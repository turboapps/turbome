#
# Cisco WebEx Meeting Center setup script
# https://github.com/turboapps/turbome/tree/master/turbobrowsers/webexmeetingcenter
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Import-Module Turbo
$version = (Get-NextTag "turbobrowsers/webexmeetings")
"turbobrowsers/webexmeetings:$version" | Set-Content image.txt