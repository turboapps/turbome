#
# Chromium Canary install script
# https://github.com/turboapps/turbome/tree/master/chromium/canary
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Is-ChromeRunning()
{
    return (Get-Process | Where-Object {$_.Name -eq 'chrome'}) -ne $null
}

# Download Canary binaries
(New-Object System.Net.WebClient).DownloadFile(
    "https://download-chromium.appspot.com/dl/Win?type=snapshots",
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
        $chromeExecutable = "C:\Chromium\chrome-win32\chrome.exe"
        Start-Process $chromeExecutable

        $counter = 0
        $isChromeRunning = $false
        while(($counter -lt 10) -and !$isChromeRunning)
        {
            Sleep 5
            $counter += 1
            $isChromeRunning = Is-ChromeRunning
        }

        if($isChromeRunning) {
            Write-Host 'Chrome launched for the first time'
        }
        else
        {
            Write-Error 'Failed to launch Chrome'
            Exit 1
        }

		(Get-Process | Where-Object {$_.Name -eq 'chrome' -and $_.MainWindowTitle -ne ''}).CloseMainWindow() | Out-Null

        $counter = 0
        while(($counter -lt 10) -and $isChromeRunning)
        {
            Sleep 5
            $counter += 1
            $isChromeRunning = Is-ChromeRunning
        }
        if($isChromeRunning)
        {
            Write-Error 'Failed to close Chrome'
            Exit 1
        } else {
            Write-Host 'Closed Chrome correctly'
        }
    }
    finally
    {
    }

# Set preferences
Write-Host "Overwriting default preferences"
$preferencesPath = "${env:LOCALAPPDATA}\Chromium\User Data\Default\Preferences"

Set-JsonPreference -Path  $preferencesPath -Category 'browser' -Property 'check_default_browser' -Value $false | Out-Null
Set-JsonPreference -Path  $preferencesPath -Category 'browser' -Property 'should_reset_check_default_browser' -Value $false | Out-Null
Set-JsonPreference -Path  $preferencesPath -Category 'download' -Property 'prompt_for_download' -Value $true | Out-Null
Set-JsonPreference -Path  $preferencesPath -Category 'download' -Property 'directory_upgrade' -Value $true | Out-Null
Set-JsonPreference -Path  $preferencesPath -Category 'download' -Property 'extensions_to_open' -Value "" | Out-Null