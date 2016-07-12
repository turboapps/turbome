#
# Viber install script
# https://github.com/turboapps/turbome/tree/master/viber
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Write-Output 'Installing Viber'
& C:\vagrant\install\ViberSetup.exe /install /quiet /norestart | Out-Null
& taskkill /im viber.exe /f

Write-Output 'Getting product version'
$webClient = (New-Object System.Net.WebClient)
$webClient.DownloadFile(
    "https://raw.githubusercontent.com/turboapps/turbome/master/tools/powershell/Turbo/Deploy-TurboModule.ps1",
    "Deploy-TurboModule.ps1")
. .\Deploy-TurboModule.ps1
Deploy-TurboModule -Path "."
Import-Module ".\Turbo"
$version = (Get-FileVersion -Path "${env:LOCALAPPDATA}\Viber\Viber.exe")
Write-Output "Viber version: $version"
"viber/viber:$version" | Set-Content 'C:\vagrant\image.txt'