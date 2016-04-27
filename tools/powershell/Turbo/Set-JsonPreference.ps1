# Edit JSON preference files
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Set-JsonPreference
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $Path,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $Category,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $Property,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [AllowEmptyString()]
        # Skipped type declaration to avoid unwanted conversions (example: $true should be a boolean, not a string value - "true")
        $Value
    )
    process
    {
        $json = (Get-Content $Path) | ConvertFrom-Json

        $categoryValue = $json.PSobject.Properties | Where-Object {$_.Name -eq $Category}
        if($categoryValue)
        {
            Add-Member -Name $Property -Value $Value -MemberType NoteProperty -InputObject $json.$Category -Force
        }
        else
        {
            $json | Add-Member -Name $category -Value @{ $Property = $Value } -MemberType NoteProperty
        }

        ConvertTo-Json $json -Compress | Set-Content $Path
        return $true
    }
}