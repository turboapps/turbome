#
# Earth Pro snapshot setup file
# https://github.com/turboapps/turbome/tree/master/google/earthpro
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

if(!(Test-Path ".\installFiles")) { New-Item ".\installFiles" -type directory}

$downloadPath = "https://dl.google.com/earth/client/advanced/current/GoogleEarthProWin.exe"
(New-Object System.Net.WebClient).DownloadFile($downloadPath,".\installFiles\install.exe")

Write-Host "Chrome Base version $tag"

if(Test-Path ".\image.txt") {Remove-Item ".\image.txt"}
