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

#Disable stylus and touch support
# This is because there were some issues with Power BI's ribbon UI hanging and there was a PenIMC.dll-related exception.
# We downgraded .NET to 4.6.1 on the RDP servers suspecting it was the same issue as
# https://developercommunity.visualstudio.com/content/problem/55303/visual-studio-may-terminate-unexpectedly-when-runn.html
# but better be safe than sorry and also disable touch support in the app itself.

$exeConfigPath = "$env:programfiles\Microsoft Power BI Desktop\bin\PBIDesktop.exe.config"
$exeConfig = Get-Content $exeConfigPath -Raw
$oldString = '<runtime>'
$newString = '<runtime>
    <AppContextSwitchOverrides value="Switch.System.Windows.Input.Stylus.DisableStylusAndTouchSupport=true" />'
$exeConfig = $exeConfig.Replace($oldString, $newString)
$exeConfig | Out-File -FilePath $exeConfigPath -Force -Encoding utf8

$mainExe = "$env:PROGRAMFILES\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
Write-Host "Version info"
(Get-Item $mainExe).VersionInfo
$version = (Get-Item $mainExe).VersionInfo.FileVersion
"microsoft/powerbi:$version" | Set-Content "X:\output\image.txt"
