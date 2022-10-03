# Remove progress bars for Invoke-Request to significantly improve performance
$ProgressPreference = 'SilentlyContinue'

# Get main download page for application.
$Page = Invoke-WebRequest -Uri 'https://notepad-plus-plus.org/downloads/' -UseBasicParsing

# Get download page for latest version.
$Page2 = Invoke-WebRequest -Uri ('https://notepad-plus-plus.org' + ($Page.Links | Where-Object {$_.outerHTML -like "*Current Version*"}).href) -UseBasicParsing

# Get installer link for latest version.
$DownloadLink = ($Page2.Links | Where-Object {$_.href -like "*Installer.exe*"})[0]

# Download installer.
$InstallerName = [System.IO.Path]::GetFileName($DownloadLink.href)
wget $DownloadLink.href -O $InstallerName

# Print the installer filename.
$InstallerName

