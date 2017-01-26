#
# Chrome Base x86 installation file
# https://github.com/turboapps/turbome/tree/master/google/chrome/base
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Import shared code
#
. C:\vagrant\resources\shared_install.ps1


#
# Installation for a single user
#
Write-Host "Installing application"
& msiexec /i "C:\vagrant\install\install.msi" /qn ALLUSERS="2" MSIINTSTALLPERUSER="1" | Out-Null

Perform-FirstLaunch


#
# Remove unnecessary files
#
Remove-GoogleUpdate
Remove-Installer
Remove-CacheContent


#
# Overwrite default preferences
#
Set-BasicPreferences


#
# Register basic file associations
#
Set-BasicFileAssoc

