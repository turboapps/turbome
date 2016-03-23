#
# Dell PowerGUI setup script
# https://github.com/turboapps/turbome/tree/master/dell/powergui
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Import-Module Turbo
$version = (Get-NextTag "dell/powergui")
"dell/powergui:$version" | Set-Content image.txt
