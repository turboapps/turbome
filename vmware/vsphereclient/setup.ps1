#
# VMware vSphere Client setup script
# https://github.com/turboapps/turbome/tree/master/vmware/vsphereclient
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# Download Steam setup exe
$downloadUrl = 'http://vsphereclient.vmware.com/vsphereclient/3/0/1/6/4/4/7/VMware-viclient-all-6.0.0-3016447.exe'
(New-Object System.Net.WebClient).DownloadFile($downloadUrl, 'installer.exe')

# Get product version
# Steam may autoupdate during the first lauch,
# so the product product version should be extracted from installation directory
Import-Module Turbo
$version = Get-FileVersion installer.exe
Set-Content 'image.txt' "vmware/vsphereclient:$version"
