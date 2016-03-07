#
# Steam setup script
# https://github.com/turboapps/turbome/tree/master/steam
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# Download Steam setup exe
$downloadUrl = 'https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe'
(New-Object System.Net.WebClient).DownloadFile($downloadUrl, 'installer.exe')

# Get product version
# Steam may autoupdate during the first lauch,
# so the product product version should be extracted from installation directory
Import-Module Turbo
$version = Get-FileVersion installer.exe
Set-Content 'image.txt' "steam/steam:$version"
