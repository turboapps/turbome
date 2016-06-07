#
# Chrome Base x86 snapshot setup file
# https://github.com/turboapps/turbome/tree/master/google/chrome/base
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

. .\Resources\shared_snapshot.ps1

Download-Browser 'install.msi'
$tag = Get-Version '.\install.msi'

Write-Host "Chrome Base version $tag"
"google/chrome-base:$tag" | Set-Content "image.txt"

# Silent install arguments: /quiet
