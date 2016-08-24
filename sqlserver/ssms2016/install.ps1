#
# SQL Server Management Studio 2016 installation file
# https://github.com/turboapps/turbome/tree/master/sqlserver/ssms2016
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Installation for a single user
#
Write-Host "Installing application"
& "C:\vagrant\install\install.exe" /quiet /norestart | Out-Null