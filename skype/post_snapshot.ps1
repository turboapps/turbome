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
$virtualizationSettings.shutdownProcessTree = [string]$true

Remove-FileSystemDirectoryItems $xappl "@SYSDRIVE@\tmp"

Add-Route $xappl "ip://*.msads.net"
Add-Route $xappl "ip://*.rad.msn.com"
Add-Route $xappl "ip://a.config.skype.com"

Remove-EnvironmentVariable $xappl 'path'
Remove-EnvironmentVariable $xappl 'pathex'

Save-XAPPL $xappl $XappPath
