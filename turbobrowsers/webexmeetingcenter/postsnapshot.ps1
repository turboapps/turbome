#
# Cisco WebEx Meeting Center post-snapshot script
# https://github.com/turboapps/turbome/tree/master/turbobrowsers/webexmeetingcenter
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Edit XAPPL
# Project requires setting dependency to turbobrowsers/turbobase
#

Import-Module Turbo

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

Set-DirectoryIsolation $xappl '@PROGRAMFILESX86@\Mozilla Firefox' $FullIsolation

Set-RegistryKeyIsolation $xappl '@HKCU@\Software\Microsoft' $FullIsolation
Set-RegistryKeyIsolation $xappl '@HKLM@\SOFTWARE\Microsoft' $FullIsolation
Set-RegistryKeyIsolation $xappl '@HKLM@\SOFTWARE\Wow6432Node\Microsoft' $FullIsolation

#This key is removed due to illegal character it brings to xappl. This line may be removed if xappl is moved from XML 1.0 to 1.1 or higher.
Remove-RegistryItems $xappl '@HKLM@\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products'

Remove-FileSystemItems $xappl '@APPDATACOMMON@\chocolatey'
Remove-FileSystemItems $xappl '@APPDATALOCAL@\NuGet'
Remove-FileSystemItems $xappl '@APPDATALOCALLOW@\Microsoft'
Remove-FileSystemItems $xappl '@SYSTEM@\CodeIntegrity'
Remove-FileSystemDirectoryItems $xappl '@SYSDRIVE@'

$firefoxInstallDir = '.\Resources\Files\Default\@PROGRAMFILESX86@\Mozilla Firefox'
Update-AdBlock -DownloadDir "$firefoxInstallDir\cck2\resources\addons" -ConfigPath "$firefoxInstallDir\cck2.cfg"

Import-Files $xappl -SourceDir '.\Resources\Files\Default' -SnapshotDir '.\output\Files' | Out-Null

Remove-StartupFiles $xappl
$firefoxExe = '@PROGRAMFILESX86@\Mozilla Firefox\firefox.exe'
Add-StartupFile $xappl -File $firefoxExe -CommandLine 'https://signin.webex.com/collabs/#/meetings/joinbynumber' -AutoStart
Add-StartupFile $xappl -File $firefoxExe -CommandLine 'https://signin.webex.com/collabs/#/meetings/joinbynumber' -Name 'join'
Add-StartupFile $xappl -File $firefoxExe -CommandLine 'https://signin.webex.com/collabs/auth?service=it&from=hostmeeting' -Name 'host'

Add-ObjectMap $xappl -Name 'Window://firefoxMessageWindow:0'

Save-XAPPL $xappl $XappPath