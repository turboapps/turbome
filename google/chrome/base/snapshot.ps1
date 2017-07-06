#
# Chrome Base x86 snapshot setup file
# https://github.com/turboapps/turbome/tree/master/google/chrome/base
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$rootDir = $(Get-Item $PSScriptRoot).Parent.FullName
. "$rootDir\Resources\shared_snapshot.ps1"

#Clean workspace
if(Test-Path ".\share") { Remove-Item ".\share" -Recurse -Force }
Remove-Item "*.svm", "*.png"

New-Item ".\share" -type directory
New-Item ".\share\install" -type directory
New-Item ".\share\tools" -type directory
New-Item ".\share\output" -type directory

$msiPath = ".\share\install\install.msi"

Download-Browser "$msiPath" 'en'
$tag = Get-Version "$msiPath"

Write-Host "Chrome Base version $tag"
"google/chrome-base:$tag" | Set-Content "image.txt"

# Silent install arguments: /quiet
