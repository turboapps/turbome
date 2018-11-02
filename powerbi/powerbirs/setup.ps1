#
# PowerBI snapshot setup file
# https://github.com/turboapps/turbome/tree/master/microsoft/powerbi
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

if(!(Test-Path ".\installFiles")) { New-Item ".\installFiles" -type directory}

$link = "https://download.microsoft.com/download/5/B/C/5BC07A39-ED27-4073-8953-70DFDD41F89E/PBIDesktopRS_x64.msi"

(New-Object System.Net.WebClient).DownloadFile($link, ".\installFiles\install.msi")

if(Test-Path ".\image.txt") {Remove-Item ".\image.txt"}