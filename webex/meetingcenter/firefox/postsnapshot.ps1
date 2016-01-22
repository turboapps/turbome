#
# Cisco WebEx Meeting Center post-snapshot script
# https://github.com/turboapps/turbome/tree/master/webex/meetingcenter
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

Set-FileSystemIsolation $xappl '@PROGRAMFILESX86@\Mozilla Firefox' $FullIsolation

Set-RegistryIsolation $xappl '@HKCU@\Software\Microsoft' $FullIsolation
Set-RegistryIsolation $xappl '@HKLM@\SOFTWARE\Microsoft' $FullIsolation
Set-RegistryIsolation $xappl '@HKLM@\SOFTWARE\Wow6432Node\Microsoft' $FullIsolation

Remove-FileSystemItems $xappl '@APPDATACOMMON@\chocolatey'
Remove-FileSystemItems $xappl '@APPDATALOCAL@\NuGet'
Remove-FileSystemItems $xappl '@APPDATALOCALLOW@\Microsoft'
Remove-FileSystemItems $xappl '@SYSTEM@\CodeIntegrity'
Remove-FileSystemDirectoryItems $xappl '@SYSDRIVE@'

Remove-StartupFiles $xappl
$firefoxExe = '@PROGRAMFILESX86@\Mozilla Firefox\firefox.exe'
Add-StartupFile $xappl -File $firefoxExe -CommandLine 'https://signin.webex.com/collabs/#/meetings/joinbynumber' -AutoStart
Add-StartupFile $xappl -File $firefoxExe -CommandLine 'https://signin.webex.com/collabs/#/meetings/joinbynumber' -Name 'join'
Add-StartupFile $xappl -File $firefoxExe -CommandLine 'https://signin.webex.com/collabs/auth?service=it&from=hostmeeting' -Name 'host'

Save-XAPPL $xappl $XappPath