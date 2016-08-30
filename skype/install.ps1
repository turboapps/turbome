#
# Skype install file
# https://github.com/turboapps/turbome/tree/master/skype
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

& install.exe INSTALLDIR=C:\Skype /qn

(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/turboapps/turbome/master/skype/added-keys.reg", "added-keys.reg")
& reg import added-keys.reg

Import-Module Turbo
$fileVersion = Get-FileVersion "c:\\Skype\\Phone\\Skype.exe"
"microsoft\skype:$fileVersion" | Set-Content "C:\vagrant\image.txt"

# Change downloads directory to c:\Skype\Downloads
Start-Process -FilePath 'c:\\Skype\\Phone\\skype.exe'
$settingsPath = "${env:APPDATA}\\skype\\shared.xml"
$maxSteps = 12
$currentStep = 0
$settingsExist = $False
do {
    Start-Sleep -s 5
    $currentStep += 1
    $settingsExist = Test-Path -Path $settingsPath
} while(-not $settingsExist -and $currentStep -lt $maxSteps)

if (-not $settingsExist) {
    throw [System.IO.FileNotFoundException] "$settingsPath not found."
}

Stop-Process -Name 'Skype'
$settings = New-Object XML
$settings.Load($settingsPath)
$libNode = $settings.SelectSingleNode('/config/Lib')
$mediaMessagingNode = $settings.CreateElement('MediaMessaging')
$libNode.AppendChild($mediaMessagingNode)
$storageTransformNode = $settings.CreateElement('StorageTransformEnabled')
$storageTransformNode.InnerText = 1
$mediaMessagingNode.AppendChild($storageTransformNode)
$uiNode = $settings.SelectSingleNode('/config/UI') 
$transferSaveDir = "C:\\Skype\\Downloads"
if (-not (Test-Path $transferSaveDir)) {
    New-Item -ItemType Directory -Force -Path $transferSaveDir
}
$transferDirElement = $settings.CreateElement('TransferSaveDir')
$transferDirElement.InnerText = "C:\Skype\Downloads"
$uiNode.AppendChild($transferDirElement)
$settings.Save($settingsPath)