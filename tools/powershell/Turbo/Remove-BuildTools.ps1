 function Remove-BuildTools
 {
    process
    {
        $pathsToDelete = @("${env:APPDATA}\Nuget", "${env:ProgramData}\chocolatey", "${env:LOCALAPPDATA}\Nuget", "C:\Python34") | Where-Object { Test-Path $_ } 
        Foreach($path in $pathsToDelete)
        {
            Remove-Item $path -Recurse -Force 
        }
    }
 }
