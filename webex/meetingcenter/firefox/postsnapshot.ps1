# WebEx Meeting Center
# Edit XAPPL
#
# https://github.com/turboapps/turbome/tree/master/webex/meetingcenter
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Import-Module Turbo

$XappPath = '..\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

Set-FileSystemIsolation $xappl '@PROGRAMFILESX86@\Mozilla Firefox' $FullIsolation

Set-RegistryIsolation $xappl '@HKCU@\Software\Microsoft' $FullIsolation
Set-RegistryIsolation $xappl '@HKLM@\SOFTWARE\Microsoft' $FullIsolation
Set-RegistryIsolation $xappl '@HKLM@\SOFTWARE\Wow6432Node\Microsoft' $FullIsolation

Remove-FileSystemItems $xappl '@APPDATACOMMON@\chocolatey'
Remove-FileSystemItems $xappl '@APPDATALOCAL@\NuGet'
Remove-FileSystemItems $xappl '@APPDATALOCALLOW@\Microsoft'
Remove-FileSystemItems $xappl '@SYSTEM@\CodeIntegrity'
Remove-FileSystemDirectoryItems $xappl '@SYSDRIVE@'

Save-XAPPL $xappl $XappPath