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
