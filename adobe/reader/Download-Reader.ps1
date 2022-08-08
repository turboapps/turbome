# Remove progress bars for Invoke-Request to significantly improve performance
$ProgressPreference = 'SilentlyContinue'

# Get latest version for Acrobat Reader from their SCUP page.
## Download SCUP cab.
Wget https://armmf.adobe.com/arm-manifests/win/SCUP/ReaderCatalog-DC.cab -OutFile ReaderCatalog.cab
## Expand cab to XML.
Expand ReaderCatalog.cab -F:* ReaderCatalog.xml
## Parse XML for latest version
[XML]$ReaderCatalog = Get-Content("ReaderCatalog.xml")
$Versions = $ReaderCatalog.SystemsManagementCatalog.SoftwareDistributionPackage.InstallableItem.ApplicabilityRules.MetaData.MsiPatchMetaData.MsiPatch.TargetProduct.UpdatedVersion | Sort-Object -Descending
$LatestVersion = $Versions[0] -Replace ('\.','')

## Create download link for Reader
$DownloadLink = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/" + $LatestVersion + "/AcroRdrDC" + $LatestVersion + "_en_US.exe"


# Download RStudio installer.
$InstallerName = [System.IO.Path]::GetFileName($DownloadLink)
Wget $DownloadLink -O $InstallerName

# Print the installer filename.
$InstallerName