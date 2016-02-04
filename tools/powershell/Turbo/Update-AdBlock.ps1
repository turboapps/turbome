# Update AdBlock Firefox Plugin in a TurboBrowser image
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Update-AdBlock
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True)]
	    [string] $DownloadDir,       
        [Parameter(Mandatory=$True)]    
        [string] $ConfigPath
    )
    process
    {
        # Visit AdBlock Plugin page and extract a download link to the latest version
        $pluginPage = (Invoke-WebRequest "https://addons.mozilla.org/en-US/firefox/addon/adblock-plus")
        if(-not ($pluginPage -match '(?<=\").*?(?<filename>adblock_plus-(?:\d+\.)+\d+-.*?\.xpi)'))
        {
            throw "Failed to extract AdBlock link"
        }
        $downloadLink = $Matches[0]
        $pluginFileName = $Matches['filename']

        # Remove existing AdBlock Plugin from cck2 configuration
        Get-ChildItem $DownloadDir -Filter "adblock_plus*.xpi" | Remove-Item

        # Download the latest AdBlock release
        $pluginPath= "$DownloadDir\$pluginFileName"
        (New-Object System.Net.WebClient).DownloadFile($downloadLink, $pluginPath)
        if(-not (Test-Path $pluginPath))
        {
            throw "Failed to download AdBlock extension from $downloadLink"
        }

        # Update cck2 configuration
        $config = Get-Content $ConfigPath
        $adblockRegex = (New-Object System.Text.RegularExpressions.Regex -ArgumentList '(?<=addons/)adblock_plus-(?:\d+\.)+\d+-.*?\.xpi')
        $updatedConfig = $config.Replace($config, $pluginFileName)
        $updatedConfig | Set-Content $configPath
    }
}