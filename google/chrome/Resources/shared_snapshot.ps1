#
# Shared code for Chrome Enterprise x86 setup
# https://github.com/turboapps/turbome/tree/master/google/chrome
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Download-Browser($msiPath, $language)
{
	(New-Object System.Net.WebClient).DownloadFile(
    "https://dl.google.com/tag/s/appguid={00000000-0000-0000-0000-000000000000}&iid={00000000-0000-0000-0000-000000000000}&lang=$language&browser=3&usagestats=0&appname=Google%20Chrome&installdataindex=defaultbrowser&needsadmin=prefers/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi",
    $msiPath)
}

function Get-Version($msiPath)
{
	$path = (Get-ChildItem $msiPath).FullName
	$shell = New-Object -COMObject Shell.Application
	$folder = Split-Path $path
	$file = Split-Path $path -Leaf
	$shellfolder = $shell.Namespace($folder)
	$shellfile = $shellfolder.ParseName($file)

	$CommentsKey = 0..287 | Where-Object { $shellfolder.GetDetailsOf($null, $_) -eq "Comments" }
	$comment = $shellfolder.GetDetailsOf($shellfile, $CommentsKey)
	if(-not ($comment -match '^(?<version>\d+(?:\.\d+){3})')) {
		throw "Failed to extract Chrome version"
	}

	return $Matches['version']
}

