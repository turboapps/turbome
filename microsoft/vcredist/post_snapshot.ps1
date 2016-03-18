#
# Microsoft Visual C++ Redistributable post install script
# https://github.com/turboapps/turbome/tree/master/microsoft/vcredist
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Edit XAPPL
#

Import-Module Turbo

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

Remove-Layer $xappl 'Xenocode'

# Remove sandbox settings - workaround for the bug: hundreds of _IEXPLORER.EXE procs start and IE fails to launch
$xappl.Configuration.RemoveChild($xappl.Configuration.VirtualizationSettings)

Remove-FileSystemItems $xappl "@SYSTEM@\MsDtc"
Remove-FileSystemItems $xappl "@SYSTEM@\Sysprep"
Remove-FileSystemItems $xappl "@APPDATALOCALLOW@\Microsoft"

Remove-RegistryItems $xappl "@HKCU@\Software"

Save-XAPPL $xappl $XappPath