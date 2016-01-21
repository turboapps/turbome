# Declares functions and scripts inluded in Turbo module
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$cmdlets =  Get-ChildItem -Path @("$PSScriptRoot\Remove-BuildTools.ps1", "$PSScriptRoot\Get-LatestChocoVersion.ps1") -ErrorAction SilentlyContinue
Foreach($cmdlet in $cmdlets)
{
    Try
    {
        . $cmdlet.Fullname
        Export-ModuleMember -Function $cmdlet.Basename
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($cmdlet.fullname): $_"
    }
}

. $PSScriptRoot\XAPPL.ps1
