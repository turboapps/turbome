#
# Chrome Enterprise x86 installation file
# https://github.com/turboapps/turbome/tree/master/google/chrome
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# Installation for a single user
Write-Host "Installing application"
& msiexec /i "C:\vagrant\install\install.msi" /qn ALLUSERS="2" MSIINTSTALLPERUSER="1" | Out-Null
# & msiexec /q /i "C:\vagrant\install\install.msi" | Out-Null

#Write-Host "Turning off auto update and default browser check"
#$SoftwarePoliciesPath = "Registry::HKLM\Software\Policies\Google"
#$SoftwareWOWPoliciesPath = "Registry::HKLM\Software\Wow6432Node\Policies\Google"

#function Create-PathIfNotExist($path)
#{
#    if(-not (Test-Path $path))
#    {
#        New-Item $path
#    }   
#}

# Turn off check if Chrome should be default browser, deactive autoupdates
#function Conifgure-Chrome($policyRoot)
#{
#    $UpdatePath = "$policyRoot\Update"
#    $ChromePath = "$policyRoot\Chrome"
#    
#    Create-PathIfNotExist $policyRoot
#    Create-PathIfNotExist $ChromePath
#    Create-PathIfNotExist $UpdatePath
    
#    New-ItemProperty -Path $ChromePath -PropertyType DWORD -Name DefaultBrowserSettingEnabled -Value 0 -Force
#    New-ItemProperty -Path $UpdatePath -PropertyType DWORD -Name AutoUpdateCheckPeriodMinutes -Value 0 -Force
#    New-ItemProperty -Path $UpdatePath -PropertyType DWORD -Name DisableAutoUpdateChecksCheckboxValue -Value 1 -Force
#    New-ItemProperty -Path $UpdatePath -PropertyType DWORD -Name "Update{8A69D345-D564-463C-AFF1-A69D9E530F96}" -Value 0 -Force
#    New-ItemProperty -Path $UpdatePath -PropertyType DWORD -Name UpdateDefault -Value 0 -Force
#}

#Conifgure-Chrome $SoftwarePoliciesPath
#Conifgure-Chrome $SoftwareWOWPoliciesPath


# Chrome running for the first time may show 'Welcome Dialog' which imports settings from another browser.
# Clicking 'Next' button in the dialog does not work in a container.
# To prevent showing 'Welcome Dialog' in container runs, we launch Chrome for the first time before taking 'after' snapshot.
# Chrome process has to be closed gracefully, otherwise crash notification may be presented in a container run.

function Get-ProcessWithMainWindow($processName)
{
    Write-Host (Get-Process | Where-Object {$_.Name -eq $processName} | Select-Object MainWindowHandle)
    return (Get-Process | Where-Object {$_.MainWindowTitle -ne '' -and $_.Name -eq $processName})
}

function Close-ProcessWithMainWindow($process)
{
    $counter = 0
    while($counter -lt 10)
    {
        $counter += 1
        try
        {
            $windowClosed = $process.CloseMainWindow()
            if($windowClosed)
            {
                Sleep 1
                $process.Refresh()
                if($process.HasExited)
                {
                    return $true
                }
            }
            else
            {
                Write-Warning "Failed to close ${process.Name} main window"
            }
        }
        catch
        {
            # CloseMainWindow may fail if process exited
            if($process.HasExited)
            {
                return $true
            }
        }
    }
   
    Write-Error "Process ${process.Name} left running"
    return $false
}

function Close-Eventually($processName)
{
    $counter = 0
    while($counter -lt 10)
    {
        $counter += 1
        Sleep 1
        $process = Get-ProcessWithMainWindow $processName
        if($process)
        {
            Write-Host "Found process " 
            return Close-ProcessWithMainWindow $process
        }
    }
    return $false
}

function Is-ScheduledTaskDefined ($taskName) {
    return Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName}
}

function Is-ScheduledTaskRunning ($taskName) {
	return Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName -and $_.State -like "Running"}
}

function Wait-ForScheduledTask ($taskName, $maxCount) {
    $isTaskRunning = $false
    $counter = 0
    do
    {
        Sleep 1
        $counter += 1
        $isTaskRunning = Is-ScheduledTaskRunning $taskName
    } while(($counter -lt $maxCount) -and $isTaskRunning)
    
    if($isTaskRunning)
    {
        Write-Error "$taskName did not complete"
    }
}

$StartChromeTask = 'Start Chrome'
$CloseChromeTask = 'Close Chrome'

function Clean-ScheduledTasks()
{
    if(Is-ScheduledTaskDefined $StartChromeTask)
    {
        Unregister-ScheduledTask $StartChromeTask -Confirm:$False
    }

    if(Is-ScheduledTaskDefined $CloseChromeTask)
    {
        Unregister-ScheduledTask $CloseChromeTask -Confirm:$False
    }
}

function Is-ChromeRunning() {
    return (Get-Process | Where-Object {$_.Name -eq 'chrome'}) -ne $null
}

Clean-ScheduledTasks
try
{
    $taskAction = New-ScheduledTaskAction -Execute 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
    Register-ScheduledTask -Action $taskAction -TaskName $StartChromeTask | Out-Null
    Start-ScheduledTask $StartChromeTask
    
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
        throw 'Failed to launch Chrome'
    }
    
    $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("(Get-Process | Where-Object {`$_.Name -eq 'chrome' -and `$_.MainWindowTitle -ne ''}).CloseMainWindow()"))
    $taskAction = New-ScheduledTaskAction -Execute PowerShell.exe -Argument "-EncodedCommand $encodedCommand"
    Register-ScheduledTask -Action $taskAction -TaskName $CloseChromeTask | Out-Null
    Start-ScheduledTask $CloseChromeTask
    
    Wait-ForScheduledTask $CloseChromeTask 60
    
    $counter = 0
    while(($counter -lt 10) -and $isChromeRunning)
    {
        Sleep 1
        $counter += 1
        $isChromeRunning = Is-ChromeRunning
    }
    if($isChromeRunning)
    {
        throw 'Failed to close Chrome'
    } else {
        Write-Host 'Closed Chrome correctly'
    }
}
finally
{
    Clean-ScheduledTasks
}

#
# Remove unnecessary files
#

Write-Host 'Removing Google Update'
$updateDir = 'C:\Program Files (X86)\Google\Update'
if(Test-Path $updateDir)
{
    Remove-Item $updateDir -Recurse -Force
}
else
{
    Write-Warning 'Failed to delete Google Update.'
}

$applicationDir = 'C:\Program Files (X86)\Google\Chrome\Application'
$versionDir = Get-ChildItem $applicationDir | Where-Object {$_.Name -Match '(?:\d+\.){3}\d+'}
if($versionDir)
{
    $installerDir = "$applicationDir\$versionDir\Installer"
    Write-Host 'Removing installer files'
    Get-ChildItem $installerDir | Remove-Item -Recurse -Force
}
else
{
    Write-Warning 'Failed to delete installer files. Output image may be too big.'
}

#
# Set preferences
#

function Set-PreferenceProperty($filepath, $category, $property, $value)
{
    $json = (Get-Content $filepath) | ConvertFrom-Json

    $categoryValue = $json.PSobject.Properties | Where-Object {$_.Name -eq $category}
    if($categoryValue)
    {
        Add-Member -Name $property -Value $value -MemberType NoteProperty -InputObject $json.$category -Force
    }
    else
    {
        $json | Add-Member -Name $category -Value @{ $property = $value } -MemberType NoteProperty
    }

    ConvertTo-Json $json -Compress | Set-Content $filepath
    return $true
}


$preferencesPath = "${env:USERPROFILE}\AppData\Local\Google\Chrome\User Data\Default\Preferences"

Set-PreferenceProperty $preferencesPath 'browser' 'check_default_browser' $false | Out-Null
Set-PreferenceProperty $preferencesPath 'download' 'prompt_for_download' $true | Out-Null
Set-PreferenceProperty $preferencesPath 'download' 'directory_upgrade' $true | Out-Null
Set-PreferenceProperty $preferencesPath 'download' 'extensions_to_open' "" | Out-Null
