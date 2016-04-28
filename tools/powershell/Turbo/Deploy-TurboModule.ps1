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

        # Invoke-WebRequest is not available in PowerShell 2.0
        function Invoke-WebRequest20($url)
        {
            [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | Out-Null
            
            # Create request manually to avoid 'The server committed a protocol violation. Section=ResponseStatusLine'
            $request = [System.Net.HttpWebRequest]::Create($url)
            $request.ContentType = "application/json"
            $request.Method = "GET"
            $request.UserAgent = "Mozilla/5.0 (Windows NT 6.3; WOW64)"
            
            $response = $request.GetResponse()
            $streamReader = New-Object System.IO.StreamReader $response.GetResponseStream()
            try
            {
                $json = $streamReader.ReadToEnd()
                $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
                return $serializer.DeserializeObject($json)
            }
            finally
            {
                $streamReader.Dispose()    
            }
        }

        $webClient = New-Object System.Net.WebClient
        try
        {
            $fileItems = Invoke-WebRequest20 "https://api.github.com/repos/turboapps/turbome/contents/tools/powershell/Turbo"
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