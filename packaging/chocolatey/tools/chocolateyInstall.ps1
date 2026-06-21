$ErrorActionPreference = 'Stop'

$version  = '0.1.0'
$packageName = 'pushpatch'
$url64    = "https://github.com/pushpatch/pushpatch_cli/releases/download/v$version/pushpatch-$version-x86_64-pc-windows-msvc.zip"
$checksum = 'REPLACE_WITH_X86_64_WINDOWS_SHA256'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Install-ChocolateyZipPackage `
  -PackageName   $packageName `
  -Url64bit      $url64 `
  -UnzipLocation $toolsDir `
  -Checksum64    $checksum `
  -ChecksumType64 'sha256'

# Chocolatey auto-shims any .exe placed under tools/.
