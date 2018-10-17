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

    [Parameter(Mandatory=$True)]
    [string] $snapshotToRestoreName,

    [Parameter(Mandatory=$True)]
    [string] $postSnapshotScriptPath,

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
    & "$virtualboxDir\VBoxManage.exe" snapshot $machine restore $snapshotToRestoreName
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
    xcopy /sy /e /I x:\ C:\share
    echo Capturing before snapshot
    C:\share\tools\XStudio.exe /before /beforepath C:\share\output\snapshot
    echo Installing dotnet
    START /WAIT C:\share\install\install.exe /norestart /q
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
    C:\share\tools\XStudio.exe /after /beforepath C:\share\output\snapshot /o C:\share\output
    xcopy /sy /e /I c:\share\output x:\output
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
    & "$virtualboxDir\VBoxManage.exe" snapshot $machine restore $snapshotToRestoreName
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

Sleep -s 20

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

$xapplPath = "$workspacePath\share\output\Snapshot.xappl"
. $postSnapshotScriptPath
Invoke-PostSnapshotScript $version $xapplPath

Build-Image

Import-SVM