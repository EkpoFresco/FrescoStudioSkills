# Saves a PNG of the Roblox Studio window (look-check evidence; Studio MCP screen_capture
# returns the image to the model only). Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File capture-studio.ps1 -Out .rbx-studio/evidence/S-01/01-shop.png [-Title "RobloxStudio"]
# Brings the Studio window to the front, waits briefly, captures its rectangle.
param(
  [Parameter(Mandatory = $true)][string]$Out,
  [string]$Title = '',
  [int]$DelayMs = 400
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class RbxWin {
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
}
'@
[void][RbxWin]::SetProcessDPIAware()
$procs = Get-Process -Name 'RobloxStudioBeta' -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 }
if ($Title) { $procs = $procs | Where-Object { $_.MainWindowTitle -like "*$Title*" } }
$p = $procs | Select-Object -First 1
if (-not $p) { Write-Error 'No Roblox Studio window found (is Studio open?)'; exit 1 }
$h = $p.MainWindowHandle
if ([RbxWin]::IsIconic($h)) { [void][RbxWin]::ShowWindow($h, 9) }
[void][RbxWin]::SetForegroundWindow($h)
Start-Sleep -Milliseconds $DelayMs
$r = New-Object RbxWin+RECT
[void][RbxWin]::GetWindowRect($h, [ref]$r)
$w = $r.Right - $r.Left; $hgt = $r.Bottom - $r.Top
if ($w -le 0 -or $hgt -le 0) { Write-Error 'Studio window has no size'; exit 1 }
$bmp = New-Object System.Drawing.Bitmap $w, $hgt
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($r.Left, $r.Top, 0, 0, $bmp.Size)
$dir = Split-Path -Parent $Out
if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output "saved $Out (${w}x${hgt}) from '$($p.MainWindowTitle)'"
