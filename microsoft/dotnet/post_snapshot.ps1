#
# Microsoft .net framework setup script
# https://github.com/turboapps/turbome/tree/master/microsoft/dotnet
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

#
# Edit XAPPL
#
# NOTE: This is the procedure for .net 4.7. Can't claim that it will work for all versions, past and future.

Import-Module Turbo

# todo: read version from image.txt
$version = "4.7.2"

$xapplPath = '.\output\Snapshot.xappl'
$xappl = Read-XAPPL $xapplPath

Remove-FileSystemItems $xappl "@SYSTEM@\CodeIntegrity"
Remove-FileSystemItems $xappl "@SYSTEM@\restore"
Remove-FileSystemItems $xappl "@WINDIR@\assembly\NativeImages_v4.0.30319_32"
Remove-FileSystemItems $xappl "@WINDIR@\assembly\NativeImages_v4.0.30319_64"
Remove-FileSystemItems $xappl "@WINDIR@\Migration"
Remove-FileSystemItems $xappl "@WINDIR@\Microsoft.NET\Framework\v4.0.30319\SetupCache"
Remove-FileSystemItems $xappl "@WINDIR@\Microsoft.NET\Framework64\v4.0.30319\SetupCache"
Remove-FileSystemItems $xappl "@WINDIR@\Microsoft.net\Framework\v2.0.50727"
Remove-FileSystemItems $xappl "@WINDIR@\Microsoft.net\Framework64\v2.0.50727"

Remove-RegistryItems $xappl "@HKCU@"
Remove-RegistryItems $xappl "@HKLM@\Software\Policies"
Remove-RegistryItems $xappl "@HKLM@\SYSTEM"
Remove-RegistryItems $xappl "@HKLM@\Software\Microsoft\EnterpriseCertificates"
Remove-RegistryItems $xappl "@HKLM@\Software\Wow6432Node\Microsoft\EnterpriseCertificates"

Set-RegistryValue $xappl "@HKLM@\Software\Microsoft\.NETFramework" "InstallRoot" "@WINDIR@\Microsoft.NET\Framework64\"
Set-RegistryValue $xappl "@HKLM@\Software\Wow6432Node\Microsoft\.NETFramework" "InstallRoot" "@WINDIR@\Microsoft.NET\Framework\"
Set-RegistryValue $xappl "@HKLM@\Software\Microsoft\.NETFramework" "Enable64Bit" "1" $DwordValueType

Set-DirectoryIsolation $xappl "@APPDATA@\Microsoft\CLR Security Config" $WriteCopyIsolation
Set-DirectoryIsolation $xappl "@APPDATA@\Microsoft\CLR Security Config\v4.0.30319" $FullIsolation
Set-DirectoryIsolation $xappl "@APPDATA@\Microsoft\.NET Framework Config" $FullIsolation
Set-DirectoryIsolation $xappl "@APPDATACOMMON@\Microsoft\NetFramework" $FullIsolation
Set-DirectoryIsolation $xappl "@PROGRAMFILESX86@\Microsoft.NET" $FullIsolation
Set-DirectoryIsolation $xappl "@WINDIR@\assembly" $WriteCopyIsolation
Set-DirectoryIsolation $xappl "@WINDIR@\assembly\NativeImages_v4.0.30319_32" $FullIsolation 
Set-DirectoryIsolation $xappl "@WINDIR@\assembly\NativeImages_v4.0.30319_64" $FullIsolation
Set-DirectoryIsolation $xappl "@WINDIR@\assembly\temp" $FullIsolation
Set-DirectoryIsolation $xappl "@WINDIR@\assembly\tmp" $FullIsolation
Set-DirectoryIsolation $xappl "@WINDIR@\Microsoft.net" $FullIsolation
Set-DirectoryIsolation $xappl "@WINDIR@\Microsoft.net\Framework\v4.0.30319" $FullIsolation
Set-DirectoryIsolation $xappl "@WINDIR@\Microsoft.net\Framework64\v4.0.30319" $FullIsolation

Set-DirectoryIsolation $xappl "@WINDIR@\Microsoft.net\Framework" $WriteCopyIsolation
Set-DirectoryIsolation $xappl "@WINDIR@\Microsoft.net\Framework64" $WriteCopyIsolation
Set-DirectoryIsolation $xappl "@WINDIR@\Microsoft.net\assembly" $FullIsolation -Recurse

Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes" $FullIsolation -Recurse -RecurseDepth 1
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes" $MergeIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\AppID" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\AppID" $MergeIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\CLSID" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\CLSID" $MergeIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Installer" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Installer" $MergeIsolation -Recurse -RecurseDepth 1
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Interface" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Interface" $MergeIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Record" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Record" $MergeIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\TypeLib" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\TypeLib" $MergeIsolation

Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node" $FullIsolation -Recurse -RecurseDepth 1
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node" $MergeIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\AppID" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\AppID" $MergeIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\CLSID" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\CLSID" $MergeIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\Installer" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\Installer" $MergeIsolation -Recurse -RecurseDepth 1
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\Interface" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\Interface" $MergeIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\Record" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\Record" $MergeIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\TypeLib" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Classes\Wow6432Node\TypeLib" $MergeIsolation

Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Microsoft\.NETFramework" $WriteCopyIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Microsoft\.NETFramework\v4.0.30319" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Microsoft\ASP.NET" $WriteCopyIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Microsoft\ASP.NET\4.0.30319.0" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Microsoft\NET Framework Setup" $WriteCopyIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Microsoft\MSBuild" $WriteCopyIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Microsoft\MSBuild\4.0" $FullIsolation -Recurse

Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Wow6432Node\Microsoft\.NETFramework" $WriteCopyIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Wow6432Node\Microsoft\ASP.NET" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Wow6432Node\Microsoft\ASP.NET" $WriteCopyIsolation
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Wow6432Node\Microsoft\NET Framework Setup" $WriteCopyIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Wow6432Node\Microsoft\MSBuild" $WriteCopyIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Wow6432Node\Microsoft\MSBuild\4.0" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Wow6432Node\Microsoft\devDiv\netfx" $FullIsolation -Recurse
Set-RegistryKeyIsolation $xappl "@HKLM@\Software\Wow6432Node\Microsoft\devDiv\netfx" $WriteCopyIsolation

Set-FileSystemObject $xappl "@WINDIR@\assembly" -NoSync $True

Set-StandardMetadata $xappl "Title" "Microsoft .NET Runtime Version ${version}"
Set-StandardMetadata $xappl "Publisher" "Microsoft Corporation"
Set-StandardMetadata $xappl "Description" "The .NET Framework is an integral Windows component that supports building and running the next generation of applications and XML Web services."
Set-StandardMetadata $xappl "Website" "http://www.microsoft.com"
Set-StandardMetadata $xappl "Version" ${version}

Disable-Services $xappl

# todo: need ability to set service properties #########################################
# Set WPF Font Cache service to use 32-bit executable
# - I didn't see this service in my testing so maybe no longer present
########################################################################################



Save-XAPPL $xappl $xapplPath
