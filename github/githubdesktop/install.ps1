#
# GitHub Dekstop install script
# https://github.com/turboapps/turbome/tree/master/github/githubdesktop
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#Install Github Desktop
& "X:\install\install.exe" | Out-Null
Start-Sleep -Seconds 10
Stop-Process -Name "github*"

#Remove updater
$appdatapath = $env:LOCALAPPDATA
Get-ChildItem -Path $appdatapath -Filter "*squirrel*" -Recurse | Remove-Item -Recurse
$updaterPath = $appdatapath+"\GitHubDesktop\Update.exe"
Remove-Item $updaterPath