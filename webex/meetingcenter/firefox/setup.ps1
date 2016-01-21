# WebEx Meeting Center
# Get WebEx image name
#
# https://github.com/turboapps/turbome/tree/master/webex/meetingcenter
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Import-Module Turbo
(Get-LatestChocoVersion -Package webexff) > test.txt
$version = (Get-LatestChocoVersion -Package webexff)
"webex/meetingcenter:$version" | Set-Content image.txt