#
# Skype snapshot file
# https://github.com/turboapps/turbome/tree/master/skype
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

(New-Object System.Net.WebClient).DownloadFile("https://get.skype.com/go/getskype-windows", "install.exe")

Import-Module Turbo
$tag = Get-FileVersion "install.exe"
"microsoft/skype:$tag" | Set-Content "image.txt"