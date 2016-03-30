#
# VMware vSphere Client post-snapshot script
# https://github.com/turboapps/turbome/tree/master/vmware/vsphereclient
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Edit XAPPL
#

Import-Module Turbo

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath


Remove-FileSystemItems $xappl '@APPDATACOMMON@\Microsoft'
Remove-FileSystemItems $xappl '@APPDATALOCAL@\Microsoft'
Remove-FileSystemItems $xappl '@APPDATALOCALLOW@\Microsoft'
Remove-FileSystemItems $xappl '@APPDATA@\Microsoft'
Remove-FileSystemDirectoryItems $xappl '@SYSDRIVE@'

$vsphereclientInstallDir = '.\output\Files\Default\VMware\Infrastructure\Virtual Infrastructure Client\Launcher'


$vsphereclientExe = '@PROGRAMFILESX86@\VMware\Infrastructure\Virtual Infrastructure Client\Launcher\VpxClient.exe'

Add-StartupFile $xappl -File $vsphereclientExe -Name 'vSphereClient'

Save-XAPPL $xappl $XappPath
