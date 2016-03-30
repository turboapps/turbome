#
# VMware vSphere Client install script
# https://github.com/turboapps/turbome/tree/master/vmware/vsphereclient
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0


# Intall vSphere Client binaries
& C:\vagrant\install\installer.exe /S | Write-Host


# Deploy Turbo PowerShell module
(New-Object System.Net.WebClient).DownloadFile(
    "https://raw.githubusercontent.com/turboapps/turbome/master/tools/powershell/Turbo/Deploy-TurboModule.ps1",
    "Deploy-TurboModule.ps1")
. .\Deploy-TurboModule.ps1
Deploy-TurboModule -Path "."
Import-Module ".\Turbo"


# Get vSphere Client version
$version = Get-FileVersion "${Env:ProgramFiles(x86)}\VMware\Infrastructure\Virtual Infrastructure Client\Launcher\VpxClient.exe"
Write-Output "Steam version after update: $version"
Set-Content 'C:\vagrant\image.txt' "steam/steam:$version"
