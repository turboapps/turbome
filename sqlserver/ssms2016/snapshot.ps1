#
# SQL Server Management Studio 2016 snapshot script
# https://github.com/turboapps/turbome/tree/master/sqlserver/ssms2016
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$page = Invoke-WebRequest -Uri "https://msdn.microsoft.com/en-us/library/mt238290.aspx"
$body = $page.ParsedHtml.getElementById("mainBody")
$hyperlinks = $body.getElementsByTagName("a")
$downloadLink = $hyperlinks | Select-Object -First 1

if(-not ($downloadLink.outerText -match "\d+(\.\d+)*"))
{
    throw "Failed to extract version number"
}
$tag = $Matches[0]

Write-Host "SQL Server Management Studio version $tag"
"sqlserver/ssms2016:$tag" | Set-Content "image.txt"

(New-Object System.Net.WebClient).DownloadFile($downloadLink.href,"install.exe")