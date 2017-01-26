#
# Chromium Canary install script
# https://github.com/turboapps/turbome/tree/master/chromium/canary
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# Download Canary binaries
(New-Object System.Net.WebClient).DownloadFile(
    "https://download-chromium.appspot.com/dl/Win?type=continuous",
    "chromium-win32.zip")

# Extract binaries to a fixed location
$fullPath = Get-ChildItem -Path ".\chromium-win32.zip"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($fullPath, "c:\Chromium")

# Deploy Turbo PowerShell module
(New-Object System.Net.WebClient).DownloadFile(
    "https://raw.githubusercontent.com/turboapps/turbome/master/tools/powershell/Turbo/Deploy-TurboModule.ps1",
    "Deploy-TurboModule.ps1")
. .\Deploy-TurboModule.ps1
Deploy-TurboModule -Path "."
Import-Module ".\Turbo"

# Perform the first launch
try
{
    Write-Host -Verbose "Launching Chromium for the first time"
    $launchProcessTask = 'Start Chromium Canary'
    Remove-ScheduledTask $launchProcessTask | Out-Null
    Start-ProcessInScheduledTask -TaskName $launchProcessTask -Path "C:\Chromium\chrome-win32\chrome.exe"
}
finally
{
    Remove-ScheduledTask $launchProcessTask | Out-Null
}

try
{
    Write-Host -Verbose "Close Chromium window"
    $closeProcessTask = 'Close Chromium Canary'
    Remove-ScheduledTask $closeProcessTask | Out-Null
    Close-WindowProcessInScheduledTask -TaskName $closeProcessTask -ProcessName chrome
}
finally
{
    Remove-ScheduledTask $closeProcessTask | Out-Null
}

# Set preferences
Write-Host "Overwriting default preferences"
$preferencesPath = "${env:LOCALAPPDATA}\Chromium\User Data\Default\Preferences"

Set-JsonPreference -Path  $preferencesPath -Category 'browser' -Property 'check_default_browser' -Value $false | Out-Null
Set-JsonPreference -Path  $preferencesPath -Category 'download' -Property 'prompt_for_download' -Value $true | Out-Null
Set-JsonPreference -Path  $preferencesPath -Category 'download' -Property 'directory_upgrade' -Value $true | Out-Null
Set-JsonPreference -Path  $preferencesPath -Category 'download' -Property 'extensions_to_open' -Value "" | Out-Null

# Remove the cache directories from the snap shot
# However, we leave in the empty cache directories, so that we can set a noSync policy on them
# Check that this section is in sync with the snapshot/xappl manipulation in 'post_snapshot.ps1'
Remove-Item -Recurse -Force $env:LOCALAPPDATA'\Google\Chrome\User Data\Default\Cache'
New-Item -ItemType Directory -Force -Path $env:LOCALAPPDATA'\Google\Chrome\User Data\Default\Cache'

Remove-Item -Recurse -Force $env:LOCALAPPDATA'\Google\Chrome\User Data\Default\GPUCache'
New-Item -ItemType Directory -Force -Path $env:LOCALAPPDATA'\Google\Chrome\User Data\Default\GPUCache'

Remove-Item -Recurse -Force $env:LOCALAPPDATA'\Google\Chrome\User Data\ShaderCache'
New-Item -ItemType Directory -Force -Path $env:LOCALAPPDATA'\Google\Chrome\User Data\ShaderCache'