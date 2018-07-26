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
        $hubResponse = turbo releases $imageToCheck

        if($versionToCheck) {
            return ([string]$hubResponse) -match $versionToCheck
        }
        else {
            return $hubResponse[2]
        }
    }
}