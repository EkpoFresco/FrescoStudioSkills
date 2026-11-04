<#
rbx-studio installer for Claude Code (Windows PowerShell 5.1+ and PowerShell 7).

  .\install.ps1                 install or reinstall into ~/.claude (or $env:CLAUDE_CONFIG_DIR)
  .\install.ps1 -Update         git pull --ff-only this clone, then reinstall (drops removed files)
  .\install.ps1 -Uninstall      remove everything this installer added, restore what it backed up
  .\install.ps1 -Target <dir>   use another config dir (sandbox testing)
  .\install.ps1 -DryRun         print what would change, touch nothing
  .\install.ps1 -Shell bash|powershell   force the hook shell (default: Git Bash if found)

Writes only: <target>/agents/<18 studio agents>.md, <target>/skills/rbx-*/, <target>/rules/rbx-*.md,
<target>/rbx-studio/, and hook entries in <target>/settings.json (backed up first).
Never overwrites a file it did not install: such files are backed up and restored on uninstall.
#>
param(
  [switch]$Update,
  [switch]$Uninstall,
  [string]$Target = '',
  [switch]$DryRun,
  [ValidateSet('auto', 'bash', 'powershell')][string]$Shell = 'auto'
)
$ErrorActionPreference = 'Stop'
$Repo = $PSScriptRoot
if (-not $Target) { if ($env:CLAUDE_CONFIG_DIR) { $Target = $env:CLAUDE_CONFIG_DIR } else { $Target = Join-Path $HOME '.claude' } }
$Target = [IO.Path]::GetFullPath($Target)
$RbxDir = Join-Path $Target 'rbx-studio'
$RbxHome = $RbxDir -replace '\\', '/'
$Manifest = Join-Path $RbxDir 'manifest.txt'
$RestoreList = Join-Path $RbxDir 'restore.txt'
$SettingsPath = Join-Path $Target 'settings.json'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupDir = Join-Path $Target "rbx-studio-backups/$Stamp"

function Say($m) { Write-Host $m }
function Get-Sha($p) {
  $sha = [Security.Cryptography.SHA256]::Create()
  try { $fs = [IO.File]::OpenRead($p); try { return ([BitConverter]::ToString($sha.ComputeHash($fs)) -replace '-', '') } finally { $fs.Dispose() } } finally { $sha.Dispose() }
}
function Read-Manifest {
  $m = @{}
  if (Test-Path -LiteralPath $Manifest) {
    foreach ($l in Get-Content -LiteralPath $Manifest) { $parts = $l -split "`t"; if ($parts.Count -ge 2) { $m[$parts[0]] = $parts[1] } }
  }
  return $m
}
function Backup-File($rel) {
  $src = Join-Path $Target $rel
  $dst = Join-Path $BackupDir $rel
  if ($DryRun) { Say "  would back up $rel"; return }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
  Copy-Item -LiteralPath $src -Destination $dst -Force
  Add-Content -LiteralPath $RestoreList -Value "$rel`t$dst"
}
function Remove-EmptyParents($rels) {
  $dirs = @($rels | ForEach-Object { Split-Path -Parent (Join-Path $Target $_) } | Sort-Object -Unique | Sort-Object { $_.Length } -Descending)
  foreach ($d in $dirs) {
    $cur = $d
    while ($cur -and $cur.Length -gt $Target.Length -and (Test-Path -LiteralPath $cur) -and -not (Get-ChildItem -LiteralPath $cur -Force)) {
      if (-not $DryRun) { Remove-Item -LiteralPath $cur -Force }
      $cur = Split-Path -Parent $cur
    }
  }
}
function Test-IsOurHook($h) {
  $s = [string]$h.command
  if ($h.PSObject.Properties['args']) { $s += ' ' + (($h.args) -join ' ') }
  return ($s -match 'rbx-studio[\\/]+hooks[\\/]+rbx-hook')
}

# ---------- settings.json helpers ----------
function Read-Settings {
  if (Test-Path -LiteralPath $SettingsPath) {
    $raw = Get-Content -LiteralPath $SettingsPath -Raw
    if ($raw.Trim()) { return ($raw | ConvertFrom-Json) }
  }
  return (New-Object PSObject)
}
function Remove-OurHooks($s) {
  if (-not $s.PSObject.Properties['hooks']) { return $s }
  foreach ($ev in @($s.hooks.PSObject.Properties.Name)) {
    $groups = @()
    foreach ($g in @($s.hooks.$ev)) {
      $kept = @(@($g.hooks) | Where-Object { -not (Test-IsOurHook $_) })
      if ($kept.Count -gt 0) { $g.hooks = $kept; $groups += $g }
    }
    if ($groups.Count -gt 0) { $s.hooks.$ev = $groups } else { $s.hooks.PSObject.Properties.Remove($ev) }
  }
  if (@($s.hooks.PSObject.Properties).Count -eq 0) { $s.PSObject.Properties.Remove('hooks') }
  return $s
}
function New-Handler($event, $timeout, $async, $useBash) {
  if ($useBash) {
    $h = [ordered]@{ type = 'command'; command = "bash `"$RbxHome/hooks/rbx-hook.sh`" $event"; shell = 'bash'; timeout = $timeout }
  } else {
    $h = [ordered]@{ type = 'command'; command = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$RbxHome/hooks/rbx-hook.ps1`" $event"; shell = 'powershell'; timeout = $timeout }
  }
  if ($async) { $h.async = $true }
  return [pscustomobject]$h
}
function Add-OurHooks($s, $useBash) {
  $spec = @(
    @{ ev = 'SessionStart'; m = ''; e = 'session-start'; t = 15; a = $false },
    @{ ev = 'UserPromptSubmit'; m = ''; e = 'prompt'; t = 10; a = $false },
    @{ ev = 'PreToolUse'; m = 'Bash|PowerShell'; e = 'pre-bash'; t = 20; a = $false },
    @{ ev = 'PostToolUse'; m = '^(Write|Edit|MultiEdit)$|^mcp__.*multi_edit$'; e = 'post-write'; t = 30; a = $false },
    @{ ev = 'PreCompact'; m = ''; e = 'pre-compact'; t = 15; a = $false },
    @{ ev = 'Stop'; m = ''; e = 'stop'; t = 10; a = $true },
    @{ ev = 'Notification'; m = 'permission_prompt|idle_prompt'; e = 'notify'; t = 10; a = $false }
  )
  if (-not $s.PSObject.Properties['hooks']) { $s | Add-Member -NotePropertyName hooks -NotePropertyValue (New-Object PSObject) }
  foreach ($x in $spec) {
    $group = [pscustomobject][ordered]@{ matcher = $x.m; hooks = @(New-Handler $x.e $x.t $x.a $useBash) }
    if ($s.hooks.PSObject.Properties[$x.ev]) { $s.hooks.($x.ev) = @(@($s.hooks.($x.ev)) + $group) }
    else { $s.hooks | Add-Member -NotePropertyName $x.ev -NotePropertyValue @($group) }
  }
  return $s
}
function Write-Settings($s) {
  $json = $s | ConvertTo-Json -Depth 30
  [IO.File]::WriteAllText($SettingsPath, $json + "`n", (New-Object Text.UTF8Encoding $false))
}

# ---------- payload ----------
function Get-Payload {
  $items = @()
  $map = @(
    @{ src = 'studio/agents'; dst = 'agents' },
    @{ src = 'studio/skills'; dst = 'skills' },
    @{ src = 'studio/rules'; dst = 'rules' },
    @{ src = 'studio/rbx-studio'; dst = 'rbx-studio' },
    @{ src = 'docs/roblox'; dst = 'rbx-studio/library/roblox' }
  )
  foreach ($m in $map) {
    $root = Join-Path $Repo $m.src
    foreach ($f in Get-ChildItem -LiteralPath $root -Recurse -File) {
      $rel = $f.FullName.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/'
      $items += [pscustomobject]@{ Src = $f.FullName; Rel = "$($m.dst)/$rel" }
    }
  }
  return $items
}
$TextExt = '.md', '.sh', '.ps1', '.json', '.yaml', '.yml', '.txt', '.luau', '.js'

# ================= uninstall =================
if ($Uninstall) {
  $man = Read-Manifest
  if ($man.Count -eq 0) { Say "rbx-studio is not installed in $Target"; exit 0 }
  foreach ($rel in $man.Keys) {
    $p = Join-Path $Target $rel
    if (Test-Path -LiteralPath $p) {
      if ((Get-Sha $p) -ne $man[$rel] -and $rel -notlike 'rbx-studio/*') { Say "  note: $rel was edited after install; removing anyway (copy in $BackupDir)"; if (-not $DryRun) { New-Item -ItemType Directory -Force -Path (Split-Path -Parent (Join-Path $BackupDir $rel)) | Out-Null; Copy-Item -LiteralPath $p -Destination (Join-Path $BackupDir $rel) } }
      if (-not $DryRun) { Remove-Item -LiteralPath $p -Force }
    }
  }
  Remove-EmptyParents @($man.Keys | Where-Object { $_ -notlike 'rbx-studio/*' })
  # restore files we displaced
  $script:displaced = 0
  if (Test-Path -LiteralPath $RestoreList) {
    foreach ($l in Get-Content -LiteralPath $RestoreList) {
      if ($l.Trim()) { $script:displaced++ }
      $parts = $l -split "`t"
      if ($parts.Count -ge 2 -and (Test-Path -LiteralPath $parts[1])) { Say "  restoring $($parts[0])"; if (-not $DryRun) { $rd = Join-Path $Target $parts[0]; New-Item -ItemType Directory -Force -Path (Split-Path -Parent $rd) | Out-Null; Copy-Item -LiteralPath $parts[1] -Destination $rd -Force } }
    }
  }
  # settings.json: exact restore if untouched since install, else surgical removal
  $pre = Join-Path $RbxDir 'settings.pre-install.json'; $preNone = Join-Path $RbxDir 'settings.pre-install.none'
  $postSha = if (Test-Path -LiteralPath (Join-Path $RbxDir 'settings.post-install.sha')) { (Get-Content -LiteralPath (Join-Path $RbxDir 'settings.post-install.sha') -Raw).Trim() } else { '' }
  if (Test-Path -LiteralPath $SettingsPath) {
    if ($postSha -and (Get-Sha $SettingsPath) -eq $postSha -and (Test-Path -LiteralPath $pre)) {
      Say '  settings.json: restored the pre-install copy (unchanged since install)'
      if (-not $DryRun) { Copy-Item -LiteralPath $pre -Destination $SettingsPath -Force }
    } elseif ($postSha -and (Get-Sha $SettingsPath) -eq $postSha -and (Test-Path -LiteralPath $preNone)) {
      Say '  settings.json: removed (it did not exist before install)'
      if (-not $DryRun) { Remove-Item -LiteralPath $SettingsPath -Force }
    } else {
      Say '  settings.json: removed rbx-studio hook entries (file changed since install, other edits kept)'
      if (-not $DryRun) { Write-Settings (Remove-OurHooks (Read-Settings)) }
    }
  }
  if (-not $DryRun) {
    Remove-Item -LiteralPath $RbxDir -Recurse -Force
    $bk = Join-Path $Target 'rbx-studio-backups'
    if ($script:displaced -gt 0 -and (Test-Path -LiteralPath $bk)) { Say "  backups of your displaced files kept at $bk (delete when you no longer need them)" }
    elseif (Test-Path -LiteralPath $bk) { Remove-Item -LiteralPath $bk -Recurse -Force }
  }
  Say "rbx-studio uninstalled from $Target"
  exit 0
}

# ================= install / update =================
if ($Update) {
  Say "Updating clone at $Repo"
  if (-not $DryRun) { git -C $Repo pull --ff-only; if ($LASTEXITCODE -ne 0) { throw 'git pull --ff-only failed; resolve the clone first' } }
}
if (-not (Test-Path -LiteralPath (Join-Path $Repo 'studio/rbx-studio/VERSION'))) { throw "Run from the rbx-studio repo root (missing studio/rbx-studio/VERSION)" }
$Version = (Get-Content -LiteralPath (Join-Path $Repo 'studio/rbx-studio/VERSION') -Raw).Trim()

# hook shell
$useBash = $false
if ($Shell -eq 'bash') { $useBash = $true }
elseif ($Shell -eq 'auto') {
  $gitBash = @($env:CLAUDE_CODE_GIT_BASH_PATH, 'C:\Program Files\Git\bin\bash.exe', 'C:\Program Files (x86)\Git\bin\bash.exe', (Join-Path $env:LOCALAPPDATA 'Programs\Git\bin\bash.exe')) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
  if ($gitBash -or -not ($IsWindows -or $env:OS -eq 'Windows_NT')) { $useBash = $true }
}
Say "Installing rbx-studio $Version into $Target (hooks: $(if ($useBash) { 'Git Bash' } else { 'PowerShell' }))$(if ($DryRun) { ' [dry run]' })"

$old = Read-Manifest
$payload = Get-Payload
$newSet = @{}; foreach ($i in $payload) { $newSet[$i.Rel] = $true }
if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $RbxDir | Out-Null }

# collisions: a file at a payload path that we did not install (or that the user edited)
$collisions = 0
foreach ($i in $payload) {
  $dst = Join-Path $Target $i.Rel
  if (Test-Path -LiteralPath $dst) {
    $ours = $old.ContainsKey($i.Rel) -and ((Get-Sha $dst) -eq $old[$i.Rel])
    if (-not $ours -and $i.Rel -notlike 'rbx-studio/*') { $collisions++; Say "  collision: $($i.Rel) exists and is not ours; backing it up"; Backup-File $i.Rel }
  }
}

# copy with {{RBX_HOME}} substitution
$lines = @()
foreach ($i in $payload) {
  $dst = Join-Path $Target $i.Rel
  if ($DryRun) { continue }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
  if ($TextExt -contains [IO.Path]::GetExtension($i.Src).ToLowerInvariant()) {
    $t = [IO.File]::ReadAllText($i.Src) -replace '\{\{RBX_HOME\}\}', $RbxHome
    [IO.File]::WriteAllText($dst, $t, (New-Object Text.UTF8Encoding $false))
  } else { Copy-Item -LiteralPath $i.Src -Destination $dst -Force }
  $lines += "$($i.Rel)`t$(Get-Sha $dst)"
}

# files from the previous version that are gone now
$removed = 0; $stale = @()
foreach ($rel in $old.Keys) {
  if (-not $newSet.ContainsKey($rel)) { $p = Join-Path $Target $rel; $stale += $rel; if (Test-Path -LiteralPath $p) { $removed++; if (-not $DryRun) { Remove-Item -LiteralPath $p -Force } } }
}
if ($stale.Count -gt 0) { Remove-EmptyParents $stale }

if (-not $DryRun) {
  # settings.json: back up the pre-install state once, then replace our hook block
  $pre = Join-Path $RbxDir 'settings.pre-install.json'; $preNone = Join-Path $RbxDir 'settings.pre-install.none'
  if (-not (Test-Path -LiteralPath $pre) -and -not (Test-Path -LiteralPath $preNone)) {
    if (Test-Path -LiteralPath $SettingsPath) { Copy-Item -LiteralPath $SettingsPath -Destination $pre } else { Set-Content -LiteralPath $preNone -Value '' }
  }
  if (Test-Path -LiteralPath $SettingsPath) { New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null; Copy-Item -LiteralPath $SettingsPath -Destination (Join-Path $BackupDir 'settings.json') }
  Write-Settings (Add-OurHooks (Remove-OurHooks (Read-Settings)) $useBash)
  Set-Content -LiteralPath (Join-Path $RbxDir 'settings.post-install.sha') -Value (Get-Sha $SettingsPath) -Encoding ascii
  Set-Content -LiteralPath $Manifest -Value $lines -Encoding utf8
  Set-Content -LiteralPath (Join-Path $RbxDir 'source.txt') -Value ($Repo -replace '\\', '/') -Encoding utf8
}

$agents = @($payload | Where-Object { $_.Rel -like 'agents/*' }).Count
$skills = @($payload | Where-Object { $_.Rel -like 'skills/*/SKILL.md' }).Count
$rules = @($payload | Where-Object { $_.Rel -like 'rules/*' }).Count
Say "Done: $agents agents, $skills skills, $rules rules, $($payload.Count) files; $collisions collisions backed up; $removed stale files removed."
Say "Next: restart Claude Code in a Roblox game folder and run /rbx-start."
Say "Studio MCP (once): Studio > Assistant > ... > Manage MCP Servers > enable; then: claude mcp add --scope user roblox-studio -- `"%LOCALAPPDATA%\Roblox\mcp.bat`""
