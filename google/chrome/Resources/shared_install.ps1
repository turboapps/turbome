#
# Shared code for Chrome Enterprise installation
# https://github.com/turboapps/turbome/tree/master/google/chrome/resources
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$StartChromeTask = 'Start Chrome'
$CloseChromeTask = 'Close Chrome'
$PreferencesPath = "${env:USERPROFILE}\AppData\Local\Google\Chrome\User Data\Default\Preferences"

function Is-ScheduledTaskDefined ($taskName)
{
    return Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName}
}

function Is-ScheduledTaskRunning ($taskName)
{
	return Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName -and $_.State -like "Running"}
}

function Wait-ForScheduledTask ($taskName, $maxCount)
{
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

function Is-ChromeRunning()
{
    return (Get-Process | Where-Object {$_.Name -eq 'chrome'}) -ne $null
}

# Chrome running for the first time may show 'Welcome Dialog' which imports settings from another browser.
# Clicking 'Next' button in the dialog does not work in a container.
# To prevent showing 'Welcome Dialog' in container runs, we launch Chrome for the first time before taking 'after' snapshot.
# Chrome process has to be closed gracefully, otherwise crash notification may be presented in a container run.
# Scheduled tasks are used to lauch Chrome with user interface from WinRM session.
function Perform-FirstLaunch()
{
    Clean-ScheduledTasks
    try
    {
        $chromeExecutable = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
        $taskAction = New-ScheduledTaskAction -Execute $chromeExecutable
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
            Write-Error 'Failed to launch Chrome'
            Exit 1
        }
        
        $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("(Get-Process | Where-Object {`$_.Name -eq 'chrome' -and `$_.MainWindowTitle -ne ''}).CloseMainWindow()"))
        $taskAction = New-ScheduledTaskAction -Execute PowerShell.exe -Argument "-EncodedCommand $encodedCommand"
        Register-ScheduledTask -Action $taskAction -TaskName $CloseChromeTask | Out-Null
        
        $counter = 0
        while(($counter -lt 10) -and $isChromeRunning)
        {
            Sleep 5
            
            Start-ScheduledTask $CloseChromeTask
            Wait-ForScheduledTask $CloseChromeTask 60
            
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
        Clean-ScheduledTasks
    }
}

function Set-PreferenceCategoryProperty($filepath, $category, $property, $value)
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

function Set-PreferenceProperty($filepath, $property, $value)
{
    $json = (Get-Content $filepath) | ConvertFrom-Json

    $propertyValue = $json.PSobject.Properties | Where-Object {$_.Name -eq $property}
    if($propertyValue)
    {
        Add-Member -Name $property -Value $value -MemberType NoteProperty -InputObject $json.$property -Force
    }
    else
    {
        $json | Add-Member -Name $property -Value $value -MemberType NoteProperty
    }

    ConvertTo-Json $json -Compress | Set-Content $filepath
    return $true
}

function Remove-GoogleUpdate()
{
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
}

function Remove-Installer()
{
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
}

function Set-BasicFileAssoc()
{
    Write-Host 'Register basic associations'
    
    $chromeValue = 'ChromeHTML'
    $extensionRegKey = "HKLM:\Software\Classes\{0}"
    $extensions = @('.htm', '.html', '.shtml', '.webp', '.xht', '.xhtml')
    foreach($extension in $extensions)
    {
        $key = $extensionRegKey -f $extension
        Set-ItemProperty -path $key -name '(Default)' -value $chromeValue
    }
}

function Set-BasicPreferences()
{
    Write-Host "Overwriting default preferences"
    
    Set-PreferenceCategoryProperty $PreferencesPath 'browser' 'check_default_browser' $false | Out-Null
    Set-PreferenceCategoryProperty $PreferencesPath 'download' 'prompt_for_download' $true | Out-Null
    Set-PreferenceCategoryProperty $PreferencesPath 'download' 'directory_upgrade' $true | Out-Null
    Set-PreferenceCategoryProperty $PreferencesPath 'download' 'extensions_to_open' "" | Out-Null
}

function Set-ContentLanguage($language)
{
    Set-PreferenceCategoryProperty $PreferencesPath 'intl' 'accept_languages' "en-US,en,$language" | Out-Null
    Set-PreferenceCategoryProperty $PreferencesPath 'spellcheck' 'dictionaries' @("en-US",$language) | Out-Null
    Set-PreferenceProperty $PreferencesPath 'translate_blocked_languages' @($language) | Out-Null
}