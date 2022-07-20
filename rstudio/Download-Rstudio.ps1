# Remove progress bars for Invoke-Request to significantly improve performance
$ProgressPreference = 'SilentlyContinue'

# Get download page for RStudio.
$Page = Invoke-WebRequest -Uri 'https://www.rstudio.com/products/rstudio/download/' -UseBasicParsing

# Get download link for RStudio for Windows.
$DownloadLink = $Page.Links | Where-Object {$_.outerHTML -like "*Download RStudio for Windows*"}

# Download RStudio installer.
$InstallerName = [System.IO.Path]::GetFileName($DownloadLink.href)
wget $DownloadLink.href -O $InstallerName

# Print the installer filename.
$InstallerName
