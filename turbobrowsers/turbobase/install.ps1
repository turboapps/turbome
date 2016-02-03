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
$webClient.DownloadFile("https://raw.githubusercontent.com/turboapps/turbome/master/firefox/config/mozilla.cfg", "$installDir\mozilla.cfg")
$webClient.DownloadFile("https://raw.githubusercontent.com/turboapps/turbome/master/firefox/config/browser/override.ini", "$installDir\browser\override.ini")
New-Item "$installDir\defaults" -ItemType Directory -ErrorAction 'silentlycontinue'
New-Item "$installDir\defaults\preferences" -ItemType Directory -ErrorAction 'silentlycontinue'
$webClient.DownloadFile("https://raw.githubusercontent.com/turboapps/turbome/master/firefox/config/browser/defaults/preferences/local-settings.js", "$installDir\defaults\preferences\local-settings.js")

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