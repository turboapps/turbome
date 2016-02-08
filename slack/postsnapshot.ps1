# 
# Slack post-snapshot script 
# https://github.com/turboapps/turbome/tree/master/slack 
# 

 
# 
# Edit XAPPL 
# 

 
Import-Module Turbo 
 
 
$XappPath = '.\output\Snapshot.xappl' 
$xappl = Read-XAPPL $XappPath 

 
Remove-FileSystemItems $xappl '@APPDATACOMMON@\chocolatey' 
Remove-FileSystemItems $xappl '@APPDATALOCALLOW@\Microsoft' 
Remove-FileSystemItems $xappl '@SYSTEM@\CodeIntegrity' 
Remove-FileSystemDirectoryItems $xappl '@SYSDRIVE@' 
 
 
Remove-StartupFiles $xappl 
$slackExe = '@APPDATALOCAL@\slack\app-1.2.7\slack.exe' 
Add-StartupFile $xappl -File $slackExe -CommandLine '@APPDATALOCAL@\slack\app-1.2.7\slack.exe'

 
Save-XAPPL $xappl $XappPath 
