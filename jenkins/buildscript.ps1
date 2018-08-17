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
    & "$virtualboxDir\VBoxManage.exe" snapshot $machine restore "turboBuildNetworking"
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
    Restore-VirtualMachine
    Sleep -s 5
    Write-Host "Adding shared directory"
    & "$virtualboxDir\VBoxManage.exe" sharedfolder add $machine --name turboBuild --hostpath (Get-Item "$workspacePath\share").FullName
    Sleep -s 5
}

function Download-Installer {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $link = "http://mirrors.jenkins-ci.org/windows-stable/latest"
    (New-Object System.Net.WebClient).DownloadFile($link, "$workspacePath\share\install\install.zip")
}

function Extract-Installer {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$workspacePath\share\install\install.zip", "$workspacePath\share\install")
}

function Download-Plugins {
    New-Item "$workspacePath\share\install\plugins" -type directory
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("https://updates.jenkins-ci.org/download/plugins/git/2.3.5/git.hpi", "$workspacePath\share\install\plugins\git.hpi")
    $webClient.DownloadFile("https://updates.jenkins-ci.org/download/plugins/git-client/1.16.1/git-client.hpi", "$workspacePath\share\install\plugins\git-client.hpi")
    $webClient.DownloadFile("https://updates.jenkins-ci.org/download/plugins/scm-api/0.2/scm-api.hpi", "$workspacePath\share\install\plugins\scm-api.hpi")
    $webClient.DownloadFile("https://updates.jenkins-ci.org/download/plugins/matrix-project/1.4/matrix-project.hpi", "$workspacePath\share\install\plugins\matrix-project.hpi")
    $webClient.DownloadFile("https://updates.jenkins-ci.org/download/plugins/credentials/1.22/credentials.hpi", "$workspacePath\share\install\plugins\credentials.hpi")
    $webClient.DownloadFile("https://raw.githubusercontent.com/turboapps/turbome/master/jenkins/plugin/turbo.hpi", "$workspacePath\share\install\plugins\turbo.hpi")
}

function Prepare-BatFile {
    $batScript ="net use /y x: \\vboxsrv\turboBuild
    echo Capturing before snapshot
    X:\tools\XStudio.exe /before /beforepath X:\output\snapshot
    echo Installing jenkins
    START /WAIT X:\install\jenkins.msi /qn
    echo Install plugins
    xcopy /sy /e /I X:\install\plugins ""%PROGRAMFILES%\jenkins\plugins\""
    sc stop jenkins
    ""%PROGRAMFILES%\jenkins\jenkins.exe"" version > X:\output\version.txt
    echo Capturing after snapshot
    X:\tools\XStudio.exe /after /beforepath X:\output\snapshot /o X:\output
    shutdown -s -f"

    [System.IO.File]::WriteAllLines("$workspacePath\script.bat", $batScript)
}

function Build-Image {
    & "$studioHomePath\xstudio.exe" "$workspacePath\share\output\Snapshot.xappl" /o "$workspacePath\share\output\image.svm" /component /uncompressed /l "$studioHomePath\$studioLicenseFile"
}

function Import-SVM {
    & turbo import svm "$workspacePath\share\output\image.svm" -n="$imageName`:$version"
}

Import-Module Turbo
$imageName = "jenkinsci/jenkins"

Clean-Workspace
Sleep -s 5

Prepare-SharedDirectory
Sleep -s 5

Download-Installer
Sleep -s 5

Extract-Installer
Sleep -s 5

Download-Plugins
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

$version = Get-Content "$workspacePath\share\output\version.txt"
$version = $version -replace '[a-zA-Z ]',''

Write-Host "Built version is: $version. Checking the lastest version available on the hub."

if(Get-LatestHubVersion $imageName $version)
{
    Write-Host "Version $version already on the hub."
    Stop-JenkinsJob
}

Build-Image

Import-SVM