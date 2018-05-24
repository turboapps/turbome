#
# MongoDB install script
# https://github.com/turboapps/turbome/tree/master/mongodb
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#Install
& msiexec /i "X:\install\install.msi" /qn /norestart INSTALLLOCATION="C:\MongoDB\" SHOULD_INSTALL_COMPASS="0" | Out-Null
