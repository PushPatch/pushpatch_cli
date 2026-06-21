<#
.SYNOPSIS
  PushPatch CLI uninstaller for Windows.
.EXAMPLE
  irm https://raw.githubusercontent.com/PushPatch/pushpatch_cli/main/uninstall.ps1 | iex
.DESCRIPTION
  Removes the binary, config/cache (~/.pushpatch), and PATH entry.
  Pass -KeepConfig to keep ~/.pushpatch.
#>
[CmdletBinding()]
param(
  [string]$BinDir = $env:PUSHPATCH_BIN_DIR,
  [switch]$KeepConfig
)

$ErrorActionPreference = "Stop"
if (-not $BinDir) { $BinDir = Join-Path $env:LOCALAPPDATA "PushPatch\bin" }

function Say($m)  { Write-Host "→ $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "✓ $m" -ForegroundColor Green }
function Warn($m) { Write-Host "! $m" -ForegroundColor Yellow }

# 1. clear stored credentials (best-effort)
if (Get-Command pushpatch -ErrorAction SilentlyContinue) {
  Say "Clearing stored credentials"
  try { pushpatch logout | Out-Null } catch { }
}

# 2. remove the binary
$exe = Join-Path $BinDir "pushpatch.exe"
if (Test-Path $exe) { Remove-Item $exe -Force; Ok "Removed $exe" }
else { Warn "No pushpatch.exe in $BinDir" }

# 3. remove the bin dir from the user PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -and $userPath -like "*$BinDir*") {
  $newPath = ($userPath -split ';' | Where-Object { $_ -and $_ -ne $BinDir }) -join ';'
  [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
  Ok "Removed $BinDir from PATH (restart your shell)"
}

# 4. remove config & cache
$cfg = Join-Path $env:USERPROFILE ".pushpatch"
if ($KeepConfig) { Say "Keeping $cfg (-KeepConfig)" }
elseif (Test-Path $cfg) { Remove-Item -Recurse -Force $cfg; Ok "Removed $cfg" }

Warn "If installed via a package manager, also run: choco uninstall pushpatch  /  winget uninstall PushPatch.PushPatch"
Write-Host "`n✓ PushPatch CLI uninstalled"
