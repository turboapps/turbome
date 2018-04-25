#
# MongoDB setup script
# https://github.com/turboapps/turbome/tree/master/mongodb
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$page = Invoke-WebRequest -Uri "https://www.mongodb.com/download-center?jmp=nav#community"
$link = "https://mongodb.com"+( $page.Links.href -Match "signed.msi")
$link = $link -replace "/dr/", "http://"
$link = $link -replace "/download$",""

$version = [regex]::match($link,'[0-9]+\.[0-9]+\.[0-9]+').Value

if(!(Test-Path ".\installFiles")) { New-Item ".\installFiles" -type directory}

(New-Object System.Net.WebClient).DownloadFile($link, ".\installFiles\install.msi")

"mongodb/mongo:$version" | Set-Content "image.txt"

https://fastdl.mongodb.org/win32/mongodb-win32-x86_64-2008plus-ssl-3.6.4-signed.msi
https://www.mongodb.com/dr/fastdl.mongodb.org/win32/mongodb-win32-x86_64-2008plus-ssl-3.6.4-signed.msi/download