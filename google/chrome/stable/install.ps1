#
# Chrome Enterprise x86 installation file
# https://github.com/turboapps/turbome/tree/master/google/chrome/stable
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Import shared code
#
. X:\resources\shared_install.ps1
. X:\resources\shared_snapshot.ps1

#
# Installation for a single user
#
Write-Host "Installing application"
& msiexec /i "X:\install\install.msi" /qn ALLUSERS="2" MSIINTSTALLPERUSER="1" | Out-Null

(Get-Version "X:\install\install.msi") | Out-File "X:\install\version.txt"

Copy-Item 'X:\Resources\master_preferences_stable' "${env:PROGRAMFILES}\Google\Chrome\Application\master_preferences"
$chromeVersion = Get-Content "X:\install\version.txt"
$preferences = Get-Content "${env:PROGRAMFILES}\Google\Chrome\Application\master_preferences"
$preferences = $preferences -replace '#CHROME_VERSION#', $chromeVersion
$preferences | Set-Content "${env:PROGRAMFILES}\Google\Chrome\Application\master_preferences"

#
# Register basic file associations
#
Set-BasicFileAssoc

