#
# TeamViewer setup script
# https://github.com/turboapps/turbome/tree/master/teamviewer
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Import-Module Turbo
$version = (Get-LatestChocoVersion -Package teamviewer)
"teamviewer/teamviewer:$version" | Set-Content image.txt