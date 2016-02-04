# Declares functions and scripts inluded in Turbo module
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$cmdlets = @(
    "$PSScriptRoot\Close-MainWindow.ps1",
    "$PSScriptRoot\Get-LatestChocoVersion.ps1",
    "$PSScriptRoot\Get-FileVersion.ps1",
    "$PSScriptRoot\Get-NextTag.ps1",
    "$PSScriptRoot\Remove-BuildTools.ps1",
    "$PSScriptRoot\Set-JsonPreference.ps1",
    "$PSScriptRoot\Update-AdBlock.ps1")
Foreach($cmdlet in (Get-ChildItem -Path $cmdlets -ErrorAction SilentlyContinue))
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
. $PSScriptRoot\ScheduledTasks.ps1
