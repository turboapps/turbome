# Get next tag for an image
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Get-NextTag
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1)]
        [string] $Repo,
        [Parameter(Mandatory=$False)]
        [string] $Hub = 'https://turbo.net',       
        [Parameter(Mandatory=$False)]    
        [ValidateSet('major', 'minor')]     
        [string] $Number = 'major'
    )
    process
    {
        $baseUri = (New-Object System.Uri -ArgumentList $Hub)
        $uri = (New-Object System.Uri -ArgumentList @($baseUri, "io/_hub/repo/$Repo"))
        $result = Invoke-RestMethod $uri
        if(-not $result)
        {
            throw "Failed to find the latest version for repo: $Repo"
        }

        $versions = $result.Tags | ForEach-Object { New-Object System.Version -ArgumentList $_ -ErrorAction SilentlyContinue }
        $latestVersion = ($versions | Measure-Object -Maximum).Maximum
        
        $major = [System.Math]::Max($latestVersion.Major, 0)
        $minor = [System.Math]::Max($latestVersion.Minor, 0)
        $build = $latestVersion.Build
        $revision = $latestVersion.Revision

        if($Number -eq 'major')
        {
            $major += 1
        }
        if ($Number -eq 'minor')
        {
            $minor += 1
        }
        $result = "$major.$minor"
        
        if($build -eq -1)
        {
            return $result
        }
        $result = "$result.$build"
        
        if($revision -eq -1)
        {
            return $result
        }
        return "$result.$revision"
    }
}