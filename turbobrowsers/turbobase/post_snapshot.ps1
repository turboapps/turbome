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

Remove-RegistryKeyItems $xappl '@HKLM@\SYSTEM'
Remove-RegistryKeyItems $xappl '@HKCU@\SOFTWARE\Microsoft'
Remove-RegistryKeyItems $xappl '@HKLM@\SOFTWARE\Microsoft\TelemetryClient'

Set-RegistryKeyIsolation $xappl "@HKCU@\SOFTWARE\Classes" $FullIsolation
Set-RegistryKeyIsolation $xappl "@HKCU@\SOFTWARE\Clients" $FullIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\SOFTWARE\Classes" $FullIsolation
Set-RegistryKeyIsolation $xappl '@HKLM@\SOFTWARE\Microsoft\Windows' $FullIsolation
@("", "\Wow6432Node") | ForEach-Object {
    Set-RegistryKeyIsolation $xappl "@HKLM@\SOFTWARE$_\Microsoft" $FullIsolation
    Set-RegistryKeyIsolation $xappl "@HKLM@\SOFTWARE$_\Mozilla" $FullIsolation
    Set-RegistryKeyIsolation $xappl "@HKLM@\SOFTWARE$_\mozilla.org" $FullIsolation
    Set-RegistryKeyIsolation $xappl "@HKLM@\SOFTWARE$_\RegisteredApplications" $FullIsolation
}

Set-RegistryValue $xappl -KeyPath '@HKLM@\SOFTWARE\Wow6432Node\Mozilla\Firefox\TaskBarIDs' -ValueName '@PROGRAMFILESX86@\Mozilla Firefox' -Value ''

Add-ObjectMap $xappl -Name 'Window://firefoxMessageWindow:0'

Save-XAPPL $xappl $XappPath