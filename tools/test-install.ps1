# Installer round trip in a sandbox config dir: install, reinstall, update-style rerun, uninstall.
# Usage: pwsh -File tools/test-install.ps1 -Sandbox <empty dir> [-Shell auto|bash|powershell]
param([Parameter(Mandatory = $true)][string]$Sandbox, [string]$Shell = 'auto')
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$sb = [IO.Path]::GetFullPath($Sandbox)
if (Test-Path -LiteralPath $sb) { Remove-Item -LiteralPath $sb -Recurse -Force }
New-Item -ItemType Directory -Force (Join-Path $sb 'agents') | Out-Null
[IO.File]::WriteAllText((Join-Path $sb 'settings.json'), '{"model":"opus","hooks":{"Stop":[{"matcher":"","hooks":[{"type":"command","command":"echo user-hook"}]}]}}')
[IO.File]::WriteAllText((Join-Path $sb 'agents/analytics-engineer.md'), "my own analytics agent`n")
function Sha($p) { $h = [Security.Cryptography.SHA256]::Create(); $b = [IO.File]::ReadAllBytes($p); ([BitConverter]::ToString($h.ComputeHash($b)) -replace '-', '') }
function Snap { Get-ChildItem -LiteralPath $sb -Recurse -Directory | Where-Object { $_.FullName -notlike '*rbx-studio-backups*' } | ForEach-Object { 'DIR ' + $_.FullName.Substring($sb.Length) }; Get-ChildItem -LiteralPath $sb -Recurse -File | Where-Object { $_.FullName -notlike '*rbx-studio-backups*' } | ForEach-Object { '{0} {1}' -f $_.FullName.Substring($sb.Length), (Sha $_.FullName) } }
$before = @(Snap)
$pass = 0; $fail = 0
function Check($name, $ok) { if ($ok) { $script:pass++; Write-Host "  ok   $name" } else { $script:fail++; Write-Host "  FAIL $name" } }

& (Join-Path $repo 'install.ps1') -Target $sb -Shell $Shell | Out-Host
& (Join-Path $repo 'install.ps1') -Target $sb -Shell $Shell | Out-Null
# simulate a skill dropped in a newer version: add it to the manifest, rerun, expect it gone
New-Item -ItemType Directory -Force (Join-Path $sb 'skills/rbx-old') | Out-Null
[IO.File]::WriteAllText((Join-Path $sb 'skills/rbx-old/SKILL.md'), 'old')
Add-Content -LiteralPath (Join-Path $sb 'rbx-studio/manifest.txt') -Value ("skills/rbx-old/SKILL.md`t" + (Sha (Join-Path $sb 'skills/rbx-old/SKILL.md')))
& (Join-Path $repo 'install.ps1') -Target $sb -Shell $Shell | Out-Null
$s = Get-Content -LiteralPath (Join-Path $sb 'settings.json') -Raw | ConvertFrom-Json
Check 'stale skill from old version removed with its folder' (-not (Test-Path (Join-Path $sb 'skills/rbx-old')))
Check 'agents installed (18 + user file replaced)' (@(Get-ChildItem (Join-Path $sb 'agents')).Count -eq 18)
Check 'skills installed (28)' (@(Get-ChildItem (Join-Path $sb 'skills') -Directory).Count -eq 28)
Check 'rules installed (7)' (@(Get-ChildItem (Join-Path $sb 'rules')).Count -eq 7)
Check 'library copied' (Test-Path (Join-Path $sb 'rbx-studio/library/roblox/genres/idle-clicker.md'))
$left = @(Select-String -Path (Join-Path $sb 'agents/*.md'), (Join-Path $sb 'skills/*/SKILL.md'), (Join-Path $sb 'rules/*.md'), (Join-Path $sb 'rbx-studio/CONTEXT.md') -Pattern '\{\{RBX_HOME\}\}').Count
Check 'no {{RBX_HOME}} left' ($left -eq 0)
Check 'absolute home substituted' ((Get-Content (Join-Path $sb 'agents/code-optimizer.md') -Raw).Contains(($sb -replace '\\', '/') + '/rbx-studio/library'))
Check 'user hook kept' ([bool](@($s.hooks.Stop) | ForEach-Object { $_.hooks } | Where-Object { $_.command -eq 'echo user-hook' }))
Check 'user model kept' ($s.model -eq 'opus')
Check 'reinstall did not duplicate hooks (Stop = user + ours)' (@($s.hooks.Stop).Count -eq 2)
Check '7 hook events' (@($s.hooks.PSObject.Properties).Count -eq 7)
Check 'collision backed up' ([bool](Get-ChildItem (Join-Path $sb 'rbx-studio-backups') -Recurse -Filter 'analytics-engineer.md'))
$hookCmd = @($s.hooks.PreToolUse)[0].hooks[0].command
Write-Host "  hook command: $hookCmd"
& (Join-Path $repo 'install.ps1') -Target $sb -Uninstall | Out-Host
$after = @(Snap)
$diff = Compare-Object $before $after
Check 'uninstall restores exact original files' ($null -eq $diff)
if ($diff) { $diff | Out-Host }
Write-Host "RESULT: $pass passed, $fail failed"
if ($fail -gt 0) { exit 1 }
