#
# SBT snapshot setup file
# https://github.com/turboapps/turbome/tree/master/sbt
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$content = (Invoke-WebRequest -URI "http://www.scala-sbt.org/download.html").Content
$content -match '"(?<downloadlink>.*?sbt\-\d+\.(?<version>\d+\.\d+\.\d+).msi)"' | Out-Null
if (-not $Matches) {
    Write-Error "Failed to find SBT version"
    exit 1
}

$downloadlink = $Matches['downloadlink']
$tag = $Matches['version']
Write-Host "SBT version $tag"
"sbt/sbt:$tag" | Set-Content "image.txt"

$client = (New-Object System.Net.WebClient)
$client.DownloadFile($downloadlink, "install.msi")