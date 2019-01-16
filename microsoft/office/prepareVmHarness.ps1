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
    [string] $turboModulePath,

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
    [string] $snapshotToTakeName,

    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName=$False,HelpMessage="Build script path")]
    [string] $buildScript,

    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName=$False,HelpMessage="Build script path")]
    [string] $configurationMSPFilePath,

    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelineByPropertyName=$False,HelpMessage="Build script path")]
    [string] $overwrite = "false",

    [Parameter(Mandatory=$False)]
    [string] $officeIsoPath = "C:\CI\ISO\Office2016_ProPlus.ISO",

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
    Copy-Item "$buildScript" "$workspacePath\share\install\buildScript.ps1"
    Copy-Item "$studioHomePath\xstudio.exe" "$workspacePath\share\tools\xstudio.exe"
    Copy-Item "$studioHomePath\StudioDependencies.svm" "$workspacePath\share\tools\StudioDependencies.svm"
    Copy-Item "$studioHomePath\$studioLicenseFile" "$workspacePath\share\tools\license.txt"
    Copy-Item "$turboModulePath" "$workspacePath\share\tools" -Recurse

    Copy-Item "$configurationMSPFilePath" "$workspacePath\share\install"
}

function Configure-VirtualMachineBefore {
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
    Write-Host "Attaching ISO"
    & "$virtualboxDir\VBoxManage.exe" storageattach $machine --storagectl "IDE" --type dvddrive --medium $officeIsoPath --port 1 --device 0
    Sleep -s 5
}

function Configure-VirtualMachineAfter {
    Write-Host "Checking VM state"
    $vmstate = & "$virtualboxDir\VBoxManage.exe" showvminfo $machine | Select-String -Pattern "State:" | Out-String
    if(-Not ($vmstate -match "powered off"))
    {
        #Turn virtual machine off
        "Virtual Machine is not powered off. Doing it now."
        & "$virtualboxDir\VBoxManage.exe" controlvm $machine poweroff
        Sleep -s 15
    }

    Write-Host "Take snapshot of the $machine VM"
    & "$virtualboxDir\VBoxManage.exe" snapshot $machine take $snapshotToTakeName
    Sleep -s 5
    Write-Host "Adding shared directory"
    & "$virtualboxDir\VBoxManage.exe" sharedfolder remove $machine --name turboBuild
    Sleep -s 5
    Write-Host "Attaching ISO"
    & "$virtualboxDir\VBoxManage.exe" storageattach $machine --storagectl "IDE" --type dvddrive --medium --port 1 --device 0
    Sleep -s 5
}

function Prepare-BatFile {
    $logForwardScript = "net use x: \\vboxsrv\turboBuild
    :loop
    timeout /t 20 >nul
    copy /b/v/y C:\share\output\logStd.txt X:\output\logStd.txt
    copy /b/v/y C:\share\output\logErr.txt X:\output\logErr.txt
    copy /b/v/y C:\share\output\image_name.txt X:\output\image_name.txt
    goto loop"
    $installScript = "net use x: \\vboxsrv\turboBuild
    xcopy X:\ C:\share /se /I /y
    START /WAIT powershell -command `"&{start-process powershell -verb RunAs -ArgumentList \`"start-process powershell -argumentList '-File C:\share\install\buildScript.ps1' -RedirectStandardOutput C:\share\output\logStd.txt -RedirectStandardError C:\share\output\logErr.txt\`"}`""

    [System.IO.File]::WriteAllLines("$workspacePath\installScript.bat", $installScript)
    [System.IO.File]::WriteAllLines("$workspacePath\logForwardScript.bat", $logForwardScript)
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
    $p = Start-Process -FilePath $PsExecPath -ArgumentList "\\$machineIp -nobanner -u $user -p $pass -h cmd.exe /c" -Wait -NoNewWindow -PassThru
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

function Write-Logs {
    $logStd = Get-Content "$workspacePath\share\output\logStd.txt"
    $logErr = Get-Content "$workspacePath\share\output\logErr.txt"

    Write-Host "### Standard Output:"
    Write-Host $logStd
    Write-Host "### Error Output:"
    Write-Host $logErr
}

Import-Module $turboModulePath

Clean-Workspace
Sleep -s 5

Prepare-SharedDirectory
Sleep -s 5

Configure-VirtualMachine
Sleep -s 5

Prepare-BatFile
Sleep -s 5

Write-Host "Start VM"
& "$virtualboxDir\VBoxManage.exe" startvm $machine

Wait-VirtualMachine

Write-Host "Running log script from $workspacePath\logForwardScript.bat on $machine"
& $PsExecPath "\\$machineIp" -nobanner -u $user -p $pass -i -h -d -c "$workspacePath\logForwardScript.bat"

Write-Host "Running install script from $workspacePath\installScript.bat on $machine"
& $PsExecPath "\\$machineIp" -nobanner -u $user -p $pass -i -h -c "$workspacePath\installScript.bat"

Write-Host "Wait for the build to finish"
while (!(Test-Path "$workspacePath\share\output\image_name.txt"))
{
    Sleep 30
}

Configure-VirtualMachineAfter

Write-Logs