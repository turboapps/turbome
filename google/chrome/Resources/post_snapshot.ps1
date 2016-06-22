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

$XappPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $XappPath

$virtualizationSettings = $xappl.Configuration.VirtualizationSettings
$virtualizationSettings.isolateWindowClasses = [string]$true
$virtualizationSettings.launchChildProcsAsUser = [string]$true

# set net.spoon.chromenativehost key to merge isolation, so Turbo VM Extension is able to establish connection with a message host installed natively 
$NativeMessageHostKey = "@HKCU@\SOFTWARE\Google\Chrome\NativeMessagingHosts\net.spoon.chromenativehost"
Add-RegistryKey $xappl $NativeMessageHostKey $FullIsolation
Set-RegistryIsolation $xappl $NativeMessageHostKey $MergeIsolation

Set-FileSystemIsolation $xappl "@APPDATACOMMON@\Microsoft" $FullIsolation
Set-FileSystemIsolation $xappl "@APPDATALOCAL@\Google" $FullIsolation
Set-FileSystemIsolation $xappl "@PROGRAMFILESX86@\Google" $FullIsolation

Remove-FileSystemDirectoryItems $xappl "@SYSDRIVE@"

Set-RegistryIsolation $xappl "@HKCU@\Software\Google" $FullIsolation
Set-RegistryIsolation $xappl "@HKLM@\SOFTWARE\Wow6432Node\Google" $FullIsolation

Remove-RegistryItems $xappl "@HKCU@\Software\Microsoft"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Wow6432Node\Microsoft"
Remove-RegistryItems $xappl "@HKLM@\SOFTWARE\Microsoft"

Add-ObjectMap $xappl -Name 'window://Chrome_MessageWindow:Chrome_MessageWindow'

Disable-Services $xappl 

Save-XAPPL $xappl $XappPath