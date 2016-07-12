#
# Viber setup script
# https://github.com/turboapps/turbome/tree/master/viber
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Import-Module Turbo

# Download Viber
(New-Object System.Net.WebClient).DownloadFile("http://download.cdn.viber.com/cdn/desktop/windows/ViberSetup.exe", "ViberSetup.exe")
$version = (Get-FileVersion -Path "ViberSetup.exe")
"viber/viber:$version" | Set-Content image.txt