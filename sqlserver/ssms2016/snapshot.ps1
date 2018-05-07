#
# SQL Server Management Studio 2016 snapshot script
# https://github.com/turboapps/turbome/tree/master/sqlserver/ssms2016
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$page = Invoke-WebRequest -Uri "https://msdn.microsoft.com/en-us/library/mt238290.aspx"
$body = $page.ParsedHtml.getElementById("mainBody")
$hyperlinks = $body.getElementsByTagName("a")
$downloadLink = $hyperlinks | Select-Object -First 1

Write-Host "SQL Server Management Studio"
"sqlserver/ssms2016" | Set-Content "image.txt"

(New-Object System.Net.WebClient).DownloadFile($downloadLink.href,"install.exe")