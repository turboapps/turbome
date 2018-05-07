#
# Python 2.7 snapshot file
# https://github.com/turboapps/turbome/tree/master/python
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$result = Invoke-WebRequest -Uri "http://www.python.org/downloads/windows/"

if ($result -NotMatch 'a href="(?<downloadLink>.*[0-9.][^rc]+\.msi)">Windows x86 MSI')
{
	throw "Failed to extract download link"
}
$downloadLink = $matches["downloadLink"]
(New-Object System.Net.WebClient).DownloadFile($downloadLink, "install.msi")

if ($downloadLink -NotMatch '.*python/(?<release>.*[0-9.][^rc]+)/python')
{
	throw "Failed to extract tag"
}
$tag = $matches["release"]

"python/python:$tag" | Set-Content "image.txt"