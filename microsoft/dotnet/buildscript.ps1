[CmdletBinding()]
param
(   
    [Parameter(Mandatory=$True)]
    [string] $workspacePath,

    [Parameter(Mandatory=$True)]
    [string] $studioHomePath,

    [Parameter(Mandatory=$True)]
    [string] $studioLicenseFile,

    [Parameter(Mandatory=$True)]
    [string] $PsExecPath,

    [Parameter(Mandatory=$True)]
    [string] $machine,

    [Parameter(Mandatory=$True)]
    [string] $machineIp,

    [Parameter(Mandatory=$True)]
    [string] $user,

    [Parameter(Mandatory=$True)]
    [string] $pass,

    [Parameter(Mandatory=$False,HelpMessage="The version of the .net framework to download. Leave empty for latest version.")]
    [string] $version,

    [Parameter(Mandatory=$False)]
    [string] $virtualboxDir = "C:\Program Files\Oracle\VirtualBox"
)

function Clean-Workspace {
    Remove-Item "$workspacePath\*" -Recurse -Force
}

function Prepare-SharedDirectory {
    New-Item "$workspacePath\share" -type directory
    New-Item "$workspacePath\share\install" -type directory
    New-Item "$workspacePath\share\tools" -type directory
    New-Item "$workspacePath\share\output" -type directory

    #Copy files to shared directory
    Copy-Item "$studioHomePath\xstudio.exe" "$workspacePath\share\tools\xstudio.exe"
    Copy-Item "$studioHomePath\StudioDependencies.svm" "$workspacePath\share\tools\StudioDependencies.svm"
    Copy-Item "$studioHomePath\$studioLicenseFile" "$workspacePath\share\tools\license.txt"
}

function Configure-VirtualMachine {
    Write-Host "Checking VM state"
    $vmstate = & "$virtualboxDir\VBoxManage.exe" showvminfo $machine | Select-String -Pattern "State:" | Out-String
    if(-Not ($vmstate -match "powered off"))
    {
        #Turn virtual machine off
        "Virtual Machine is not powered off. Doing it now."
        & "$virtualboxDir\VBoxManage.exe" controlvm $machine poweroff
        Sleep -s 15
    }
    
    Sleep -s 5
    Write-Host "Restoring snapshot"
    & "$virtualboxDir\VBoxManage.exe" snapshot $machine restore "turboBuildNoNET"
    Sleep -s 5
    Write-Host "Adding shared directory"
    & "$virtualboxDir\VBoxManage.exe" sharedfolder add $machine --name turboBuild --hostpath (Get-Item "$workspacePath\share").FullName
    Sleep -s 5
}

function Download-Installer($version) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    if(!$version) {
        $page = Invoke-WebRequest -Uri https://www.microsoft.com/net/download/windows
        $page -match "(?<=.NET Framework )[0-9]\.[0-9]\.[0-9]" | Out-Null
        $version = $Matches[0]
        Set-Variable -scope 1 -Name "version" -Value $version
    }

    if(Get-LatestHubVersion "microsoft/dotnet" $version)
    {
        Write-Host "Version $version already on the hub."
        Stop-JenkinsJob
    }

    # the download link was found here: https://www.microsoft.com/net/download/all
    $downloadKey = $version.Replace(".", "")
    $content = Invoke-WebRequest https://www.microsoft.com/net/download/thank-you/net$downloadKey

    $link = ($content.Links -match "Try again").href

    (New-Object System.Net.WebClient).DownloadFile($link, "$workspacePath\share\install\install.exe")
}

function Prepare-BatFile {
    $batScript ="net use /y x: \\vboxsrv\turboBuild
    echo Capturing before snapshot
    X:\tools\XStudio.exe /before /beforepath X:\output\snapshot
    echo Installing dotnet
    START /WAIT X:\install\install.exe /norestart /q
    echo Configuring the installation
    c:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\CasPol.exe -q -m -cg All_Code FullTrust
    c:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\CasPol.exe -q -m -cg All_Code FullTrust
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\Microsoft.JScript.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\mscoree.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\mscorlib.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Drawing.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\System.EnterpriseServices.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\System.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Windows.Forms.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Web.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\Microsoft.JScript.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscoree.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscorlib.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Drawing.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.EnterpriseServices.tl
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Windows.Forms.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.tlb

    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\Microsoft.JScript.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\mscoree.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\mscorlib.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Drawing.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\System.EnterpriseServices.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\System.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Windows.Forms.tlb
    c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Web.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\Microsoft.JScript.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscoree.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscorlib.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Drawing.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.EnterpriseServices.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Windows.Forms.tlb
    c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.tlb
    echo Capturing after snapshot
    X:\tools\XStudio.exe /after /beforepath X:\output\snapshot /o X:\output
    shutdown -s -f"

    [System.IO.File]::WriteAllLines("$workspacePath\script.bat", $batScript)
}

function Wait-VirtualMachine {
    $timeout = 300
    Write-Host "Test System: $machine"
    Write-Host "Timeout: $timeout"

    $span = new-timespan -Seconds $timeout
    $timer = [diagnostics.stopwatch]::StartNew()
    While ($True)
    {
    If ($timer.elapsed -gt $span)
    {
      Write-Error "Error: Timeout of $timeout seconds reached while waiting for $machine."
      return -1
    }

    # just execute a prompt window and close it immediately as a test for connectivity
    $p = Start-Process -FilePath $PsExecPath -ArgumentList "\\$machineIp -u $user -p $pass cmd.exe /c" -Wait -NoNewWindow -PassThru
    If ($p.ExitCode -eq 0)
    {
      break
    }

    Write-Host "$machine is not ready yet."
    Start-Sleep -Seconds 5
    }

    Write-Host "$machine is ready!"
    return 0
}

function Restore-VirtualMachine {
    Write-Host "Restoring $machine to the base snapshot"
    & "$virtualboxDir\VBoxManage.exe" snapshot $machine restore "turboBuildNoNET"
}

function Invoke-PostSnapshotScript {
    $xapplPath = "$workspacePath\share\output\Snapshot.xappl"
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

    Set-StandardMetadata $xappl "Title" "Microsoft .NET Runtime Version $version"
    Set-StandardMetadata $xappl "Publisher" "Microsoft Corporation"
    Set-StandardMetadata $xappl "Description" "The .NET Framework is an integral Windows component that supports building and running the next generation of applications and XML Web services."
    Set-StandardMetadata $xappl "Website" "http://www.microsoft.com"
    Set-StandardMetadata $xappl "Version" $version

    Disable-Services $xappl

    # todo: need ability to set service properties #########################################
    # Set WPF Font Cache service to use 32-bit executable
    # - I didn't see this service in my testing so maybe no longer present
    ########################################################################################

    Save-XAPPL $xappl $xapplPath
}

function Build-Image {
    & "$studioHomePath\xstudio.exe" "$workspacePath\share\output\Snapshot.xappl" /o "$workspacePath\share\output\image.svm" /component /uncompressed /l "$studioHomePath\$studioLicenseFile"
}

function Import-SVM {
    & turbo import svm "$workspacePath\share\output\image.svm" -n=microsoft/dotnet:$version
}

Import-Module Turbo

Clean-Workspace
Sleep -s 5

Prepare-SharedDirectory
Sleep -s 5

Download-Installer $version
Sleep -s 5

Configure-VirtualMachine
Sleep -s 5

Prepare-BatFile
Sleep -s 5

Write-Host "Start VM"
& "$virtualboxDir\VBoxManage.exe" startvm $machine

Wait-VirtualMachine

#Write-Host "Running log script from $workspacePath\logForwardScript.bat on $machine"
#& $PsExecPath "\\$machineIp" -u $user -p $pass -i -h -d -c "$workspacePath\logForwardScript.bat"

Write-Host "Running build script from $workspacePath\script.bat on $machine"
& $PsExecPath "\\$machineIp" -u $user -p $pass -i -h -c "$workspacePath\script.bat"

Write-Host "Wait for the build to finish"
$vmstate = & "$virtualboxDir\VBoxManage.exe" showvminfo $machine | Select-String -Pattern "State:" | Out-String
while(-Not ($vmstate -match "powered off"))
{
    Write-Host $vmstate
    Sleep -s 5
    $vmstate = & "$virtualboxDir\VBoxManage.exe" showvminfo $machine | Select-String -Pattern "State:" | Out-String
}

Sleep -s 5

Restore-VirtualMachine

Invoke-PostSnapshotScript

Build-Image

Import-SVM