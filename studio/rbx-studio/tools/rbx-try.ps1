# rbx-try: try any git branch of a Rojo game in Studio without touching your working copy.
# Each branch gets a throwaway git worktree (detached, outside the game folder) plus a generated
# try.project.json that also syncs every *.spec.luau as ReplicatedStorage.<Name>Spec.
# Never commits, merges or pushes. Usage (run from the game folder):
#   rbx-try.ps1 list                         remote branches vs main
#   rbx-try.ps1 prep  <branch> [-Reset]      create or refresh the worktree, print a summary
#   rbx-try.ps1 serve <branch> [-Port 34872] [-Reset] [-OpenStudio]   prep, then rojo serve (foreground)
#   rbx-try.ps1 status                       worktrees made by rbx-try
#   rbx-try.ps1 clean [<branch> | -All]      remove worktrees (discards anything saved inside them)
param(
  [Parameter(Position = 0)][ValidateSet('list', 'prep', 'serve', 'status', 'clean')][string]$Cmd = 'list',
  [Parameter(Position = 1)][string]$Branch = '',
  [int]$Port = 34872,
  [switch]$Reset,
  [switch]$OpenStudio,
  [switch]$All,
  [string]$Remote = 'origin',
  [string]$Main = 'main'
)
$ErrorActionPreference = 'Continue'  # native git writes progress to stderr; failures are checked by exit code

function Invoke-GitChecked { & git.exe @args | Out-Null; if ($LASTEXITCODE -ne 0) { throw "git $($args -join ' ') failed" } }
$repo = (& git rev-parse --show-toplevel 2>$null)
if (-not $repo) { Write-Output 'SKIPPED: not a git repo'; exit 0 }
$repo = $repo.Trim()
$project = Get-ChildItem -LiteralPath $repo -Filter '*.project.json' -File | Where-Object { $_.Name -ne 'try.project.json' } | Select-Object -First 1
if (-not $project) { Write-Output 'SKIPPED: no *.project.json (not a Rojo project)'; exit 0 }
$repoName = (Split-Path $repo -Leaf) -replace '[^A-Za-z0-9._-]', '_'
$root = Join-Path $env:USERPROFILE (Join-Path '.rbx-try' $repoName)
function Slug([string]$b) { ($b -replace '[\\/:*?"<>| ]', '-') }
function WtPath([string]$b) { Join-Path $root (Slug $b) }

function Fetch { & git -C $repo fetch --quiet --prune $Remote 2>&1 | Out-Null }

function ResolveBranch([string]$b) {
  $refs = @(& git -C $repo for-each-ref --format='%(refname:short)' "refs/remotes/$Remote" | Where-Object { $_ -ne "$Remote/HEAD" -and $_ -ne $Remote } | ForEach-Object { $_.Substring($Remote.Length + 1) })
  if ($refs -contains $b) { return $b }
  $hits = @($refs | Where-Object { $_ -like "*$b*" })
  if ($hits.Count -eq 1) { return $hits[0] }
  if ($hits.Count -eq 0) { throw "No remote branch matches '$b'. Run: rbx-try.ps1 list" }
  throw "'$b' matches several branches: $($hits -join ', ')"
}

function Prep([string]$b) {
  $ref = "$Remote/$b"; $wt = WtPath $b
  New-Item -ItemType Directory -Force $root | Out-Null
  & git -C $repo worktree prune 2>&1 | Out-Null
  if (Test-Path -LiteralPath (Join-Path $wt '.git')) {
    $dirty = & git -C $wt status --porcelain --untracked-files=no
    if ($dirty -and -not $Reset) { throw "Worktree has saved changes (probably a saved .rbxl): $wt. Re-run with -Reset to discard them." }
    Invoke-GitChecked -C $wt checkout --quiet --detach --force $ref
  } else {
    Invoke-GitChecked -C $repo worktree add --quiet --detach $wt $ref
  }
  # try.project.json = the game's project + every spec module, so tests need no copy-paste.
  $json = Get-Content -LiteralPath (Join-Path $wt $project.Name) -Raw | ConvertFrom-Json
  $specs = @(Get-ChildItem -LiteralPath $wt -Recurse -File -Filter '*.spec.luau' | Where-Object { $_.FullName -notmatch '[\\/](_archive|node_modules|Packages|\.git)[\\/]' })
  if ($specs.Count) {
    if (-not $json.tree.PSObject.Properties['ReplicatedStorage']) { $json.tree | Add-Member -NotePropertyName ReplicatedStorage -NotePropertyValue ([pscustomobject]@{ '$className' = 'ReplicatedStorage' }) }
    $rs = $json.tree.ReplicatedStorage
    foreach ($s in $specs) {
      $name = ($s.Name -replace '\.spec\.luau$', '') + 'Spec'
      $rel = $s.FullName.Substring($wt.Length + 1) -replace '\\', '/'
      if (-not $rs.PSObject.Properties[$name]) { $rs | Add-Member -NotePropertyName $name -NotePropertyValue ([pscustomobject]@{ '$path' = $rel }) }
    }
  }
  [IO.File]::WriteAllText((Join-Path $wt 'try.project.json'), ($json | ConvertTo-Json -Depth 30))
  $short = (& git -C $wt rev-parse --short HEAD).Trim()
  $counts = (& git -C $repo rev-list --left-right --count "$Remote/$Main...$ref").Trim() -split '\s+'
  $places = @(Get-ChildItem -LiteralPath $wt -Recurse -File -Filter '*.rbxl' | Where-Object { $_.FullName -notmatch '[\\/]_archive[\\/]' } | ForEach-Object { $_.FullName })
  Write-Host "branch:   $b @ $short ($($counts[1]) ahead, $($counts[0]) behind $Main)"
  Write-Host "worktree: $wt"
  Write-Host "project:  try.project.json (+$($specs.Count) spec modules: $(($specs | ForEach-Object { ($_.Name -replace '\.spec\.luau$','') + 'Spec' }) -join ', '))"
  Write-Host "places:   $($places -join ' | ')"
  Write-Host "changed:"
  & git -C $repo diff --stat "$Remote/$Main...$ref" | Select-Object -Last 12 | ForEach-Object { Write-Host "  $_" }
  Write-Host "commits:"
  & git -C $repo log --format='  %h %an %ad %s' --date=short "$Remote/$Main..$ref" | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
  return $wt
}

switch ($Cmd) {
  'list' {
    Fetch
    $rows = & git -C $repo for-each-ref --sort=-committerdate --format='%(refname:short)|%(authorname)|%(committerdate:short)|%(subject)' "refs/remotes/$Remote"
    Write-Output "Branches on $Remote (newest first). ahead/behind vs $Main. [tried] = worktree exists."
    foreach ($r in $rows) {
      $p = $r -split '\|', 4
      if ($p[0] -eq "$Remote/HEAD" -or $p[0] -eq $Remote) { continue }
      $b = $p[0].Substring($Remote.Length + 1); if ($b -eq $Main) { continue }
      $c = (& git -C $repo rev-list --left-right --count "$Remote/$Main...$($p[0])").Trim() -split '\s+'
      $state = if ($c[1] -eq '0') { 'merged' } else { "+$($c[1]) / -$($c[0])" }
      $tried = if (Test-Path -LiteralPath (Join-Path (WtPath $b) '.git')) { ' [tried]' } else { '' }
      Write-Output ("- {0} | {1} | {2} | {3} | {4}{5}" -f $b, $p[1], $p[2], $state, $p[3], $tried)
    }
  }
  'prep' { if (-not $Branch) { throw 'Usage: rbx-try.ps1 prep <branch>' }; Fetch; $null = Prep (ResolveBranch $Branch) }
  'serve' {
    if (-not $Branch) { throw 'Usage: rbx-try.ps1 serve <branch>' }
    Fetch; $b = ResolveBranch $Branch
    $wt = Prep $b
    if ($OpenStudio) {
      $place = Get-ChildItem -LiteralPath $wt -Recurse -File -Filter '*.rbxl' | Where-Object { $_.FullName -notmatch '[\\/]_archive[\\/]' } | Sort-Object { $_.FullName -notmatch 'TestLab' } | Select-Object -First 1
      if ($place) { Start-Process -FilePath $place.FullName; Write-Output "opened:   $($place.FullName) (throwaway copy; saving it never touches your game folder)" }
    }
    Write-Output "serving:  rojo serve try.project.json --port $Port  (Studio: Plugins > Rojo > Connect to localhost:$Port; Ctrl+C stops)"
    Push-Location $wt
    try { & rojo serve try.project.json --port $Port } finally { Pop-Location }
  }
  'status' {
    if (-not (Test-Path $root)) { Write-Output 'No rbx-try worktrees.'; break }
    Get-ChildItem -LiteralPath $root -Directory | ForEach-Object {
      if (Test-Path (Join-Path $_.FullName '.git')) {
        $h = (& git -C $_.FullName log -1 --format='%h %ad %s' --date=short).Trim()
        $d = if (& git -C $_.FullName status --porcelain --untracked-files=no) { ' [has saved changes]' } else { '' }
        Write-Output "- $($_.Name): $h$d  ($($_.FullName))"
      }
    }
  }
  'clean' {
    $targets = if ($All) { @(Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }) } elseif ($Branch) { @(WtPath $Branch) } else { throw 'Usage: rbx-try.ps1 clean <branch> | -All' }
    foreach ($t in $targets) { if (Test-Path -LiteralPath $t) { & git -C $repo worktree remove --force $t 2>&1 | Out-Null; if (Test-Path -LiteralPath $t) { Remove-Item -Recurse -Force -LiteralPath $t }; Write-Output "removed: $t" } }
    & git -C $repo worktree prune 2>&1 | Out-Null
  }
}
