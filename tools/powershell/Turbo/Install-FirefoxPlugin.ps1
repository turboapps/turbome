# Install a Firefox Plugin in a TurboBrowser image
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Install-FirefoxPlugin
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True)]
        [string] $DownloadDir,       
        [Parameter(Mandatory=$True)]    
        [string] $PluginName,
        [Parameter(Mandatory=$True)]    
        [string] $PluginId
    )
    process
    {
        Add-Type -Assembly “system.io.compression.filesystem”
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $hostname = "https://addons.mozilla.org"
        $pluginPage = (Invoke-WebRequest "$hostname/en-US/firefox/addon/$PluginName")
        if(-not ($pluginPage -match "href=`"(?<link>https://addons.mozilla.org/firefox/downloads.*ublock_origin-.*\.xpi).*<span"))
        {
            throw "Failed to extract download link"
        }
        $downloadLink = $Matches['link']

        if (-not (Test-Path $DownloadDir))
        {
            New-Item -Path $DownloadDir -ItemType Directory | Out-Null
        }
        $DownloadDirToUse = Get-Item $DownloadDir 

        # Download the latest plugin release
        $pluginPath= "$($DownloadDirToUse.FullName)\$pluginName.xpi"

        (New-Object System.Net.WebClient).DownloadFile($downloadLink, $pluginPath)
        if(-not (Test-Path $pluginPath))
        {
            throw "Failed to download the extension using $downloadLink"
        }

        $extractedPluginDir = "$($DownloadDirToUse.FullName)\$pluginId"
        [io.compression.zipfile]::ExtractToDirectory($pluginPath, $extractedPluginDir)

        function Install-Extension($extensionSourceDir) {
            $extensionSourceDirToUse = Get-Item $extensionSourceDir

            $ffInstallDir = "${Env:ProgramFiles(x86)}\Mozilla Firefox"
            $ffExtensionsRegKey = "HKLM:\SOFTWARE\Wow6432Node\Mozilla\Firefox\Extensions"
            if (-not (Test-Path -Path $ffInstallDir)) {
                    # if 64-bit path fails, fall back to 32-bit path
                    $ffInstallDir    = "${Env:ProgramFiles}\Mozilla Firefox"
                    $ffExtensionsRegKey = "HKLM:\SOFTWARE\Mozilla\Firefox\Extensions"
            }
            if (-not (Test-Path -Path $ffInstallDir)) {
                    throw "Problem: Could not find Firefox installation folder."
            }
 
            # create extensions folder if necessary
            $ffExtensionsDir = "$ffInstallDir\extensions"
            if (-not (Test-Path -Path $ffExtensionsDir)) {
                New-Item $ffExtensionsDir -ItemType Directory -ErrorAction SilentlyContinue -Force | Out-Null
            }
            # create extensions registry key if necessary
            if (-not (Test-Path -Path $ffExtensionsRegKey)) {
                New-Item $ffExtensionsRegKey -ErrorAction SilentlyContinue -Force | Out-Null
            }

            # Install extension
            Write-Host "Installing Firefox extension: $($extensionSourceDirToUse.Name)"
            # copy each extension folder to the system
            Copy-Item $extensionSourceDirToUse.FullName $ffExtensionsDir -Recurse -Force | Out-Null
            # create registry key for each extension
            New-ItemProperty -Path $ffExtensionsRegKey -Name $extensionSourceDirToUse.Name -Value "$ffExtensionsDir\$($extensionSourceDirToUse.Name)" -PropertyType String -Force | Out-Null
        }
    
        Install-Extension $extractedPluginDir
    }
}