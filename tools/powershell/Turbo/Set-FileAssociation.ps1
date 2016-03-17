# Set file association
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Set-FileAssociation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True)]
        [string] $Name,
        [Parameter(Mandatory=$True)]
        [string[]] $Extensions
    )
    process
    {
        $regPath = "HKCU:\Software\Classes\{0}"
	    foreach($extension in $Extensions)
	    {
		    $key = $regPath -f $extension
            if(-not (Test-Path $key))
            {
                New-Item -Path $key -ItemType RegistryKey -Force
            }
		    Set-ItemProperty -path $key -name '(Default)' -value $Name
	    }
    }
}