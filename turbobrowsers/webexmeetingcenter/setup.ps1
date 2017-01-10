#
# Cisco WebEx Meeting Center setup script
# https://github.com/turboapps/turbome/tree/master/turbobrowsers/webexmeetingcenter
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$version = Get-Date -Format 'yyyy.M.dd'
"turbobrowsers/webex:$version" | Set-Content image.txt
