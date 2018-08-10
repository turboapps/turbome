# Extract the latest version of Turbo repository
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Get-LatestHubVersion
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $imageToCheck,

        [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $versionToCheck
    )
    process
    {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $hubResponse = Invoke-WebRequest -Uri "https://turbo.net/io/_hub/repo/$imageToCheck"
        $tags = $hubResponse | ConvertFrom-Json | Select -expand tags

        if($versionToCheck) {
            return ([string]$tags[0]) -match $versionToCheck
        }
        else {
            return $tags[0]
        }
    }
}