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

$xapplText = Get-Content $XappPath -Raw
$xapplText = $xapplText -replace "<MachineSid />", "<MachineSid>S-1-5-21-992951991-166803189-1664049914</MachineSid>"
$xapplText | Out-File $XappPath -Encoding ascii

$xappl = Read-XAPPL $XappPath

$virtualizationSettings = $xappl.Configuration.VirtualizationSettings
$virtualizationSettings.httpUrlPassthrough = [string]$true

Add-Directory $xappl "@APPDATALOCAL@\Microsoft" -NoSync $True
Add-Directory $xappl "@APPDATALOCAL@\Microsoft\Power BI Desktop" -NoSync $False

Save-XAPPL $xappl $XappPath