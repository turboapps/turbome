# WebEx Meeting Center
# Install Firefox
#
# https://github.com/turboapps/turbome/tree/master/webex/meetingcenter
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
& refreshenv
& choco install firefox --x86 --confirm
