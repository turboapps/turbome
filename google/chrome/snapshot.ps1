#
# Chrome Enterprise x86 snapshot setup file
# https://github.com/turboapps/turbome/tree/master/google/chrome
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

(New-Object System.Net.WebClient).DownloadFile(
    "https://dl.google.com/tag/s/appguid={00000000-0000-0000-0000-000000000000}&iid={00000000-0000-0000-0000-000000000000}&lang=en&browser=3&usagestats=0&appname=Google%20Chrome&installdataindex=defaultbrowser&needsadmin=prefers/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi",
    "install.msi")

$path = (Get-ChildItem '.\install.msi').FullName
$shell = New-Object -COMObject Shell.Application
$folder = Split-Path $path
$file = Split-Path $path -Leaf
$shellfolder = $shell.Namespace($folder)
$shellfile = $shellfolder.ParseName($file)

$CommentsKey = 0..287 | Where-Object { $shellfolder.GetDetailsOf($null, $_) -eq "Comments" }
$comment = $shellfolder.GetDetailsOf($shellfile, $CommentsKey)
if(-not ($comment -match '^(?<version>\d+(?:\.\d+){3})')) {
    Write-Error "Failed to extract Chrome version"
    exit 1
}

$tag = $Matches['version']
Write-Host "Chrome version $tag"
"google/chrome:$tag" | Set-Content "image.txt"

# Silent install arguments: /quiet
