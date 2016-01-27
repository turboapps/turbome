#
# Chromium Canary setup script
# https://github.com/turboapps/turbome/tree/master/chromium/canary
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$date = Get-Date -Format yyyyMMdd
"google/chromium-canary:$date" | Set-Content "image.txt"