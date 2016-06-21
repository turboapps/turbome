#
# TurboBase post-snapshot script
# https://github.com/turboapps/turbome/tree/master/turbobrowsers/turbobase
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Import-Module Turbo

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

Remove-Layer $xappl 'Xenocode'

Remove-FileSystemDirectoryItems $xappl '@SYSTEM@'

Remove-RegistryItems $xappl '@HKLM@\SYSTEM'
Remove-RegistryItems $xappl '@HKCU@\SOFTWARE\Microsoft'
Remove-RegistryItems $xappl '@HKLM@\SOFTWARE\Microsoft\TelemetryClient'

Set-RegistryIsolation $xappl "@HKCU@\SOFTWARE\Classes" $FullIsolation
Set-RegistryIsolation $xappl "@HKCU@\SOFTWARE\Clients" $FullIsolation
Set-RegistryIsolation $xappl "@HKLM@\SOFTWARE\Classes" $FullIsolation
Set-RegistryIsolation $xappl '@HKLM@\SOFTWARE\Microsoft\Windows' $FullIsolation
@("", "\Wow6432Node") | ForEach-Object {
    Set-RegistryIsolation $xappl "@HKLM@\SOFTWARE$_\Microsoft" $FullIsolation
    Set-RegistryIsolation $xappl "@HKLM@\SOFTWARE$_\Mozilla" $FullIsolation
    Set-RegistryIsolation $xappl "@HKLM@\SOFTWARE$_\mozilla.org" $FullIsolation
    Set-RegistryIsolation $xappl "@HKLM@\SOFTWARE$_\RegisteredApplications" $FullIsolation
}

Set-RegistryValue $xappl -Path '@HKLM@\SOFTWARE\Wow6432Node\Mozilla\Firefox\TaskBarIDs' -Key '@PROGRAMFILESX86@\Mozilla Firefox' -Value ''

Add-ObjectMap $xappl -Name 'Window://firefoxMessageWindow:firefoxMessageWindow'

Save-XAPPL $xappl $XappPath