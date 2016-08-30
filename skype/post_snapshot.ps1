#
# Skype post snapshot file
# https://github.com/turboapps/turbome/tree/master/skype
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Import-Module Turbo

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

$virtualizationSettings = $xappl.Configuration.VirtualizationSettings
$virtualizationSettings.httpUrlPassthrough = [string]$true

Remove-FileSystemDirectoryItems $xappl "@SYSDRIVE@\tmp"

Add-Route "ip://*.msads.net"
Add-Route "ip://*.rad.msn.com"
Add-Route "ip://a.config.skype.com"

Set-EnvironmentVariable $xappl 'path' "" 'Prepend' ';'
Set-EnvironmentVariable $xappl 'pathex' "" 'Prepend' ';'

Save-XAPPL $xappl $XappPath