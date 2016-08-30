#
# Python 2.7 post snapshot file
# https://github.com/turboapps/turbome/tree/master/python
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Import-Module Turbo

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

Remove-FileSystemDirectoryItems $xappl "@SYSDRIVE@\tmp"

$sysDriveNode = $Xappl.SelectSingleNode("Configuration/Layers/Layer[@name=`"Default`"]/Filesystem/Directory[@name=`"@SYSDRIVE@`"]")
$pythonNode = $sysDriveNode.ChildNodes | Where-Object { $_.name.StartsWith('Python') }
$version = $pythonNode.name

Set-EnvironmentVariable $xappl 'path' "C:\$version;C:\$version\scripts" 'Prepend' ';'
Set-EnvironmentVariable $xappl 'pythonhome' "C:\$version" 'Replace' '.'

Save-XAPPL $xappl $XappPath