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

function Get-Layer($path)
{
    if($path.StartsWith('@'))
    {
        return 'Default'
    }

    $firstBackslashIndex = $path.IndexOf('\')
    if($firstBackslashIndex -eq -1)
    {
        return 'Default'
    }

    return $path.Substring(0, $firstBackslashIndex)
}

function Skip-Layer($path)
{
    if($path.StartsWith('@'))
    {
        return $path
    }

    $firstBackslashIndex = $path.IndexOf('\')
    if($firstBackslashIndex -eq -1)
    {
        return $path
    }
    if(($firstBackslashIndex + 1) -eq $path.Lenght)
    {
        throw "Path contains only layer name: $path"
    }

    return $path.Substring($firstBackslashIndex + 1)
}

function Get-FileSystemXPath($path)
{
    $layerName = Get-Layer $path
    return (Get-XPath "Configuration/Layers/Layer[@name=`"$layerName`"]/Filesystem" 'Directory' (Skip-Layer $path))
}

function Get-RegistryXPath($path)
{
    $layerName = Get-Layer $path
    return (Get-XPath "Configuration/Layers/Layer[@name=`"$layerName`"]/Registry" 'Key' (Skip-Layer $path))
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

function Remove-FileSystemItems($xappl, $path)
{
    $xpath = Get-FileSystemXPath $path
    $xappl.SelectNodes($xpath) | ForEach-Object { $_.ParentNode.RemoveChild($_) | Out-Null }
}

function Remove-RegistryItems($xappl, $path)
{
    $xpath = Get-RegistryXPath $path
    $xappl.SelectNodes($xpath) | ForEach-Object { $_.ParentNode.RemoveChild($_) | Out-Null } 
}

function Set-RegistryValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
	    [XML] $Xappl,
        [Parameter(Mandatory=$True,Position=2)]
        [string] $Path,
        [Parameter(Mandatory=$True,Position=3)]
        [string] $Key,
        [Parameter(Mandatory=$True,Position=4)]
        [AllowEmptyString()]
        [string] $Value
    )
    process
    {
        $propertyXPath = Get-RegistryXPath($path)
        $valueXPath = "$propertyXPath/Value[@name=`"$Key`"]"
        $xappl.SelectNodes($valueXPath) | ForEach-Object { $_.value = $Value }
    }
}

function Disable-Services($xappl)
{
    $xappl.SelectNodes("Configuration/Layers/Layer/Services/Service") | ForEach-Object { $_.autoStart = "false" }
}

function Add-Node($Xappl, $root, $segments, $nodeSelector, $nodeName, $attrs)
{
     function Add-Attribute($element, $name, $value)
     {
        $attribute = $Xappl.CreateAttribute($name)
        $attribute.Value = $value
        $element.Attributes.Append($attribute) | Out-Null
     }
     
     $result = $False
     $parent = $root
     $currentPath = ""
     foreach($segment in $segments)
     {
        $currentPath = [System.IO.Path]::Combine($currentPath, $segment)
        $xpath = & $nodeSelector $currentPath
        $node = $xappl.SelectSingleNode($xpath)
            
        if(-not $node)
        {
            $node = $Xappl.CreateElement($nodeName)
            $parent.AppendChild($node) | Out-Null
            
            Add-Attribute $node 'name' $segment       
            foreach($entry in $attrs.GetEnumerator())
            {
                Add-Attribute $node $entry.key $entry.value   
            }

            $parent = $node
            $result = $True
        }
        else
        {
            $parent = $node
        }
    }
    return $result
}

function Add-RegistryKey
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
	    [XML] $Xappl,
        [Parameter(Mandatory=$True,Position=2)]
        [string] $Path,
        [Parameter(Mandatory=$False,Position=3)]
        [string] $Isolation = $FullIsolation,
        [Parameter(Mandatory=$False)]
        [string] $ReadOnly = $False,
        [Parameter(Mandatory=$False)]
        [string] $Hide = "False",
        [Parameter(Mandatory=$False)]
        [string] $NoSync = $False
    )
    process
    {
        $layer = Get-Layer $Path
        $root = $Xappl.SelectSingleNode("Configuration/Layers/Layer[@name=`"$layer`"]/Registry")
        $segments = (Skip-Layer $Path).Split('\')
        $attrs = @{
            'isolation' = $Isolation;
            'readOnly' = $ReadOnly;
            'hide' = $Hide;
            'noSync' = $NoSync
        }
        
        return Add-Node $Xappl $root $segments Get-RegistryXPath 'Key' $attrs
    }
}

function Add-Directory
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
	    [XML] $Xappl,
        [Parameter(Mandatory=$True)]
        [string] $Path,
        [Parameter(Mandatory=$False)]
        [string] $Isolation = $FullIsolation,
        [Parameter(Mandatory=$False)]
        [string] $ReadOnly = $False,
        [Parameter(Mandatory=$False)]
        [string] $Hide = "False",
        [Parameter(Mandatory=$False)]
        [string] $NoSync = $False
    )
    process
    {
        $layer = Get-Layer $Path
        $root = $Xappl.SelectSingleNode("Configuration/Layers/Layer[@name=`"$layer`"]/Filesystem")
        $segments = (Skip-Layer $Path).Split('\')
        $attrs = @{
            'isolation' = $Isolation
            'readOnly' = $ReadOnly
            'hide' = $Hide
            'noSync' = $NoSync
        }
        
        return Add-Node $Xappl $root $segments Get-FileSystemXPath 'Directory' $attrs
    }
}

function Add-File
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
	    [XML] $Xappl,
        [Parameter(Mandatory=$True)]
        [string] $Path,
        [Parameter(Mandatory=$False)]
        [string] $Isolation = $FullIsolation,
        [Parameter(Mandatory=$False)]
        [string] $ReadOnly = $False,
        [Parameter(Mandatory=$False)]
        [string] $Hide = $False,
        [Parameter(Mandatory=$False)]
        [string] $Upgradeable = $True,
        [Parameter(Mandatory=$False)]
        [string] $Source = $null
    )
    process
    {
        if(!$Source)
        {
            $Source = ".\Files\$Path"
        }

        $fileXPath = (Get-FileSystemXPath $Path)
        $fileNode = $xappl.SelectSingleNode($fileXPath)
        if($fileNode) {
            return $False
        }

        $lastBackslashPosition = $Path.LastIndexOf('\')
        if($lastBackslashPosition -eq -1)
        {
            throw "Path must include directory: $Path"
        }
        if($Path.EndsWith('\')) {
            throw "Path must not end with '\': $Path"
        }

        $fileName = $Path.SubString($lastBackslashPosition + 1)
        $parentDirPath = $Path.SubString(0, $lastBackslashPosition)

        $parentDirXPath = (Get-FileSystemXPath $parentDirPath)
        $parentDir = $Xappl.SelectSingleNode($parentDirXPath)
        if(-not $parentDir)
        {
            Add-Directory $Xappl -Path $parentDirPath
            $parentDir = $Xappl.SelectSingleNode($parentDirXPath)
        }

        if(-not $parentDir) {
            throw "Parent directory does not exist: $parentDirPath"
        }


        $fileElement = $Xappl.CreateElement('File')
        $parentDir.AppendChild($fileElement) | Out-Null

        function Add-Attribute($name, $value)
        {
            $attribute = $Xappl.CreateAttribute($name)
            $attribute.Value = $value
            $fileElement.Attributes.Append($attribute) | Out-Null
        }

        Add-Attribute 'name' $fileName
        Add-Attribute 'isolation' $Isolation
        Add-Attribute 'readOnly' $ReadOnly
        Add-Attribute 'hide' $Hide
        Add-Attribute 'upgradeable' $Upgradeable
        Add-Attribute 'source' $Source

        return $True
    }
}

function Add-StartupFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
	    [XML] $Xappl,
        [Parameter(Mandatory=$True)]
        [string] $File,
        [Parameter(Mandatory=$False)]
        [string] $CommandLine = $null,
        [Parameter(Mandatory=$False)]
        [string] $Architecture = "AnyCpu",
        [Parameter(Mandatory=$False)]
        [string] $Name = $null,
        [Parameter(Mandatory=$False)]
        [switch] $Autostart = $False
    )
    process
    {
        $startupFileGroup = $xappl.SelectSingleNode('Configuration/StartupFiles')

        $startupFile = $Xappl.CreateElement('StartupFile')
        $startupFileGroup.AppendChild($startupFile) | Out-Null

        function Add-Attribute($name, $value) {
            $attribute = $Xappl.CreateAttribute($name)
            $attribute.Value = $value
            $startupFile.Attributes.Append($attribute) | Out-Null
        }

        Add-Attribute 'node' $File
        Add-Attribute 'tag' $Name

        if($CommandLine)
        {
            Add-Attribute 'commandLine' $CommandLine
        }

        if($AutoStart)
        {
            Add-Attribute 'default' 'True'
        }

        Add-Attribute 'architecture' $Architecture
    }
}

function Remove-StartupFiles($xappl)
{
    $xappl.SelectNodes('Configuration/StartupFiles/*') | ForEach-Object { $_.ParentNode.RemoveChild($_) | Out-Null }
}

function Remove-Layer($xappl, $layer)
{
    $xappl.SelectNodes("Configuration/Layers/Layer[@name=`"$layer`"]") | ForEach-Object { $_.ParentNode.RemoveChild($_) | Out-Null }
}

function Import-Files
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
	    [XML] $Xappl,
        [Parameter(Mandatory=$True)]
        [string] $SnapshotDir,
        [Parameter(Mandatory=$True)]
        [string] $SourceDir = $null
    )
    process
    {
        $snapshotDirPath = (Get-Item $SnapshotDir).FullName
        $sourceDirPath = (Get-Item $SourceDir).FullName

        Copy-Item "$sourceDirPath\*" $snapshotDirPath -Recurse -Force

        $sourceFiles = (Get-ChildItem $SourceDir -Recurse | Where {!$_.PSIsContainer})
        foreach($file in $sourceFiles)
        {
            $fileSourcePath = $file.FullName
            $fileRelativePath = $fileSourcePath.Replace("$sourceDirPath\", "") 
            Add-File $Xappl -Path $fileRelativePath
        }
    }
}

Export-ModuleMember -Function 'Add-RegistryKey'
Export-ModuleMember -Function 'Add-Directory'
Export-ModuleMember -Function 'Add-File'
Export-ModuleMember -Function 'Add-StartupFile'
Export-ModuleMember -Function 'Disable-Services'
Export-ModuleMember -Function 'Get-LatestChocoVersion'
Export-ModuleMember -Function 'Import-Files'
Export-ModuleMember -Function 'Read-XAPPL'
Export-ModuleMember -Function 'Remove-BuildTools'
Export-ModuleMember -Function 'Remove-FileSystemDirectoryItems'
Export-ModuleMember -Function 'Remove-FileSystemItems'
Export-ModuleMember -Function 'Remove-Layer'
Export-ModuleMember -Function 'Remove-StartupFiles'
Export-ModuleMember -Function 'Remove-RegistryItems'
Export-ModuleMember -Function 'Set-RegistryIsolation'
Export-ModuleMember -Function 'Set-RegistryValue'
Export-ModuleMember -Function 'Set-FileSystemIsolation'
Export-ModuleMember -Function 'Save-XAPPL'

Export-ModuleMember -Variable FullIsolation
Export-ModuleMember -Variable MergeIsolation