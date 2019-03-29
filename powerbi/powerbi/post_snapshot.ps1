#
# Microsoft PowerBI post-snapshot script
# https://github.com/turboapps/turbome/tree/master/microsoft/powerbi
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Edit XAPPL
#

Import-Module Turbo

$XappPath = 'C:\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

$virtualizationSettings = $xappl.Configuration.VirtualizationSettings
$virtualizationSettings.httpUrlPassthrough = [string]$true

Add-Directory $xappl "@APPDATALOCAL@\Microsoft" -NoSync $True
Add-Directory $xappl "@APPDATALOCAL@\Microsoft\Power BI Desktop" -NoSync $False

Save-XAPPL $xappl $XappPath