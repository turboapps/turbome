# Extract the latest version of a file
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Get-FileVersion
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
	    [string] $Path,
        [Parameter(HelpMessage="Allows to extract version from different file metadata. Supported values are: FileVersion, Comments")]
        [string] $Source = 'FileVersion'
    )
    process
    {
        if($Source -like 'FileVersion')
        {
            $versionInfo = (Get-Item -Path $Path).VersionInfo
            return ("{0}.{1}.{2}.{3}" -f $versionInfo.FileMajorPart, 
                $versionInfo.FileMinorPart, 
                $versionInfo.FileBuildPart, 
                $versionInfo.FilePrivatePart)
        }
        elseif($Source -like 'Comments')
        {
            $path = (Get-ChildItem $Path).FullName
            $shell = New-Object -COMObject Shell.Application
            $folder = Split-Path $path
            $file = Split-Path $path -Leaf
            $shellfolder = $shell.Namespace($folder)
            $shellfile = $shellfolder.ParseName($file)

            $CommentsKey = 0..287 | Where-Object { $shellfolder.GetDetailsOf($null, $_) -eq "Comments" }
            $comment = $shellfolder.GetDetailsOf($shellfile, $CommentsKey)
            if(-not ($comment -match '(?<version>\d+(?:\.\d+){3})')) {
                throw "Failed to extract version number"
            }

            return $Matches['version']
        }
        
        throw "Uknown Source: $Source"
    }
}