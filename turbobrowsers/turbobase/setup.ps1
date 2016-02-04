#
# TurboBase setup script
# https://github.com/turboapps/turbome/tree/master/turbobrowsers/turbobase
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# Download Firefox
(New-Object System.Net.WebClient).DownloadFile("https://download.mozilla.org/?product=firefox-latest&os=win&lang=en-US",
    "firefox.exe")