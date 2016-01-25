#
# Cisco WebEx Meeting Center setup script
# https://github.com/turboapps/turbome/tree/master/webex/meetingcenter
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Import-Module Turbo
$version = (Get-LatestChocoVersion -Package webexff)
"webex/webex-meeting:$version" | Set-Content image.txt