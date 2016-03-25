#
# Dell PowerGUI post-snapshot script
# https://github.com/turboapps/turbome/tree/master/dell/powergui
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Edit XAPPL
#

Import-Module Turbo

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath


Set-RegistryIsolation $xappl '@HKCU@\Software\Microsoft' $FullIsolation
Set-RegistryIsolation $xappl '@HKLM@\SOFTWARE\Microsoft' $FullIsolation
Set-RegistryIsolation $xappl '@HKLM@\SOFTWARE\Wow6432Node\Microsoft' $FullIsolation
Set-RegistryIsolation $xappl '@HKLM@\SOFTWARE\Quest Software' $FullIsolation
Set-RegistryIsolation $xappl '@HKLM@\SOFTWARE\Wow6432Node\Quest Software' $FullIsolation

Remove-FileSystemItems $xappl '@APPDATACOMMON@\chocolatey'
Remove-FileSystemItems $xappl '@APPDATALOCAL@\NuGet'
Remove-FileSystemItems $xappl '@APPDATALOCALLOW@\Microsoft'
Remove-FileSystemItems $xappl '@SYSTEM@\CodeIntegrity'
Remove-FileSystemDirectoryItems $xappl '@SYSDRIVE@'

$powerguiInstallDir = '.\output\Files\Default\@PROGRAMFILESX86@\PowerGUI'

Remove-StartupFiles $xappl
$powerguiscriptExe = '@PROGRAMFILESX86@\PowerGUI\ScriptEditor.exe'
$powerguiscriptx86Exe = '@PROGRAMFILESX86@\PowerGUI\ScriptEditor_x86.exe'
$powerguiadminExe = '@PROGRAMFILESX86@\PowerGUI\AdminConsole.exe'
$powerguiadminx86Exe = '@PROGRAMFILESX86@\PowerGUI\AdminConsole_x86.exe'
Add-StartupFile $xappl -File $powerguiscriptExe -Name 'ScriptEditor' -AutoStart
Add-StartupFile $xappl -File $powerguiscriptx86Exe -Name 'ScriptEditor_x86'
Add-StartupFile $xappl -File $powerguiadminExe -CommandLine '-AuthoringMode' -Name 'AdminConsoleAuthoring'
Add-StartupFile $xappl -File $powerguiadminx86Exe -CommandLine '-AuthoringMode' -Name 'AdminConsoleAuthoringx86'
Add-StartupFile $xappl -File $powerguiadminExe -Name 'AdminConsole'

Add-StartupFile $xappl -File $powerguiadminx86Exe -Name 'AdminConsolex86'

Save-XAPPL $xappl $XappPath