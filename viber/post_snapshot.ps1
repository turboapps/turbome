#
# Viber post-snapshot script
# https://github.com/turboapps/turbome/tree/master/viber
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Import-Module Turbo

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

Remove-Layer $xappl 'Xenocode'

Remove-FileSystemDirectoryItems $xappl '@SYSTEM@'
Remove-FileSystemDirectoryItems $xappl '@APPDATALOCAL@\Package Cache'
Remove-FileSystemDirectoryItems $xappl '@APPDATALOCALLOW@'

Remove-RegistryItems $xappl '@HKLM@\SYSTEM'
Remove-RegistryItems $xappl '@HKLM@\SOFTWARE\Microsoft\TelemetryClient'

Save-XAPPL $xappl $XappPath