#
# Java Runtime Environment setup script
# https://github.com/turboapps/turbome/tree/master/java/jre
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$content = Invoke-WebRequest https://www.java.com/en/download/manual.jsp

$urlPattern = "<a title=`"Download Java software for Windows Offline`" href=`"(?<url>[a-zA-Z0-9._/?:=]+)`">"
$versionPattern = "Recommended Version (?<version>[\d]+) Update (?<update>[\d]+)"

$content -match $urlPattern | Out-Null
$DownloadLink = $Matches['url']
$content -match $versionPattern | Out-Null
$version = $Matches['version']+"."+$Matches['update']

(New-Object System.Net.WebClient).DownloadFile($DownloadLink,".\installer.exe")

"oracle/jre:"+$version | Set-Content 'image.txt'