#
# Chrome Enterprise x86 post install script
# https://github.com/turboapps/turbome/tree/master/google/chrome
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$XappPath = '.\output\Snapshot.xappl'
$xappl = New-Object XML
$xappl.Load($XappPath)

$Isolation = [PSCustomObject]@{
    Full = 'Full'
    Merge = 'Merge'
}

function Create-XPath($prefix, $segmentName, $path)
{
    $xpath = $prefix
    $segments = $path.Split("\")

    $lastIndex = $segments.length - 1
    for($index = 0; $index -lt $lastIndex; $index += 1)
    {
        $xpath += "/$segmentName[@name=`"$($segments[$index])`"]"
    }
    
    if($lastIndex -ge 0)
    {
        $xpath += "/*[@name=`"$($segments[$lastIndex])`"]"
    }

    return $xpath
}

function Get-FileSystemXPath($path)
{
    return (Create-XPath 'Configuration/Layers/Layer/Filesystem' 'Directory' $path)
}

function Get-RegistryXPath($path)
{
    return (Create-XPath 'Configuration/Layers/Layer/Registry' 'Key' $path)
}

function Set-FileSystemIsolation($path, $isolationMode)
{
    $xpath = Get-FileSystemXPath($path)
    $xappl.SelectNodes($xpath) | ForEach-Object { $_.isolation = $isolationMode }
}

function Set-RegistryIsolation($path, $isolationMode)
{
    $xpath = Get-RegistryXPath($path)
    $xappl.SelectNodes($xpath) | ForEach-Object { $_.isolation = $isolationMode }
}

function Delete-FileSystemDirectoryItems($path)
{
    $xpath = Get-FileSystemXPath($path)
    $xappl.SelectNodes($xpath) | ForEach-Object {
        foreach($child in $_.SelectNodes("*")) {
            $_.RemoveChild($child) | Out-Null
        }
    }
}

function Delete-RegistryItems($path)
{
    $xpath = Get-RegistryXPath $path
    $xappl.SelectNodes($xpath) | ForEach-Object { $_.ParentNode.RemoveChild($_) | Out-Null } 
}

function TurnOff-Services()
{
    $xappl.SelectNodes("Configuration/Layers/Layer/Services/Service") | ForEach-Object { $_.autoStart = "false" }
}

#
# Edit XAPPL
#

$virtualizationSettings = $xappl.Configuration.VirtualizationSettings
$virtualizationSettings.isolateWindowClasses = [string]$true
$virtualizationSettings.launchChildProcsAsUser = [string]$true

Set-FileSystemIsolation "@APPDATACOMMON@\Microsoft" $Isolation.Full
Set-FileSystemIsolation "@APPDATALOCAL@\Google" $Isolation.Full
Set-FileSystemIsolation "@PROGRAMFILESX86@\Google" $Isolation.Full

Delete-FileSystemDirectoryItems "@SYSDRIVE@"

Set-RegistryIsolation "@HKCU@\Software\Google" $Isolation.Full
Set-RegistryIsolation "@HKLM@\SOFTWARE\Wow6432Node\Google" $Isolation.Full

Delete-RegistryItems "@HKCU@\Software\Microsoft"
Delete-RegistryItems "@HKLM@\SOFTWARE\Wow6432Node\Microsoft"
Delete-RegistryItems "@HKLM@\SOFTWARE\Microsoft"

TurnOff-Services

$xappl.Save($XappPath)