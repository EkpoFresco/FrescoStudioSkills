# rbx-studio hook dispatcher (PowerShell twin of rbx-hook.sh). Usage: rbx-hook.ps1 <event>
# Same contract: silent outside Roblox projects; writes only under <project>/.rbx-studio/;
# exit 2 only from pre-bash. Works on Windows PowerShell 5.1 and PowerShell 7.
param([string]$Event = '')
$ErrorActionPreference = 'SilentlyContinue'

$RbxHome = '{{RBX_HOME}}'
if ($RbxHome -like '*{{*' -or -not $RbxHome) { $RbxHome = Split-Path -Parent $PSScriptRoot }

$raw = [Console]::In.ReadToEnd()
try { $j = $raw | ConvertFrom-Json } catch { $j = $null }
function Get-J($path) {
  $o = $j; foreach ($p in $path.Split('.')) { if ($null -eq $o) { return '' }; $o = $o.$p }
  if ($null -eq $o) { return '' } ; return [string]$o
}

$Root = $env:CLAUDE_PROJECT_DIR
if (-not $Root) { $Root = Get-J 'cwd' }
if (-not $Root) { $Root = (Get-Location).Path }
$Session = (Get-J 'session_id') -replace '[^A-Za-z0-9_-]', ''
$Rbx = Join-Path $Root '.rbx-studio'
$State = Join-Path $Rbx 'state'

function Test-Roblox([bool]$deep) {
  if (Test-Path -LiteralPath $Rbx -PathType Container) { return $true }
  foreach ($pat in '*.project.json', '*.rbxl', '*.rbxlx') {
    if (Get-ChildItem -LiteralPath $Root -Filter $pat -File -ErrorAction SilentlyContinue | Select-Object -First 1) { return $true }
  }
  foreach ($f in 'wally.toml', 'rokit.toml', 'aftman.toml', 'foreman.toml') { if (Test-Path -LiteralPath (Join-Path $Root $f)) { return $true } }
  $mcp = Join-Path $Root '.mcp.json'
  if ((Test-Path -LiteralPath $mcp) -and (Select-String -LiteralPath $mcp -Pattern 'StudioMCP|roblox' -Quiet)) { return $true }
  if ($deep) {
    $hit = Get-ChildItem -LiteralPath $Root -Filter '*.luau' -Recurse -Depth 2 -File -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -notmatch '[\\/](node_modules|\.git|Packages)[\\/]' } | Select-Object -First 1
    if ($hit) { return $true }
  }
  return $false
}

function Initialize-State {
  New-Item -ItemType Directory -Force -Path $State | Out-Null
  $gi = Join-Path $Rbx '.gitignore'
  if (-not (Test-Path -LiteralPath $gi)) { Set-Content -LiteralPath $gi -Value 'state/' -Encoding ascii }
}

function Get-Yaml($key) {
  $y = Join-Path $Rbx 'project.yaml'
  if (-not (Test-Path -LiteralPath $y)) { return '' }
  $m = Select-String -LiteralPath $y -Pattern "^\s*${key}:\s*(.*)$" | Select-Object -First 1
  if (-not $m) { return '' }
  return (($m.Matches[0].Groups[1].Value -replace '\s+#.*$', '').Trim().Trim('"').Trim("'"))
}

function Get-AgeSeconds($p) {
  if (-not (Test-Path -LiteralPath $p)) { return 999999 }
  return [int]((Get-Date) - (Get-Item -LiteralPath $p).LastWriteTime).TotalSeconds
}

function Invoke-Git([string[]]$a) { & git -C $Root @a 2>$null }

# Returns 1-based line numbers of inline OnServerEvent/OnServerInvoke handlers with client
# args beyond player and no guard in the next 12 lines. Mirrors guard_scan in rbx-hook.sh.
function Find-Unguarded([string[]]$lines) {
  $extra = @((Get-Yaml 'guard_words').Trim('[', ']') -split ',' | ForEach-Object { $_.Trim().Trim('"') } | Where-Object { $_ })
  $out = @()
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $s = $lines[$i]
    if ($s -notmatch 'OnServerEvent\s*:\s*Connect\s*\(' -and $s -notmatch 'OnServerInvoke\s*=') { continue }
    if ($s -notmatch 'function\s*\(([^)]*)\)') { continue }
    if ($Matches[1] -notmatch ',') { continue }
    if ($i -gt 0 -and $lines[$i - 1] -match 'rbx:guarded') { continue }
    $ok = $false
    for ($k = $i; $k -le [Math]::Min($i + 12, $lines.Count - 1); $k++) {
      $t = $lines[$k]
      if ($t -match 'typeof\s*\(|(^|[^A-Za-z0-9_])t\.[a-z]|[Gg]uard|[Vv]alidat|assert\s*\(|[Cc]heck|rbx:guarded|[Ss]anitiz') { $ok = $true; break }
      foreach ($w in $extra) { if ($t.Contains($w)) { $ok = $true; break } }
      if ($ok) { break }
    }
    if (-not $ok) { $out += ($i + 1) }
  }
  return $out
}

switch ($Event) {

  'session-start' {
    if (-not (Test-Roblox $true)) { exit 0 }
    $ver = (Get-Content -LiteralPath (Join-Path $RbxHome 'VERSION') -Raw).Trim()
    if (-not $ver) { $ver = 'dev' }
    Write-Output "[rbx-studio $ver] Roblox project detected at $Root"
    $ctx = Join-Path $RbxHome 'CONTEXT.md'
    if (Test-Path -LiteralPath $ctx) { Get-Content -LiteralPath $ctx -Raw | Write-Output }
    if (Test-Path -LiteralPath (Join-Path $Rbx 'project.yaml')) {
      Write-Output ("Project: genre={0} toolchain={1} rigor={2} team_size={3}" -f (Get-Yaml 'genre'), (Get-Yaml 'toolchain'), (Get-Yaml 'rigor'), (Get-Yaml 'team_size'))
      if (-not (Test-Path -LiteralPath (Join-Path $Rbx 'conventions.md'))) { Write-Output 'Gap: no .rbx-studio/conventions.md. /rbx-start builds it.' }
    } else { Write-Output 'No .rbx-studio/project.yaml yet. Suggest /rbx-start before other rbx skills.' }
    $cp = Join-Path $Rbx 'checkpoint.md'
    if (Test-Path -LiteralPath $cp) {
      Write-Output ("Checkpoint: .rbx-studio/checkpoint.md ({0} min old). After a crash or compaction, run /rbx-resume." -f [int]((Get-AgeSeconds $cp) / 60))
      $lt = Join-Path $State 'last-turn.txt'
      if ((Test-Path -LiteralPath $lt) -and ((Get-Item -LiteralPath $lt).LastWriteTime -gt (Get-Item -LiteralPath $cp).LastWriteTime)) {
        Write-Output 'Note: work happened after the last checkpoint (state/last-turn.txt is newer).'
      }
    }
    $h = Get-ChildItem -LiteralPath (Join-Path $Rbx 'handoffs') -Filter '*.md' -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($h) { Write-Output "Latest handoff: .rbx-studio/handoffs/$($h.Name)" }
    $src = (Get-Content -LiteralPath (Join-Path $RbxHome 'source.txt') -Raw)
    if ($src) {
      $sv = (Get-Content -LiteralPath (Join-Path $src.Trim() 'studio/rbx-studio/VERSION') -Raw)
      if ($sv -and $sv.Trim() -ne $ver) { Write-Output "Studio update available ($ver -> $($sv.Trim())): run install.ps1 -Update in $($src.Trim())" }
    }
    exit 0
  }

  'prompt' {
    if (-not (Test-Roblox $false)) { exit 0 }
    $p = (Get-J 'prompt').ToLowerInvariant()
    if (-not $p) { exit 0 }
    $tok = Join-Path $State "approval-$Session"
    if ($p -match "(don'?t|do not|never|no|not yet|stop)\s+(to\s+)?(push|ship|merge|open)") { Remove-Item -LiteralPath $tok -Force; exit 0 }
    if ($p -match '^\s*/rbx-ship|approved?[,.!]?\s+(to\s+)?(push|ship|merge)|(ok|okay|yes|go)[,.!]?\s+(ahead\s+(and\s+)?)?push|push it|ship it|you can push|go ahead and (push|ship|open the pr)|open the pr') {
      Initialize-State
      Set-Content -LiteralPath $tok -Value ([DateTimeOffset]::UtcNow.ToUnixTimeSeconds()) -Encoding ascii
      Write-Output '[rbx-studio] Push/PR approval recorded for this session (2 h).'
    }
    exit 0
  }

  'pre-bash' {
    if ($raw -notmatch '"tool_input"[\s\S]*([Gg]it|gh )') { exit 0 }
    if (-not (Test-Roblox $false)) { exit 0 }
    $cmd = Get-J 'tool_input.command'
    if (-not $cmd) { exit 0 }
    $need = ''; $isCommit = $false; $all = $false
    foreach ($seg in ($cmd -split '&&|\|\||;|\||\r?\n')) {
      $s = ($seg.Trim() -replace '^([A-Za-z_][A-Za-z0-9_]*=\S*\s+)*', '' -replace '^(&|command|exec)\s+', '')
      $git = '^"?([^ ]*[/\\])?git(\.exe)?"?'
      if ($s -match ($git + '(\s+-[Cc]\s+\S+|\s+--[a-z-]+(=\S+)?)*\s+push(\s|$)')) {
        if ($s -notmatch '--dry-run|(^|\s)-n(\s|$)') { $need = 'git push' }
      } elseif ($s -match '^gh(\.exe)?\s+pr\s+(create|merge)') { $need = 'gh pr' }
      elseif ($s -match ($git + '.*\smerge(\s|$)')) {
        $br = (Invoke-Git @('rev-parse', '--abbrev-ref', 'HEAD')); $mb = Get-Yaml 'main_branch'; if (-not $mb) { $mb = 'main' }
        if ($br -eq $mb -or $br -eq 'master') { $need = "git merge into $br" }
      } elseif ($s -match ($git + '(\s+-[Cc]\s+\S+)*\s+commit(\s|$)')) {
        $isCommit = $true; if ($s -match '(^|\s)-[a-zA-Z]*a|--all') { $all = $true }
      }
    }
    if ($need) {
      $tok = Join-Path $State "approval-$Session"
      if ($Session -and (Test-Path -LiteralPath $tok) -and ((Get-AgeSeconds $tok) -lt 7200)) { exit 0 }
      [Console]::Error.WriteLine("BLOCKED by rbx-studio: '$need' needs the developer's approval this session. Stop and ask. They approve by typing 'approved, push' or running /rbx-ship. Local commits are fine.")
      exit 2
    }
    if ($isCommit) {
      $files = @(Invoke-Git @('diff', '--cached', '--name-only', '--diff-filter=ACM'))
      if ($all) { $files += @(Invoke-Git @('diff', '--name-only', '--diff-filter=ACM')) }
      $report = @()
      foreach ($f in ($files | Sort-Object -Unique)) {
        if ($f -notmatch '\.(lua|luau)$') { continue }
        $content = @(Invoke-Git @('show', ":$f"))
        if (-not $content -or $content.Count -eq 0) { $content = @(Get-Content -LiteralPath (Join-Path $Root $f)) }
        foreach ($ln in (Find-Unguarded $content)) { $report += "  ${f}:$ln" }
      }
      if ($report.Count -gt 0) {
        [Console]::Error.WriteLine("BLOCKED by rbx-studio: unguarded remote handlers in files being committed:`n" + ($report -join "`n") + "`nValidate every client arg (typeof, range, ownership, rate limit) before use. If validated elsewhere, add '-- rbx:guarded' on the line above the Connect. Rule: rbx-remotes.")
        exit 2
      }
    }
    exit 0
  }

  'post-write' {
    if (-not (Test-Roblox $false)) { exit 0 }
    $tool = Get-J 'tool_name'
    $fp = Get-J 'tool_input.file_path'
    $msgs = @(); $lines = @(); $label = $fp; $isMcp = $false
    if ($tool -like 'mcp__*multi_edit*') {
      $isMcp = $true
      foreach ($e in @($j.tool_input.edits)) { if ($e.new_string) { $lines += ([string]$e.new_string -split "`r?`n") } }
    } else {
      if ($fp -notmatch '\.(lua|luau)$' -or -not (Test-Path -LiteralPath $fp)) { exit 0 }
      $lines = @(Get-Content -LiteralPath $fp)
      $full = (Resolve-Path -LiteralPath $fp).Path
      if ($full.StartsWith($Root)) { $label = $full.Substring($Root.Length).TrimStart('\', '/') }
      $hasStylua = (Test-Path -LiteralPath (Join-Path $Root 'stylua.toml')) -or (Test-Path -LiteralPath (Join-Path $Root '.stylua.toml'))
      if ($hasStylua -and (Get-Command stylua -ErrorAction SilentlyContinue)) {
        Push-Location $Root; & stylua --check $fp *> $null; $rc = $LASTEXITCODE; Pop-Location
        if ($rc -ne 0) { $msgs += "- StyLua: $label is not formatted. Run: stylua `"$label`"" }
      }
      if ((Test-Path -LiteralPath (Join-Path $Root 'selene.toml')) -and (Get-Command selene -ErrorAction SilentlyContinue)) {
        Push-Location $Root; $o = (& selene --display-style Quiet $fp 2>&1 | Select-String 'error|warning' | Select-Object -First 15) -join "`n"; Pop-Location
        if ($o) { $msgs += "- Selene:`n$o" }
      }
    }
    $text = $lines -join "`n"
    if ($text -match 'GetDataStore|GetOrderedDataStore|DataStoreService') {
      $dm = Get-Yaml 'data_module'
      if ($dm) {
        $dmp = $dm -replace '\\', '/'; $dmd = $dm -replace '[\\/]', '.'
        $norm = $label -replace '\\', '/'
        if (-not ($norm.Contains($dmp) -or $norm.Contains($dmd))) { $msgs += "- Data: DataStore access in $label, outside the data module ($dm). Route reads/writes through the data module (rule rbx-data)." }
      } elseif ($label -notmatch '[Dd]ata|[Pp]rofile|[Ss]tore|[Ss]ave|[Pp]ersist|[Rr]eceipt') {
        $msgs += "- Data: DataStore access in $label, which does not look like the data module. Keep DataStore calls in one module (rule rbx-data). Set paths.data_module in .rbx-studio/project.yaml."
      }
    }
    $bad = @(Find-Unguarded $lines)
    if ($bad.Count -gt 0) { $msgs += "- Remotes: unguarded handler(s) in $label at line(s) $($bad -join ' '). Validate client args before use (rule rbx-remotes). Commits will be blocked until fixed." }
    if ($msgs.Count -eq 0) { exit 0 }
    $ctx = "[rbx-studio] Checks on ${label}:`n" + ($msgs -join "`n")
    $obj = @{ hookSpecificOutput = @{ hookEventName = 'PostToolUse'; additionalContext = $ctx } }
    Write-Output ($obj | ConvertTo-Json -Compress -Depth 5)
    exit 0
  }

  'pre-compact' {
    if (-not (Test-Roblox $false)) { exit 0 }
    Initialize-State
    $o = @("# Auto checkpoint (PreCompact) $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')", "session: $Session",
      "branch: $(Invoke-Git @('rev-parse','--abbrev-ref','HEAD'))", '## git status')
    $o += @(Invoke-Git @('status', '--short') | Select-Object -First 40)
    $o += '## last commits'; $o += @(Invoke-Git @('log', '--oneline', '-5'))
    $cp = Join-Path $Rbx 'checkpoint.md'
    if (Test-Path -LiteralPath $cp) { $o += "## manual checkpoint is $([int]((Get-AgeSeconds $cp) / 60)) min old" }
    Set-Content -LiteralPath (Join-Path $State 'auto-checkpoint.md') -Value $o -Encoding utf8
    exit 0
  }

  'stop' {
    if (-not (Test-Roblox $false)) { exit 0 }
    Initialize-State
    $o = @("time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')", "session: $Session", "branch: $(Invoke-Git @('rev-parse','--abbrev-ref','HEAD'))", 'changed:')
    $o += @(Invoke-Git @('status', '--short') | Select-Object -First 50)
    Set-Content -LiteralPath (Join-Path $State 'last-turn.txt') -Value $o -Encoding utf8
    exit 0
  }

  'notify' {
    if (-not (Test-Roblox $false)) { exit 0 }
    $msg = Get-J 'message'; if (-not $msg) { $msg = 'Claude Code needs your attention' }
    if ($msg.Length -gt 200) { $msg = $msg.Substring(0, 200) }
    $safe = $msg -replace "'", "''"
    Start-Process -WindowStyle Hidden powershell.exe -ArgumentList '-NoProfile', '-NonInteractive', '-Command',
      "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; `$n = New-Object System.Windows.Forms.NotifyIcon; `$n.Icon = [System.Drawing.SystemIcons]::Information; `$n.BalloonTipTitle = 'Claude Code (Roblox)'; `$n.BalloonTipText = '$safe'; `$n.Visible = `$true; `$n.ShowBalloonTip(5000); Start-Sleep -Seconds 6; `$n.Dispose()"
    exit 0
  }

  default { exit 0 }
}
