#
# Chromium Canary post-snapshot script
# https://github.com/turboapps/turbome/tree/master/chromium/canary
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Edit XAPPL
#

$content = Invoke-WebRequest https://www.java.com/en/download/manual.jsp
$versionPattern = "Recommended Version (?<version>[\d]+) Update (?<update>[\d]+)"

$content -match $versionPattern | Out-Null
$version = $Matches['version']
$update = $Matches['update']

Import-Module Turbo

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

Set-EnvironmentVariable $xappl 'path' "@PROGRAMFILESX86@\java\jre1.$version.0_$update\bin\"
Set-EnvironmentVariable $xappl 'JAVA_HOME' "@PROGRAMFILESX86@\java\jre1.$version.0_$update"

Remove-StartupFiles $xappl

Save-XAPPL $xappl $XappPath