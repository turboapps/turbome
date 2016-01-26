# Close the main window of an application
# Used for applications which report taskill /im {processName} as crash
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Close-MainWindow
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
	    [string] $ProcessName
    )
    process
    {
        function Get-WindowProcesses
        {
            return (Get-Process | Where-Object {$_.Name -eq $ProcessName -and $_.MainWindowTitle -ne ''})
        }

        $processes = Get-WindowProcesses
        $counter = 1
        while(-not $processes -and $counter -lt 16)
        {
            $counter += 1
            Sleep -Seconds 1
            $processes = Get-WindowProcesses
        }

        if (-not $processes)
        {
            throw ("Failed to find $ProcessName process")
        }

        return $processes | ForEach { $_.CloseMainWindow() }
    }
}