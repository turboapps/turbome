#
# TeamViewer post-snapshot script
# https://github.com/turboapps/turbome/tree/master/teamviewer
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Edit XAPPL
#

Import-Module Turbo

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

Remove-RegistryItems $xappl "@HKCU@\Software\Microsoft"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Microsoft\TelemetryClient"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Wow6432Node\Apple Inc."

Disable-Services $xappl 

Save-XAPPL $xappl $XappPath