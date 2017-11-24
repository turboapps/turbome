#
# PowerBI install file
# https://github.com/turboapps/turbome/tree/master/microsoft/powerbi
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#Install PowerBI
& msiexec /i "X:\install\install.msi" /qn /norestart ACCEPT_EULA=1 DISABLE_UPDATE_NOTIFICATION=1 ENABLECXP=0 | Out-Null

#Disable settings in registry
$RegKey = "HKCU:\Software\Microsoft\Microsoft Power BI Desktop\"
Set-ItemProperty -Path $RegKey -Name ShowLeadGenDialog -Value 0


$mainExe = "$env:PROGRAMFILES\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
Write-Host "Version info"
(Get-Item $mainExe).VersionInfo
$version = (Get-Item $mainExe).VersionInfo.FileVersion
"microsoft/powerbi:$version" | Set-Content "X:\output\image.txt"
