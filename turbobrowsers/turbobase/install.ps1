#
# TurboBase install script
# https://github.com/turboapps/turbome/tree/master/turbobrowsers/turbobase
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Write-Output 'Installing Firefox'
$iniConfig = @"
[Install]

MaintenanceService=false
"@
$iniConfig | Set-Content 'C:\vagrant\install\install.ini'

& C:\vagrant\install\firefox.exe /INI=C:\vagrant\install\install.ini | Write-Host

# Apply custom settings
$installDir="${env:ProgramFiles(x86)}\Mozilla Firefox"

Write-Output 'Downloading preferences'
$webClient = (New-Object System.Net.WebClient)
$webClient.DownloadFile("https://raw.githubusercontent.com/turboapps/turbome/master/firefox/config/browser/override.ini", "$installDir\browser\override.ini")

Write-Output 'Getting product version'
$webClient.DownloadFile(
    "https://raw.githubusercontent.com/turboapps/turbome/master/tools/powershell/Turbo/Deploy-TurboModule.ps1",
    "Deploy-TurboModule.ps1")
. .\Deploy-TurboModule.ps1
Deploy-TurboModule -Path "."
Import-Module ".\Turbo"
$version = (Get-FileVersion -Path "$installDir\firefox.exe")
Write-Output "Firefox version: $version"
"turbobrowsers/turbobase:$version" | Set-Content 'C:\vagrant\image.txt'