#
# GitHub Dekstop post snapshot script
# https://github.com/turboapps/turbome/tree/master/github/githubdesktop
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Edit XAPPL
#

Import-Module Turbo

$XappPath = 'C:\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

Remove-StartupFiles $xappl
Add-StartupFile $xappl -File "@APPDATALOCAL@\GitHubDesktop\GitHubDesktop.exe" -AutoStart

Set-VirtualizationSetting($xappl, "chromiumSupport", "True")

Save-XAPPL $xappl $XappPath
