#
# PowerBI snapshot setup file
# https://github.com/turboapps/turbome/tree/master/microsoft/powerbi
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

if(!(Test-Path ".\installFiles")) { New-Item ".\installFiles" -type directory}

$website = Invoke-WebRequest -Uri https://powerbi.microsoft.com/en-us/desktop/
$item = $website.links | where {$_.innerText -like "*Download free*"}
$link = "https:" + $item[0].href
$link = $link -replace "amp;",""
Write-Host "Fixed link is: " + $link
(New-Object System.Net.WebClient).DownloadFile($link, ".\installFiles\install.msi")

if(Test-Path ".\image.txt") {Remove-Item ".\image.txt"}