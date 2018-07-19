#
# Microsoft .net framework setup script
# https://github.com/turboapps/turbome/tree/master/microsoft/dotnet
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

Param(

    [Parameter(HelpMessage="The version of the .net framework to download. Default is latest version.")]
    [string]$version
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$page = Invoke-WebRequest -Uri https://www.microsoft.com/net/download/windows
$page -match "(?<=.NET Framework )[0-9]\.[0-9]\.[0-9]" | Out-Null
$version = $Matches[0]

# the download link was found here: https://www.microsoft.com/net/download/all
$downloadKey = $version.Replace(".", "")
$content = Invoke-WebRequest https://www.microsoft.com/net/download/thank-you/net${downloadKey}

$content.Content -match "http://go.microsoft.com/fwlink/\?LinkId=\d+"
$downloadLink = $Matches[0]

$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($downloadLink,"dotnet-installer.exe")

"microsoft/dotnet:${version}" | Set-Content 'image.txt'
