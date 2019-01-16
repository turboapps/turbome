function Capture-Before {
    & "c:\share\tools\XStudio.exe" /before /beforepath c:\output\snapshot
}

function Install-Office {
    $opticalDrivePath = (Get-CimInstance -class cim_cdromdrive).Drive
    $officeInstallerPath = "C:\Installer"
    New-Item $officeInstallerPath -type directory
    Copy-Item "$opticalDrivePath\*" $officeInstallerPath -Recurse
    Copy-Item "c:\share\install\*.msp" "$officeInstallerPath\updates"
    Write-Host "Copied files from install drive to local disk. Dir:"
    Get-ChildItem $officeInstallerPath

    Write-Host "Running installer"
    & "$officeInstallerPath\setup.exe" | Out-Null
    Write-Host "Installer finished"
}
function Find-OfficeExe {
    Write-Host "Looking for office exe"
    $programFiles86Dir = (${env:ProgramFiles(x86)}, ${env:ProgramFiles} -ne $null)[0]
    $officeExeDirectory = "$programFiles86Dir\Microsoft Office\Office16"
    if (Test-Path "$officeExeDirectory\EXCEL.EXE")
    {
        [System.IO.File]::WriteAllLines("c:\share\output\image_name.txt", "excel")
    }
    if (Test-Path "$officeExeDirectory\POWERPNT.EXE")
    {
        [System.IO.File]::WriteAllLines("c:\share\output\image_name.txt", "powerpoint")
    }
    if (Test-Path "$officeExeDirectory\WINWORD.EXE")
    {
        [System.IO.File]::WriteAllLines("c:\share\output\image_name.txt", "word")
    }
}

function Delete-Installer {
    Remove-Item -Path "C:\Installer" -Recurse -Force
}

Capture-Before

Install-Office

Delete-Installer

Find-OfficeExe