# Cmdlets used by TurboScript and snapshot scripts
# Module should be saved on host machine in %SystemRoot%\system32\WindowsPowerShell\v1.0\Modules\Turbo directory

function Get-LatestChocoPackageVersion($packageName)
{
    $versions = (& choco list $packageName | Where-Object {$_ -match "(?<version>\d+(:?\.\d+)+)"} | Select-Object -InputObject {$Matches['version']})
    if($versions)
    {
        if($versions.Count -gt 1)
        {
            throw "More than one version is available: $packageName"
        }
        return $versions
    }
    throw "No versions available for package: $packageName"
}

Export-ModuleMember -Function 'Get-LatestChocoPackageVersion'