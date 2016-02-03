# Downloads Turbo module from GitHub
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Deploy-TurboModule
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
	    [string] $Path
    )
    process
    {
        $relativeModulePath = "$Path\Turbo"
        if(-not (Test-Path $relativeModulePath)) {
            New-Item -Path $relativeModulePath -Type Directory | Out-Null
        }
        $fullModulePath = (Resolve-Path $relativeModulePath).Path

        $fileItems = Invoke-RestMethod https://api.github.com/repos/turboapps/turbome/contents/tools/powershell/Turbo
        $webClient = New-Object System.Net.WebClient
        try
        {
            foreach($fileItem in $fileItems)
            {
                $webClient.DownloadFile($fileItem.download_url, "$fullModulePath\$($fileItem.name)")
                Write-Verbose "Downloaded $($fileItem.name)"
            }
        }
        finally
        {
            $webClient.Dispose()
        }
    }
}