#
# Microsoft Visual C++ Redistributable setup script
# https://github.com/turboapps/turbome/tree/master/microsoft/vcredist
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$content = Invoke-WebRequest https://www.microsoft.com/en-us/download/confirmation.aspx?id=48145

$content -match "(?<="")https://download.microsoft.com/download/[^""]*?/vc_redist.x86.exe(?="")"
$x86DownloadLink = $Matches[0]

$content -match "(?<="")https://download.microsoft.com/download/[^""]*?/vc_redist.x64.exe(?="")"
$x64DownloadLink = $Matches[0]

$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($x86DownloadLink,'vc_redist.x86.exe')
$webClient.DownloadFile($x64DownloadLink,'vc_redist.x64.exe')

"microsoft/vcredist:2015" | Set-Content 'image.txt'
# TODO: Support something like this in Turbo Jenkins plugin
#"microsoft/universal-crt" | Set-Content 'dependencies.txt'
