#
# GitHub Dekstop setup script
# https://github.com/turboapps/turbome/tree/master/github/githubdesktop
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$page = Invoke-WebRequest -Uri https://desktop.github.com/
$link = ($page.Links.href | where {$_ -like "*win32"})[0]

if(!(Test-Path ".\installFiles")) { New-Item ".\installFiles" -type directory}

$path = ".\installFiles\install.exe"
(New-Object System.Net.WebClient).DownloadFile($link, $path)

$version = (Get-Item $path).VersionInfo.FileVersion

"github/githubdesktop:$version" | Set-Content "image.txt"