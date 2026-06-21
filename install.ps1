<#
.SYNOPSIS
  PushPatch CLI installer for Windows.
.EXAMPLE
  irm https://raw.githubusercontent.com/PushPatch/pushpatch_cli/main/install.ps1 | iex
#>
[CmdletBinding()]
param(
  [string]$Repo    = $env:PUSHPATCH_REPO,
  [string]$Version = $env:PUSHPATCH_VERSION,
  [string]$BinDir  = $env:PUSHPATCH_BIN_DIR
)

$ErrorActionPreference = "Stop"
if (-not $Repo)    { $Repo = "PushPatch/pushpatch_cli" }
if (-not $Version) { $Version = "latest" }
if (-not $BinDir)  { $BinDir = Join-Path $env:LOCALAPPDATA "PushPatch\bin" }

function Say($m) { Write-Host "→ $m" -ForegroundColor Cyan }
function Ok($m)  { Write-Host "✓ $m" -ForegroundColor Green }
function Die($m) { Write-Host "✗ $m" -ForegroundColor Red; exit 1 }

$target = "x86_64-pc-windows-msvc"
Say "Detected target: $target"

if ($Version -eq "latest") {
  $rel = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest"
  $Version = $rel.tag_name
}
$verNum = $Version.TrimStart("v")
Say "Installing pushpatch $verNum"

$asset = "pushpatch-$verNum-$target.zip"
$base  = "https://github.com/$Repo/releases/download/$Version"
$tmp   = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ([guid]::NewGuid()))
try {
  Say "Downloading $asset"
  Invoke-WebRequest "$base/$asset" -OutFile (Join-Path $tmp $asset)

  try {
    Invoke-WebRequest "$base/$asset.sha256" -OutFile (Join-Path $tmp "$asset.sha256")
    $expected = (Get-Content (Join-Path $tmp "$asset.sha256")).Split(" ")[0]
    $actual   = (Get-FileHash (Join-Path $tmp $asset) -Algorithm SHA256).Hash
    if ($expected -ne $actual) { Die "checksum mismatch" }
    Ok "Checksum verified"
  } catch {
    Say "No checksum published — skipping verification"
  }

  Expand-Archive (Join-Path $tmp $asset) -DestinationPath $tmp -Force
  New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
  Copy-Item (Join-Path $tmp "pushpatch.exe") (Join-Path $BinDir "pushpatch.exe") -Force
  Ok "Installed to $BinDir\pushpatch.exe"

  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if ($userPath -notlike "*$BinDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$BinDir", "User")
    Say "Added $BinDir to your PATH (restart your shell)"
  }
  & (Join-Path $BinDir "pushpatch.exe") version
  Write-Host "`n🚀 PushPatch CLI installed"
} finally {
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
