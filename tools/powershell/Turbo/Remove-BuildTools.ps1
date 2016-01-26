# Performs cleanup of a container created using turbo/turboscript-tools
# Does not remove c:\TurboBuildTools which contains this script
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

 
 function Remove-BuildTools
 {
    process
    {
        $pathsToDelete = @(
            "${env:APPDATA}\Nuget",
            "${env:ProgramData}\chocolatey",
            "${env:LOCALAPPDATA}\Temp\Chocolatey",
            "${env:LOCALAPPDATA}\Nuget\Temp\Nuget",
            "${env:LOCALAPPDATA}\Nuget",
            "C:\Python34",
            "C:\wget",
            "C:\7-zip") 
        Foreach($path in ($pathsToDelete | Where-Object { Test-Path $_ }))
        {
            Remove-Item $path -Recurse -Force 
        }
    }
 }
