#
# Chromium Canary post-snapshot script
# https://github.com/turboapps/turbome/tree/master/chromium/canary
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
$virtualizationSettings.isolateWindowClasses = [string]$true
$virtualizationSettings.launchChildProcsAsUser = [string]$true

Set-RegistryIsolation $xappl "@HKLM@\System" $FullIsolation
Set-RegistryIsolation $xappl "@HKLM@\Software" $FullIsolation

Remove-RegistryItems $xappl "@HKCU@\Software\Microsoft"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Wow6432Node\Microsoft"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Microsoft"

Remove-StartupFiles $xappl
Add-StartupFile $xappl -File "@SYSDRIVE@\Chromium\chrome-win32\chrome.exe" -AutoStart

Save-XAPPL $xappl $XappPath