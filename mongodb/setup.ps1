#
# MongoDB setup script
# https://github.com/turboapps/turbome/tree/master/mongodb
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$page = Invoke-WebRequest -Uri "https://www.mongodb.com/download-center/community?jmp=nav"
$page -match "\d+\.\d+\.\d+(?= \(current release\))" | Out-Null
$version = $Matches[0]
$page -match "https://fastdl.mongodb.org/win32[a-z0-9\.\/\-_]*$version\.zip" | Out-Null
$link = $Matches[0]
$link = $link -replace "\.zip", "-signed.msi"
Write-Host $link

if(!(Test-Path ".\installFiles")) { New-Item ".\installFiles" -type directory}

(New-Object System.Net.WebClient).DownloadFile($link, ".\installFiles\install.msi")

"mongodb/mongo:$version" | Set-Content "image.txt"