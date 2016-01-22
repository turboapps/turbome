# Extract the latest version of Chocolatey package
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Get-LatestChocoVersion
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Name of the Chocolatey package")]
	    [string] $Package
    )
    process
    {
        $versions = (& choco list $Package | Where-Object {$_ -match "(?<version>\d+(:?\.\d+)+)"} | Select-Object -InputObject {$Matches['version']})
        if(-not $versions)
        {
            throw "No versions available for package: $Package" 
        }
        if($versions.Count -gt 1)
        {
            throw "More than one version is available: $Package"
        }
        return $versions
    }
}
