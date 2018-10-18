function Capture-Before {
    & "c:\share\tools\XStudio.exe" /before /beforepath c:\output\snapshot
}
function Capture-After {
    & "c:\share\tools\XStudio.exe" /after /beforepath c:\output\snapshot /o c:\output
}

function Build-Image {
    & "c:\share\tools\XStudio.exe" c:\output\snapshot.xappl /o c:\share\output\image.svm /component /uncompressed /l c:\share\tools\license.txt
}

function Send-Keystroke{
    param(
    [Parameter(Mandatory=$true)]
    [String]$Keystroke
    )
    
    [Windows.Forms.Sendkeys]::SendWait($Keystroke)
}

function Install-Office {
    $opticalDrivePath = (Get-CimInstance -class cim_cdromdrive).Drive
    $officeInstallerPath = "C:\Installer"
    New-Item $officeInstallerPath -type directory
    Copy-Item "$opticalDrivePath\*" $officeInstallerPath -Recurse
    Copy-Item "c:\share\install\*.msp" "$officeInstallerPath\updates"

    & "$officeInstallerPath\setup.exe" | Out-Null
}
function Find-OfficeExe {
    $programFiles86Dir = (${env:ProgramFiles(x86)}, ${env:ProgramFiles} -ne $null)[0]
    $officeExeDirectory = "$programFiles86Dir\Microsoft Office\Office16"
    if (Test-Path "$officeExeDirectory\EXCEL.EXE")
    {
        $exeToLaunch = "EXCEL"
        [System.IO.File]::WriteAllLines("c:\share\output\image_name.txt", "excel")
    }
    if (Test-Path "$officeExeDirectory\POWERPNT.EXE")
    {
        $exeToLaunch = "POWERPNT"
        [System.IO.File]::WriteAllLines("c:\share\output\image_name.txt", "powerpoint")
    }
    if (Test-Path "$officeExeDirectory\WINWORD.EXE")
    {
        $exeToLaunch = "WINWORD"
        [System.IO.File]::WriteAllLines("c:\share\output\image_name.txt", "word")
    }

    return "$officeExeDirectory\$exeToLaunch.EXE"
}

function FirstLaunch-Office {
    $officeExe = Find-OfficeExe

    & $officeExe
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    Sleep -s 30
    Send-Keystroke " "
    Sleep -Milliseconds 500
    Send-Keystroke "{ENTER}"
    Sleep -Milliseconds 500

    $exeToStop = $officeExe.split('\.')[-2]
    Get-Process $exeToStop | Stop-Process -Force
}

function Delete-Installer {
    Remove-Item -Path "C:\Installer" -Recurse -Force
}

function Get-OfficeVersion {
    $officeExePath = Find-OfficeExe
    $officeExe = Get-Item -path $officeExePath
    $version = $officeExe.VersionInfo.FileVersion
    [System.IO.File]::WriteAllLines("c:\share\output\version.txt", "2016.$version")
}

function Enable-OfficeUpdatesInWinUpdate {
    $ServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"
    $ServiceManager.ClientApplicationID = "My App"
    $ServiceManager.AddService2( "7971f918-a847-4430-9279-4a52d1efe18d",7,"")
}

function Install-Updates {
    $AvailableUpdates = @()
    Write-Host "Creating Update Session"
    $Session = New-Object -com "Microsoft.Update.Session"
    $Search = $Session.CreateUpdateSearcher()
    $SearchResults = $Search.Search("IsInstalled=0 and IsHidden=0")

    Write-Host "There are " $SearchResults.Updates.Count "TOTAL updates available."
    $SearchResults.Updates | ForEach-Object {
        if(($_.Categories.Item(0).Name -like "Office 2016") -or ($_.Categories.Item(1).Name -like "Office 2016")) {
            $AvailableUpdates += $_
        }
    }

    Write-Host "There are " $AvailableUpdates.Count "Office updates available:"
    $AvailableUpdates | ForEach-Object {
        Write-Host $_.Title -ForegroundColor Green
    }

    Write-Host "Downloading updates..."
    $DownloadCollection = New-Object -com "Microsoft.Update.UpdateColl"
    $AvailableUpdates | ForEach-Object {
        if ($_.InstallationBehavior.CanRequestUserInput -ne $TRUE) {
            $DownloadCollection.Add($_) | Out-Null
            }
        }
    $Downloader = $Session.CreateUpdateDownloader()
    $Downloader.Updates = $DownloadCollection
    $Downloader.Download()

    Write-Host "Download complete."

    Write-Host "Creating Installation Object"
    $InstallCollection = New-Object -com "Microsoft.Update.UpdateColl"
    $AvailableUpdates | ForEach-Object {
        if ($_.IsDownloaded) {
            $InstallCollection.Add($_) | Out-Null
        }
    }

    Write-Host "Installing updates..."
    $Installer = $Session.CreateUpdateInstaller()
    $Installer.Updates = $InstallCollection
    $Results = $Installer.Install()
    Write-Host "Installation complete."

    # Reboot if needed
    if ($Results.RebootRequired) {
        Write-Host "Please reboot."
    }
    else {
        Write-Host "No reboot required."
    }
}

function Update-Office {
    Enable-OfficeUpdatesInWinUpdate

    Install-Updates
}

function Configure-Snapshot {
    Import-Module C:\share\tools\Turbo

    $XappPath = 'C:\output\Snapshot.xappl'
    $xappl = Read-XAPPL $XappPath

    $virtualizationSettings = $xappl.Configuration.VirtualizationSettings
    $virtualizationSettings.launchChildProcsAsUser = [string]$true
    $virtualizationSettings.faultExecutablesIntoSandbox = [string]$true

    Remove-FileSystemItem $xappl "@SYSDRIVE@\output"
    Remove-FileSystemItem $xappl "@SYSDRIVE@\share"

    $dependency = $xappl.CreateElement('Dependency')
    $dependency.SetAttribute("Identifier","microsoft/universal-crt")
    $dependency.SetAttribute("Hash","4aacde9ac183a14eb15d09761d6e9eab240b7802ebc71ae0d09e7367573093b4")

    $dependencies = $xappl.SelectSingleNode("//Configuration/Dependencies")
    $dependencies.AppendChild($dependency)

    Save-XAPPL $xappl $XappPath


}

Capture-Before

Install-Office

Delete-Installer

Update-Office

FirstLaunch-Office

Capture-After

Configure-Snapshot

Build-Image

Get-OfficeVersion