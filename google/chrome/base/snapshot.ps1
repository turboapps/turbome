#
# Chrome Base x86 snapshot setup file
# https://github.com/turboapps/turbome/tree/master/google/chrome/base
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$rootDir = $(Get-Item $PSScriptRoot).Parent.FullName
. "$rootDir\Resources\shared_snapshot.ps1"

$msiPath = ".\installFiles\install.msi"
if(!(Test-Path ".\installFiles")) { New-Item ".\installFiles" -type directory}

Download-Browser "$msiPath" 'en'
$tag = Get-Version "$msiPath"

Write-Host "Chrome Base version $tag"
"google/chrome-base:$tag" | Set-Content "image.txt"

# Silent install arguments: /quiet
