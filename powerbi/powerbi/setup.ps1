#
# PowerBI snapshot setup file
# https://github.com/turboapps/turbome/tree/master/microsoft/powerbi
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

if(!(Test-Path ".\installFiles")) { New-Item ".\installFiles" -type directory}

$link = "https://download.microsoft.com/download/9/B/A/9BAEFFEF-1A68-4102-8CDF-5D28BFFE6A61/PBIDesktop_x64.msi"
(New-Object System.Net.WebClient).DownloadFile($link, ".\installFiles\install.msi")

if(Test-Path ".\image.txt") {Remove-Item ".\image.txt"}