#
# Earth Pro  installation file
# https://github.com/turboapps/turbome/tree/master/google/earthpro
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Write-Host "Installing application"
#Out-Null is a hack, so that powershell waits for installation to complete
& "X:\install\install.exe" "OMAHA=1" | Out-Null

$programfiles86Path = If (Test-Path "env:programfiles(x86)") {"$env:programfiles(x86)"} Else {"$env:programfiles"}
$mainExe = "$programfiles86Path\Google\Google Earth Pro\client\googleearth.exe"
$version = (Get-Item $mainExe).VersionInfo.FileVersion
"google/earthpro:$version" | Set-Content "X:\output\image.txt"