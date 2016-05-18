#
# TeamViewer pre-install script
# https://github.com/turboapps/turbome/tree/master/teamviewer
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# Install Chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
& refreshenv
