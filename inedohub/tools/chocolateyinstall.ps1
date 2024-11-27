$ErrorActionPreference = "Stop"
$toolsdir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$pp = Get-PackageParameters
$filepath = Join-Path $toolsdir -ChildPath 'DesktopHub.zip'

# Use Get-ChocolateyWebFile to download latest installer
$webfileArgs = @{
  PackageName  = $env:ChocolateyPackageName
  FileFullPath = $filepath
  Url          = "https://proget.inedo.com/upack/Products/download/InedoReleases/DesktopHub?contentOnly=zip&latest"
  Checksum     = '615ED7D113ACD1071667F6AEDB4F83B6A52379DB55ECA0BB98769091B38C39A6'
  ChecksumType = 'SHA256'
}

Get-ChocolateyWebFile @webfileArgs

# Create the unzip location
$unzipLocation = if ($pp['Destination']) {
  $pp['Destination']
}
else {
  'C:\InedoHub\'
}

# Use Get-ChocolateyUnzip to unzip InedoHub to created location
$unzipArgs = @{
  FileFullPath = $filepath
  Destination  = $unzipLocation
  PackageName  = $env:ChocolateyPackageName
}

Get-ChocolateyUnzip @unzipArgs

#Set system path location for easy execution
Install-ChocolateyPath -Path $unzipLocation -PathType 'Machine'

# Write text file to document unzip location for use with uninstallation
Set-Content -Path (Join-Path $toolsdir -ChildPath 'uninstall.txt') -Value $unzipLocation

#Clean up downloaded artifacts
Remove-Item $filepath -Recurse -Force
