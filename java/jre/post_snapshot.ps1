#
# Java Runtime Environment post-snapshot script
# https://github.com/turboapps/turbome/tree/master/java/jre
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Edit XAPPL
#

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$content = Invoke-WebRequest https://www.java.com/en/download/manual.jsp
$versionPattern = "Recommended Version (?<version>[\d]+) Update (?<update>[\d]+)"

$content -match $versionPattern | Out-Null
$version = $Matches['version']
$update = $Matches['update']

Import-Module Turbo

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

Set-EnvironmentVariable $xappl 'path' "@PROGRAMFILESX86@\java\jre1.$version.0_$update\bin\"
Set-EnvironmentVariable $xappl 'JAVA_HOME' "@PROGRAMFILESX86@\java\jre1.$version.0_$update"


Set-RegistryIsolation $xappl "@HKLM@\Software\Microsoft\Windows\CurrentVersion\Installer\UserData" $MergeIsolation
Set-RegistryIsolation $xappl "@HKLM@\Software\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18" $MergeIsolation
Set-RegistryIsolation $xappl "@HKLM@\Software\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components" $MergeIsolation
Set-RegistryIsolation $xappl "@HKLM@\Software\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products" $MergeIsolation

Set-RegistryIsolation $xappl "@HKLM@\Software\Classes\Installer" $MergeIsolation
Set-RegistryIsolation $xappl "@HKLM@\Software\Classes\Installer\Features" $MergeIsolation
Set-RegistryIsolation $xappl "@HKLM@\Software\Classes\Installer\Products" $MergeIsolation
Set-RegistryIsolation $xappl "@HKLM@\Software\Classes\Installer\UpgradeCodes" $MergeIsolation

Remove-StartupFiles $xappl

Save-XAPPL $xappl $XappPath