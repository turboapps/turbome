#
# Chrome Enterprise x86 post install script
# https://github.com/turboapps/turbome/tree/master/google/chrome/resources
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Edit XAPPL
#

Import-Module Turbo

$XappPath = 'C:\output\Snapshot.xappl'

$xapplText = Get-Content $XappPath -Raw
$regex = '(?<=<Directory name="@APPDATALOCAL@".*noSync=)"True"'
$xapplText = $xapplText -replace $regex, '"False"'
$regex = '(?<=<Directory name="@APPDATALOCALLOW@".*noSync=)"True"'
$xapplText = $xapplText -replace $regex, '"False"'
$xapplText = $xapplText -replace "<MachineSid />", "<MachineSid>S-1-5-21-992951991-166803189-1664049914</MachineSid>"
$xapplText | Out-File $XappPath -Encoding utf8

$xappl = Read-XAPPL $XappPath

# Adds this directory to have it noSync set to False - default option
Add-Directory $xappl "@APPDATALOCAL@\Google\Chrome"

$virtualizationSettings = $xappl.Configuration.VirtualizationSettings
$virtualizationSettings.isolateWindowClasses = [string]$true
$virtualizationSettings.launchChildProcsAsUser = [string]$true

# set net.spoon.chromenativehost key to merge isolation, so Turbo VM Extension is able to establish connection with a message host installed natively
$NativeMessageHostKey = "@HKCU@\SOFTWARE\Google\Chrome\NativeMessagingHosts\net.spoon.chromenativehost"
Set-RegistryKeyIsolation $xappl $NativeMessageHostKey $MergeIsolation

Set-DirectoryIsolation $xappl "@APPDATACOMMON@\Microsoft" $FullIsolation
Set-DirectoryIsolation $xappl "@APPDATALOCAL@\Google" $FullIsolation
Set-DirectoryIsolation $xappl "@PROGRAMFILESX86@\Google" $FullIsolation

Remove-FileSystemDirectoryItems $xappl "@SYSDRIVE@"
Write-Host 'Removing Google Update'
Remove-FileSystemDirectoryItems $xappl "@PROGRAMFILESX86@\Google\Update"
Write-Host 'Removing installer files'
$chromeVersion = Get-Content "X:\install\version.txt"
Remove-FileSystemDirectoryItems $xappl "${env:PROGRAMFILES}\Google\Chrome\Application\$chromeVersion\Installer"


Set-RegistryKeyIsolation $xappl "@HKCU@\Software\Google" $FullIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\SOFTWARE\Wow6432Node\Google" $FullIsolation

Remove-RegistryItems $xappl "@HKCU@\Software\Microsoft"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Wow6432Node\Microsoft"
#This is to keep @HKLM@\SOFTWARE\Microsoft\CurrentVersion\App Paths but delete everything else from @HKLM@\SOFTWARE\Microsoft
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Microsoft\Active Setup"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Microsoft\Internet Explorer"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Microsoft\MediaPlayer"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Microsoft\Windows NT"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Microsoft\CurrentVersion\Installer"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Microsoft\CurrentVersion\Uninstaller"

Add-ObjectMap $xappl -Name 'window://Chrome_MessageWindow:0'

Remove-Service $xappl 'gupdate'
Remove-Service $xappl 'gupdatem'

Save-XAPPL $xappl $XappPath
