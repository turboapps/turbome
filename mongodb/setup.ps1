#
# MongoDB setup script
# https://github.com/turboapps/turbome/tree/master/mongodb
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$page = Invoke-WebRequest -Uri "https://www.mongodb.com/download-center?jmp=nav#community"
$link = ( $page.Links.href -Match "signed.msi")[0]
$link = $link -replace "/dr/", "http://"
$link = $link -replace "/download$",""

$version = [regex]::match($link,'[0-9]+\.[0-9]+\.[0-9]+').Value

if(!(Test-Path ".\installFiles")) { New-Item ".\installFiles" -type directory}

(New-Object System.Net.WebClient).DownloadFile($link, ".\installFiles\install.msi")

"mongodb/mongo:$version" | Set-Content "image.txt"