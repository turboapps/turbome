#
# Adobe Brackets setup script
# https://github.com/turboapps/turbome/tree/master/adobe/brackets
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$result = Invoke-WebRequest -Uri https://github.com/adobe/brackets/releases
if ($result -NotMatch 'a href="(?<downloadLink>.*[0-9.]{2,}.msi)"')
	{ throw "Failed to extract download link" }
$link = "https://github.com/"+$Matches['downloadLink']
$version = [regex]::match($link,'[0-9]+.[0-9]+').Value

if(!(Test-Path ".\installFiles")) { New-Item ".\installFiles" -type directory}

(New-Object System.Net.WebClient).DownloadFile($link, ".\installFiles\install.msi")

"adobe/brackets:$version" | Set-Content "image.txt"