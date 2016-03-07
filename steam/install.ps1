#
# Steam install script
# https://github.com/turboapps/turbome/tree/master/steam
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# Intall Steam binaries
& C:\vagrant\install\installer.exe /S | Write-Host


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
    Write-Host -Verbose "Launching Steam for the first time"
    $launchProcessTask = 'Start Steam'
    Remove-ScheduledTask $launchProcessTask | Out-Null
    Start-ProcessInScheduledTask -TaskName $launchProcessTask -Path "C:\Program Files (x86)\Steam\steam.exe"
}
finally
{
    Remove-ScheduledTask $launchProcessTask | Out-Null
}


# Wait for Steam to update
Write-Output 'Waiting for Steam update to complete'
$SteamProcessName = 'Steam'
$SteamWebHelperProcessName = 'steamwebhelper'
$MaxRetry = 300

$steamWebHelperProcess = $null
$retry = 0
while((-not $steamWebHelperProcess) -and ($retry -lt $MaxRetry))
{
    $retry += 1

    Sleep -Seconds 1
    
    $steamWebHelperProcess = Get-Process -Name $SteamWebHelperProcessName -ErrorAction SilentlyContinue
}

if(-not $steamWebHelperProcess)
{
    throw "Failed to find $SteamWebHelperProcessName"
}

Stop-Process -Name $SteamProcessName -Force

function Ensure-Killed($processName)
{
    if(-not (Get-Process -Name $processName -ErrorAction SilentlyContinue))
    {
        throw "Failed to kill $processName"
    }
}

Ensure-Killed $SteamProcessName


# Get Steam version
$version = Get-FileVersion "${Env:ProgramFiles(x86)}\Steam\Steam.exe"
Write-Output "Steam version after update: $version"
Set-Content 'C:\vagrant\image.txt' "steam/steam:$version"