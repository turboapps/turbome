#
# Node install file
# https://github.com/turboapps/turbome/tree/master/node
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0


& msiexec /i C:\vagrant\install\install.msi /quiet | Write-Host

& "${env:ProgramFiles(x86)}\nodejs\npm.cmd" | Write-Host