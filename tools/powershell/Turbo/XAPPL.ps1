# Functions for XAPPL modifications
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Get-XPath($prefix, $segmentName, $path)
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
    return (Get-XPath 'Configuration/Layers/Layer/Filesystem' 'Directory' $path)
}

function Get-RegistryXPath($path)
{
    return (Get-XPath 'Configuration/Layers/Layer/Registry' 'Key' $path)
}

Set-Variable -Name FullIsolation -Option ReadOnly -Value 'Full'
Set-Variable -Name MergeIsolation -Option ReadOnly -Value 'Merge'

function Read-XAPPL($filePath)
{
    $xappl = New-Object XML
    $xappl.Load($filePath)
    return $xappl
}

function Save-XAPPL($xappl, $filepath)
{
    $xappl.Save($filePath)
}

function Set-FileSystemIsolation($xappl, $path, $isolationMode)
{
    $xpath = Get-FileSystemXPath($path)
    $xappl.SelectNodes($xpath) | ForEach-Object { $_.isolation = $isolationMode }
}

function Set-RegistryIsolation($xappl, $path, $isolationMode)
{
    $xpath = Get-RegistryXPath($path)
    $xappl.SelectNodes($xpath) | ForEach-Object { $_.isolation = $isolationMode }
}

function Remove-FileSystemDirectoryItems($xappl, $path)
{
    $xpath = Get-FileSystemXPath($path)
    $xappl.SelectNodes($xpath) | ForEach-Object {
        foreach($child in $_.SelectNodes("*")) {
            $_.RemoveChild($child) | Out-Null
        }
    }
}

function Remove-RegistryItems($xappl, $path)
{
    $xpath = Get-RegistryXPath $path
    $xappl.SelectNodes($xpath) | ForEach-Object { $_.ParentNode.RemoveChild($_) | Out-Null } 
}

function Disable-Services($xappl)
{
    $xappl.SelectNodes("Configuration/Layers/Layer/Services/Service") | ForEach-Object { $_.autoStart = "false" }
}

Export-ModuleMember -Function 'Disable-Services'
Export-ModuleMember -Function 'Get-LatestChocoVersion'
Export-ModuleMember -Function 'Read-XAPPL'
Export-ModuleMember -Function 'Remove-BuildTools'
Export-ModuleMember -Function 'Remove-FileSystemDirectoryItems'
Export-ModuleMember -Function 'Remove-RegistryItems'
Export-ModuleMember -Function 'Set-RegistryIsolation'
Export-ModuleMember -Function 'Set-FileSystemIsolation'
Export-ModuleMember -Function 'Save-XAPPL'

Export-ModuleMember -Variable FullIsolation
Export-ModuleMember -Variable MergeIsolation