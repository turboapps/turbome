#
# Java Runtime Environment install script
# https://github.com/turboapps/turbome/tree/master/java/jre
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Write-Host "Installing application"
Start-Process "C:\vagrant\install\installer.exe" /s -NoNewWindow -Wait

If (Test-Path c:\ProgramData\Oracle) {
  Remove-Item c:\ProgramData\Oracle -Force -Recurse
}