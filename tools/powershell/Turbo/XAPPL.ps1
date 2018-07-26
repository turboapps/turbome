# Functions for XAPPL modifications
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# isolation string constants.
Set-Variable -Name FullIsolation -Option ReadOnly -Value 'Full'
Set-Variable -Name MergeIsolation -Option ReadOnly -Value 'Merge'
Set-Variable -Name WriteCopyIsolation -Option ReadOnly -Value 'WriteCopy'

# registry value types
Set-Variable -Name StringValueType -Option ReadOnly -Value 'String'
Set-Variable -Name StringArrayValueType -Option ReadOnly -Value 'StringArray'
Set-Variable -Name ExpandStringValueType -Option ReadOnly -Value 'ExpandString'
Set-Variable -Name DWORDValueType -Option ReadOnly -Value 'DWORD'
Set-Variable -Name QWORDValueType -Option ReadOnly -Value 'QWORD'
Set-Variable -Name BinaryValueType -Option ReadOnly -Value 'Binary'

<#
.Description
Adds an attribute to the specified node.
#>
function Add-Attribute($xappl, $element, $name, $value)
{
    $attribute = $Xappl.CreateAttribute($name)
    $attribute.Value = $value
    $element.Attributes.Append($attribute) | Out-Null
}

<#
.Description
Creates a case insensitive XPath attribute match since they are case sensitive by default.
#>
function EqualsIgnoreCase([string] $attribute, [string] $value)
{
    # convert all the upper case characters in the string to their lower case and then compare to lower case version
    $upperCaseValue = $value.ToUpper()
    $lowerCaseValue = $value.ToLower()
    return "translate($attribute,`"$upperCaseValue`",`"$lowerCaseValue`")=`"$lowerCaseValue`""
}

<#
.Description
Creates a case insensitive full xappl xpath for the given path.

.PARAMETER prefix
The xappl xpath prefix to be prepended to the generated xpath (ie. "Configuration/Layers/Layer[@name="Default"]/Filesystem" if we're talking about a filesystem path

.PARAMETER segmentName 
The xml node name of each segment of the $path (ie. "Directory" for "<Directory><Directory>...</Directory></Directory>" nodes. Assumes there is only one... which is valid for registry/filesystem paths. this says nothing about the name of the last node in the path (ie. so can select a "file" node).

.PARAMETER path
The friendly path to be processed into xpath format (ie. "@SYSTEM@\file.dll", assuming the prefix is as above).
#>
function Get-XPath($prefix, $segmentName, $path)
{
    $xpath = $prefix
    $segments = $path.Split("\")

    $lastIndex = $segments.length - 1
    for($index = 0; $index -lt $lastIndex; $index += 1)
    {
        $xpath += "/$segmentName[$(EqualsIgnoreCase "@name" "$($segments[$index])")]"
    }
    
    if($lastIndex -ge 0)
    {
        $xpath += "/*[$(EqualsIgnoreCase "@name" "$($segments[$index])")]"
    }

    return $xpath
}

<#
.Description
Returns the layer name from a path (ie. "mylayer" from "mylayer\@SYSTEM@\file.dll" or "default" for "@SYSTEM@\file.dll").
#>
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

<#
.Description
Removes the layer name from the path (ie. "mylayer\@SYSTEM@\file.dll" becomes "@SYSTEM@\file.dll")
#>
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

<#
.Description
Gets the xpath for a directory or file with the given path (ie. "mylayer\@SYSTEM@" or "@SYSTEM@\file.dll")
#>
function Get-FileSystemXPath($path)
{
    $layerName = Get-Layer $path
    return (Get-XPath "Configuration/Layers/Layer[@name=`"$layerName`"]/Filesystem" 'Directory' (Skip-Layer $path))
}

<#
.Description
Gets the xpath for a key or value with the given path (ie. "mylayer\@HKCU@\software" or "@HKLM@\SOFTWARE\Microsoft\.NETFramework\InstallRoot")
#>
function Get-RegistryXPath($path)
{
    $layerName = Get-Layer $path
    return (Get-XPath "Configuration/Layers/Layer[@name=`"$layerName`"]/Registry" 'Key' (Skip-Layer $path))
}

<#
.Description
Gets the xpath for a service in the DEFAULT layer.
#>
function Get-ServiceXPath($serviceName)
{
    return (Get-XPath "Configuration/Layers/Layer[@name=`"Default`"]/Services" 'Service' $serviceName )
}

<#
.Description
Load xappl as xml object from a path.
#>
function Read-XAPPL($filePath)
{
    $xappl = New-Object XML
    $xappl.Load($filePath)
    return $xappl
}

<#
.Description
Save xappl modifications to path.
#>
function Save-XAPPL($xappl, $filepath)
{
    $xappl.Save($filePath)
}

<#
.Description
Internal helper function to set the isolation for a directory.

.PARAMETER Recurse
Switch for whether to set the isolation on the entire node tree.

.PARAMETER RecurseDepth 
Set the depth of recursion (0 == only top level, 1 == top level and children, etc). Default is as deep as it can.
#>
function Set-DirectoryIsolationInternal
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
        [Parameter(Mandatory=$True,Position=4)]
        [int] $Depth,
        [Parameter(Mandatory=$True,Position=5)]
        [switch] $Recurse,
        [Parameter(Mandatory=$True,Position=6)]
        [int] $RecurseDepth
    )
    process
    {
        $xpath = Get-FileSystemXPath($Path)
        
        $node = $Xappl.SelectSingleNode($xpath)
        if($node)
        {
            $node.isolation = $Isolation
            
            if($Recurse -And $Depth -lt $RecurseDepth) 
            {
                $node.ChildNodes | ForEach-Object { 
                    if($_.LocalName -eq "Directory")
                    {
                        Set-DirectoryIsolationInternal $Xappl "$Path\$($_.name)" $Isolation ($Depth + 1) $Recurse $RecurseDepth
                    }
                }
            }
        }
        else
        {
            # create the object
            Add-Directory $Xappl $Path -Isolation $Isolation
        }
    }
}

<#
.Description
Set the isolation for a directory. valid isolation is "Merge", "Full", "WriteCopy".

.PARAMETER Recurse 
Switch for whether to set the isolation on the entire node tree.

.PARAMETER RecurseDepth 
Set the depth of recursion (0 == only top level, 1 == top level and children, etc). Default is as deep as it can.
#>
function Set-DirectoryIsolation
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
        [switch] $Recurse,
        [Parameter(Mandatory=$False)]
        [int] $RecurseDepth = $([int]::MaxValue)
    )
    process
    {
        Set-DirectoryIsolationInternal $Xappl $Path $Isolation 0 $Recurse $RecurseDepth
    }
}

<#
.Description
Internal helper fuinction to set the isolation for a registry key.

.PARAMETER Recurse 
Switch for whether to set the isolation on the entire node tree.

.PARAMETER RecurseDepth 
Set the depth of recursion (0 == only top level, 1 == top level and children, etc). Default is as deep as it can.

.PARAMETER IsKeyPath 
Whether the path points to a key or value.
#>
function Set-RegistryKeyIsolationInternal
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
        [XML] $Xappl,
        [Parameter(Mandatory=$True,Position=2)]
        [string] $Path,
        [Parameter(Mandatory=$True,Position=3)]
        [string] $Isolation = $FullIsolation,
        [Parameter(Mandatory=$True,Position=4)]
        [int] $Depth,
        [Parameter(Mandatory=$True,Position=5)]
        [switch] $Recurse,
        [Parameter(Mandatory=$True,Position=6)]
        [int] $RecurseDepth = $([int]::MaxValue)
    )
    process
    {
        $xpath = Get-RegistryXPath($Path)
        
        $node = $Xappl.SelectSingleNode($xpath)
        if($node)
        {
            $node.isolation = $Isolation
            
            if($Recurse -And $Depth -lt $RecurseDepth) 
            {
                $node.ChildNodes | ForEach-Object { 
                    if($_.LocalName -eq "Key")
                    {
                        Set-RegistryKeyIsolationInternal $Xappl "$Path\$($_.name)" $Isolation ($Depth + 1) $Recurse $RecurseDepth
                    }
                }
            }
        }
        else
        {
            # create the object
            Add-RegistryKey $Xappl $Path -Isolation $Isolation
        }
    }
}

<#
.Description
Set the isolation for a key. valid isolation is "Merge", "Full", "WriteCopy".

.PARAMETER Recurse 
Switch for whether to set the isolation on the entire node tree.

.PARAMETER RecurseDepth 
Set the depth of recursion (0 == only top level, 1 == top level and children, etc). Default is as deep as it can.
#>
function Set-RegistryKeyIsolation
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
        [switch] $Recurse,
        [Parameter(Mandatory=$False)]
        [int] $RecurseDepth = $([int]::MaxValue)
    )
    process
    {
        Set-RegistryKeyIsolationInternal $Xappl $Path $Isolation 0 $Recurse $RecurseDepth
    }
}

<#
.Description
Removes items from the specified directory, leaving the directory.
#>
function Remove-FileSystemDirectoryItems($xappl, $path)
{
    $xpath = Get-FileSystemXPath($path)
    $xappl.SelectNodes($xpath) | ForEach-Object {
        foreach($child in $_.SelectNodes("*")) {
            $_.RemoveChild($child) | Out-Null
        }
    }
}

<#
.Description
Removes the specified directory or file.
#>
function Remove-FileSystemItems($xappl, $path)
{
    $xpath = Get-FileSystemXPath $path
    $xappl.SelectNodes($xpath) | ForEach-Object { $_.ParentNode.RemoveChild($_) | Out-Null }
}

<#
.Description
Removes the specified registry or value.
#>
function Remove-RegistryItems($xappl, $path)
{
    $xpath = Get-RegistryXPath $path
    $xappl.SelectNodes($xpath) | ForEach-Object { $_.ParentNode.RemoveChild($_) | Out-Null } 
}

<#
.Description
Removes the specified service FROM THE DEFAULT LAYER.

todo: should support removing services from non-default layer.
#>
function Remove-Service($xappl, $service)
{
    $xpath = Get-ServiceXPath $service
    $serviceNode = $xappl.SelectSingleNode($xpath)
    if ($serviceNode -and $serviceNode.ParentNode)
    {
        $serviceNode.ParentNode.RemoveChild($serviceNode) | Out-Null
    }
}

<#
.Description
Sets the value on an existing registry value. Assumes that the value already exists and that the data type doesn't change.
#>
function Set-RegistryValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
        [XML] $Xappl,
        [Parameter(Mandatory=$True,Position=2)]
        [string] $KeyPath,
        [Parameter(Mandatory=$True,Position=3)]
        [string] $ValueName,
        [Parameter(Mandatory=$True,Position=4)]
        [AllowEmptyString()]
        [string] $Value,
        [Parameter(Mandatory=$False,Position=5)]
        [string] $ValueType=$StringValueType
    )
    process
    {
        # todo: fix for type=StringArray as it uses child nodes
        if($ValueType -eq $StringArrayValueType)
        {
            throw "StringArray value type not implemented"
        }

        $keyXPath = Get-RegistryXPath($KeyPath)
        $valueXPath = "$keyXPath/Value[@name=`"$ValueName`"]"
        $node = $xappl.SelectSingleNode($valueXPath)
        if($node)
        {
            $node.value = $Value
            $node.type = $ValueType
        }
        else
        {
            # value node doesn't exist so create it
            Add-RegistryKey $Xappl $KeyPath | Out-Null
            $key = $Xappl.SelectSingleNode($keyXPath)

            $node = $Xappl.CreateElement("Value")
            $key.AppendChild($node) | Out-Null
            
            Add-Attribute $Xappl $node "name" $ValueName
            Add-Attribute $Xappl $node "isolation" $FullIsolation
            Add-Attribute $Xappl $node "readOnly" $False
            Add-Attribute $Xappl $node "hide" $False
            Add-Attribute $Xappl $node "type" $ValueType
            Add-Attribute $Xappl $node "value" $Value
        }
    }
}

<#
.Description
Disables auto-start on all services in all layers.
#>
function Disable-Services($xappl)
{
    $xappl.SelectNodes("Configuration/Layers/Layer/Services/Service") | ForEach-Object { $_.start = "Disabled" }
}

<#
.Description
Creates a node in the xappl. If the key already exists then no changes will be made.

.PARAMETER xappl 
Xml object to add the node to.

.PARAMETER root 
The root xml node where the path segments are relative to

.PARAMETER segments 
Path segments of the node to create (ie. path split on '\').

.PARAMETER nodeSelector 
A function which returns the xpath based on a path. this is a little wonky as it doesn't take the root as a param so there are big assumptions about how these params are used together.

.PARAMETER nodeName 
The name of the xml node to create.

.PARAMETER attrs 
The element attributes to add to the new node.
#>
function Add-Node($Xappl, $root, $segments, $nodeSelector, $nodeName, $attrs)
{
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
            
            Add-Attribute $Xappl $node 'name' $segment       
            foreach($entry in $attrs.GetEnumerator())
            {
                Add-Attribute $Xappl $node $entry.key $entry.value   
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

<#
.Description
Add a registry key with the specified attributes. If the key already exists then no changes will be made.
Returns whether the key was added.
#>
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

<#
.Description
Add a directory with the specified attributes. If the directory already exists then no changes will be made.
Returns whether the directory was added.
#>
function Add-Directory
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
        [XML] $Xappl,
        [Parameter(Mandatory=$True,Position=2)]
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

<#
.Description
Updates a directory or file with the specified attributes. Passing empty value for the attribute empty will leave it unchanged.

NOTE: NoSync attribute only valid on a Directory
#>
function Set-FileSystemObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
        [XML] $Xappl,
        [Parameter(Mandatory=$True,Position=2)]
        [string] $Path,
        [Parameter(Mandatory=$False)]
        [string] $Isolation,
        [Parameter(Mandatory=$False)]
        [string] $ReadOnly,
        [Parameter(Mandatory=$False)]
        [string] $Hide,
        [Parameter(Mandatory=$False)]
        [string] $NoSync
    )
    process
    {
        $xpath = Get-FileSystemXPath($Path)        
        $node = $Xappl.SelectSingleNode($xpath)
        if($node)
        {
            if($Isolation -ne "") { $node.isolation = $Isolation }
            if($ReadOnly -ne "") { $node.readOnly = $ReadOnly }
            if($Hide -ne "") { $node.hide = $Hide }
            if($NoSync -ne "" -and $node.noSync) { $node.noSync = $NoSync }
        }
    }
}

<#
.Description
Updates a registry key or value with the specified attributes. Passing empty value for the attribute empty will leave it unchanged.

NOTE: NoSync attribute only valid on a key
#>
function Set-RegistryObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
        [XML] $Xappl,
        [Parameter(Mandatory=$True,Position=2)]
        [string] $Path,
        [Parameter(Mandatory=$False)]
        [string] $Isolation,
        [Parameter(Mandatory=$False)]
        [string] $ReadOnly,
        [Parameter(Mandatory=$False)]
        [string] $Hide,
        [Parameter(Mandatory=$False)]
        [string] $NoSync
    )
    process
    {
        $xpath = Get-RegistryXPath($Path)        
        $node = $Xappl.SelectSingleNode($xpath)
        if($node)
        {
            if($Isolation -ne "") { $node.isolation = $Isolation }
            if($ReadOnly -ne "") { $node.readOnly = $ReadOnly }
            if($Hide -ne "") { $node.hide = $Hide }
            if($NoSync -ne "" -and $node.noSync) { $node.noSync = $NoSync }
        }
    }
}

<#
.Description
Sets properties of standard metadata.
#>
function Set-StandardMetadata
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
        [XML] $Xappl,
        [Parameter(Mandatory=$True,Position=2)]
        [string] $PropertyName,
        [Parameter(Mandatory=$True,Position=3)]
        [string] $PropertyValue
    )
    process
    {
        $meta = $Xappl.SelectSingleNode("/Configuration/StandardMetadata");
        $xpath = "*[$(EqualsIgnoreCase `"@property`" `"$PropertyName`")]"
        $prop = $meta.SelectSingleNode($xpath)
        if($prop)
        {
            $prop.value = $PropertyValue
        }
        else
        {
            $prop = $Xappl.CreateElement("StandardMetadataItem")
            $meta.AppendChild($prop) | Out-Null
            
            Add-Attribute $Xappl $prop 'property' $PropertyName   
            Add-Attribute $Xappl $prop 'value' $PropertyValue
        }
    }
}
<#
.Description
Add a file with the specified attributes.
#>
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
        
        Add-Attribute $Xappl $fileElement 'name' $fileName
        Add-Attribute $Xappl $fileElement 'isolation' $Isolation
        Add-Attribute $Xappl $fileElement 'readOnly' $ReadOnly
        Add-Attribute $Xappl $fileElement 'hide' $Hide
        Add-Attribute $Xappl $fileElement 'upgradeable' $Upgradeable
        Add-Attribute $Xappl $fileElement 'source' $Source

        return $True
    }
}

<#
.Description
Add a startup file with the specified attributes.
#>
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
        
        Add-Attribute $Xappl $startupFile 'node' $File
        Add-Attribute $Xappl $startupFile 'tag' $Name

        if($CommandLine)
        {
            Add-Attribute $Xappl $startupFile 'commandLine' $CommandLine
        }

        if($AutoStart)
        {
            Add-Attribute $Xappl $startupFile 'default' 'True'
        }

        Add-Attribute $Xappl $startupFile 'architecture' $Architecture
    }
}

<#
.Description
Add an object map entry to DEFAULT layer with the specified attributes.
#>
function Add-ObjectMap
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
        [XML] $Xappl,
        [Parameter(Mandatory=$True)]
        [string] $Name
    )
    process
    {
        $objectMaps = $Xappl.SelectSingleNode("Configuration/Layers/Layer[@name='Default']/ObjectMaps")
        $objectMap = $Xappl.CreateElement('ObjectMap')
        $objectMaps.AppendChild($objectMap) | Out-Null

        $valueAttribute = $Xappl.CreateAttribute('value')
        $valueAttribute.Value = $Name
        $objectMap.Attributes.Append($valueAttribute) | Out-Null
    }
}

<#
.Description
Removes all startup files
#>
function Remove-StartupFiles($xappl)
{
    $xappl.SelectNodes('Configuration/StartupFiles/*') | ForEach-Object { $_.ParentNode.RemoveChild($_) | Out-Null }
}

<#
.Description
Removes the layer with the specified name.
#>
function Remove-Layer($xappl, $layer)
{
    $xappl.SelectNodes("Configuration/Layers/Layer[@name=`"$layer`"]") | ForEach-Object { $_.ParentNode.RemoveChild($_) | Out-Null }
}

<#
.Description
Copies the files in the specified directory to the snapshot directory path and adds to the xappl accordingly.
#>
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

<#
.Description
Renames a native ProgId to a virtual one in order not to collide with native links after SVM is installed.

.EXAMPLE
Rename-ProgId $xappl 'ChromeHTML' 'ChromeHTML-Virt' @()
#>
function Rename-ProgId
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True)]
        [xml] $Xappl,
        [Parameter(Mandatory=$True)]
        [string] $OldProgId,
        [Parameter(Mandatory=$True)]
        [string] $NewProgId,
        [Parameter(Mandatory=$False,HelpMessage="Array of file extensions to process prefixed by '.'. If null or empty all file extensions will be processed.")]
        [string[]] $FileAssoc = @()
    )
    process
    {
        function TryReplaceAssoc($element)
        {
            if($element -and $element.value -eq $OldProgId)
            {
                $element.value = $NewProgId
            }
        }

        $defaultLayer = $Xappl.SelectSingleNode('//Configuration/Layers/Layer[@name="Default"]')
        
        # Process XAPPL registry node
        $registry = $defaultLayer.SelectSingleNode('./Registry')

        # PRocess HKLM/SOFTWARE/Classes Hive
        $hklmSoftwareClassesNodes = $registry.SelectNodes("./Key[@name=`"@HKLM@`"]/Key[$(EqualsIgnoreCase "@name" "software")]/Key[$(EqualsIgnoreCase "@name" "classes")]/*")

        $hklmProgIdNode = $hklmSoftwareClassesNodes | Where { $_.name -eq $OldProgId } | Select -First 1
        if(-not $hklmProgIdNode)
        {
            throw "ProgId $OldProgId is not defined in @HKLM@/SOFTWARE/CLASSES"
        }
        $hklmProgIdNode.name = $NewProgId

        $extensionNodes = $hklmSoftwareClassesNodes | Where { $_.name.StartsWith('.') }
        if ($FileExtensions)
        {
            $extensionNodes = $extensionNodes | Where { $FileExtensions -contains $_.name }
        }

        foreach ($extensionNode in $extensionNodes)
        {
            $defaultProgramIdNode = $extensionNode.SelectSingleNode('./Value[@name=""]')
            TryReplaceAssoc $defaultProgramIdNode
    
            $openWithProgidsNode = $extensionNode.SelectSingleNode("./Key[$(EqualsIgnoreCase "@name" "openwithprogids")]")
            if(-not $openWithProgidsNode)
            {
                continue
            }
            
            $oldProgIdNode = $openWithProgidsNode.SelectSingleNode("./Value[@name=`"$OldProgId`"]")
            if($oldProgIdNode)
            {
                $oldProgIdNode.name = $NewProgId
            }
        }

        # Process HKLM/SOFTWARE/Clients Hive
        $fileAssocNodes = $registry.SelectNodes("./Key[@name=`"@HKLM@`"]/Key[$(EqualsIgnoreCase "@name" "software")]/descendant::Key[@name=`"FileAssociations`"]/*")
        $fileAssocNodes | ForEach { TryReplaceAssoc $_ }

        $urlAssocNodes = $registry.SelectNodes("./Key[@name=`"@HKLM@`"]/Key[$(EqualsIgnoreCase "@name" "software")]/descendant::Key[@name=`"URLAssociations`"]/*")
        $urlAssocNodes | ForEach { TryReplaceAssoc $_ }

        $hkcuProgIdNode = $registry.SelectSingleNode("./Key[@name=`"@HKCU@`"]/Key[$(EqualsIgnoreCase "@name" "software")]/Key[$(EqualsIgnoreCase "@name" "classes")]/Key[@name=`"$OldProgId`"]")
        if ($hkcuProgIdNode)
        {
           $hkcuProgIdNode.Name = $NewProgId 
        }

        # Process ProgIds XAPPL node
        $progIds = $defaultLayer.SelectNodes('./ProgIds/*')
        foreach ($progId in $progIds)
        {
            if ($progId.Name -eq $OldProgId)
            {
                $progId.Name = $NewProgId
            }
        }

        # Process Extensions node
        $extensions = $defaultLayer.SelectNodes('./Extensions/*')
        foreach ($extension in $extensions)
        {
            if ($extension.progId -eq $OldProgId)
            {
                $extension.progId = $NewProgId
            }
        }
    }
}

<#
.Description
Moves ProgId to the top of OpenWithProgIds list for all registered file associations so that it is used by default.
#>
function Set-DefaultProgId
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True)]
        [xml] $Xappl,
        [Parameter(Mandatory=$True)]
        [string] $ProgId
    )
    process
    {
        $fileAssocNodes = $Xappl.SelectNodes("//Configuration/Layers/Layer[@name='Default']/Registry/Key[@name='@HKLM@']/Key[$(EqualsIgnoreCase '@name' 'software')]/Key[$(EqualsIgnoreCase '@name' 'classes')]/*")
        foreach ($fileAssocNode in $fileAssocNodes)
        {
            $openWithProgIdsNode = $fileAssocNode.SelectSingleNode("./Key[$(EqualsIgnoreCase "@name" "OpenWithProgIds")]")
            if (-not $openWithProgIdsNode)
            {
                continue
            }

            $progIdNode = $openWithProgIdsNode.SelectSingleNode("./Value[@name=`"$ProgId`"]")
            if (-not $progIdNode)
            {
                continue
            }

            if ($openWithProgIdsNode.FirstChild.name -ne $ProgId)
            {
                $openWithProgIdsNode.RemoveChild($progIdNode) | Out-Null
                $openWithProgIdsNode.InsertBefore($progIdNode, $openWithProgIdsNode.FirstChild) | Out-Null
            }
        }
    }
}

<#
.Description
Creates or modifies an environment variable with the specified attributes.
#>
function Set-EnvironmentVariable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True)]
        [xml] $Xappl,
        [Parameter(Mandatory=$True)]
        [string] $Name,
        [Parameter(Mandatory=$True)]
        [string] $Value,
        [Parameter(Mandatory=$False)]
        [string] $MergeNode = 'Replace',
        [Parameter(Mandatory=$False)]
        [string] $MergeString = '.'
    )
    process
    {
        $environmentVariablesRootNode = $Xappl.SelectSingleNode("//Configuration/Layers/Layer[@name='Default']/EnvironmentVariablesEx")
        $environmentVariable = $environmentVariablesRootNode.SelectSingleNode("./VariableEx[$(EqualsIgnoreCase "@name" "$Name")]")
        if ($environmentVariable) {
            $environmentVariable.Attributes["value"].Value = $Value
        } else {
            $environmentVariable = $Xappl.CreateElement('VariableEx')
            $environmentVariablesRootNode.AppendChild($environmentVariable) | Out-Null
            
            Add-Attribute $Xappl $environmentVariable 'name' $Name
            Add-Attribute $Xappl $environmentVariable 'isolation' 'Inherit'
            Add-Attribute $Xappl $environmentVariable 'value' $Value
            Add-Attribute $Xappl $environmentVariable 'mergeMode' $MergeNode
            Add-Attribute $Xappl $environmentVariable 'mergeString' $MergeString
        }
    }
}

<#
.Description
Removes the environment variable with the specified name.
#>
function Remove-EnvironmentVariable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True)]
        [xml] $Xappl,
        [Parameter(Mandatory=$True)]
        [string] $Name
    )
    process
    {
        $environmentVariablesRootNode = $Xappl.SelectSingleNode("//Configuration/Layers/Layer[@name='Default']/EnvironmentVariablesEx")
        $environmentVariable = $environmentVariablesRootNode.SelectSingleNode("./VariableEx[$(EqualsIgnoreCase "@name" "$Name")]")
        if ($environmentVariable) {
            $environmentVariablesRootNode.RemoveChild($environmentVariable)
        } 
    }
}

<#
.Description
Adds a route ObjectMap entry.
#>
function Add-Route
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True)]
        [xml] $Xappl,
        [Parameter(Mandatory=$True)]
        [string] $Value
    )
    process
    {
        $objectMapsNode = $Xappl.SelectSingleNode("//Configuration/Layers/Layer[@name='Default']/ObjectMaps")
        $objectMap = $Xappl.CreateElement('ObjectMap')
        $objectMapsNode.AppendChild($objectMap)
        
        $attribute = $Xappl.CreateAttribute('value')
        $attribute.Value = $Value
        $objectMap.Attributes.Append($attribute) | Out-Null
    }
}

#
# specify exports
#
Export-ModuleMember -Function 'Add-Directory'
Export-ModuleMember -Function 'Add-File'
Export-ModuleMember -Function 'Add-ObjectMap'
Export-ModuleMember -Function 'Add-StartupFile'
Export-ModuleMember -Function 'Add-RegistryKey'
Export-ModuleMember -Function 'Add-Route'
Export-ModuleMember -Function 'Disable-Services'
Export-ModuleMember -Function 'Get-LatestChocoVersion'
Export-ModuleMember -Function 'Import-Files'
Export-ModuleMember -Function 'Read-XAPPL'
Export-ModuleMember -Function 'Remove-BuildTools'
Export-ModuleMember -Function 'Remove-EnvironmentVariable'
Export-ModuleMember -Function 'Remove-FileSystemDirectoryItems'
Export-ModuleMember -Function 'Remove-FileSystemItems'
Export-ModuleMember -Function 'Remove-Layer'
Export-ModuleMember -Function 'Rename-ProgId'
Export-ModuleMember -Function 'Remove-RegistryItems'
Export-ModuleMember -Function 'Remove-StartupFiles'
Export-ModuleMember -Function 'Remove-Service'
Export-ModuleMember -Function 'Save-XAPPL'
Export-ModuleMember -Function 'Set-DefaultProgId'
Export-ModuleMember -Function 'Set-EnvironmentVariable'
Export-ModuleMember -Function 'Set-DirectoryIsolation'
Export-ModuleMember -Function 'Set-RegistryKeyIsolation'
Export-ModuleMember -Function 'Set-RegistryValue'
Export-ModuleMember -Function 'Set-FileSystemObject'
Export-ModuleMember -Function 'Set-RegistryObject'
Export-ModuleMember -Function 'Set-StandardMetadata'

Export-ModuleMember -Variable FullIsolation
Export-ModuleMember -Variable WriteCopyIsolation
Export-ModuleMember -Variable MergeIsolation

Export-ModuleMember -Variable StringValueType
Export-ModuleMember -Variable StringArrayValueType
Export-ModuleMember -Variable ExpandStringValueType
Export-ModuleMember -Variable DWORDValueType
Export-ModuleMember -Variable QWORDValueType
Export-ModuleMember -Variable BinaryValueType