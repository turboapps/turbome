# Cmdlets wrappers for scheduled tasks
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

function Test-ScheduledTaskDefined
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $TaskName
    )
    process
    {
        return Get-ScheduledTask | Where-Object {$_.TaskName -like $TaskName}
    }
}

function Test-ScheduledTaskRunning
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $TaskName
    )
    process
    {
        return Get-ScheduledTask | Where-Object {$_.TaskName -like $TaskName -and $_.State -like "Running"}
    }
}

function Wait-ForScheduledTask
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $TaskName,
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $MaxCount = 16
    )
    process
    {
        $isTaskRunning = $false
        $counter = 0
        do
        {
            Sleep 1
            $counter += 1
            $isTaskRunning = Test-ScheduledTaskRunning $TaskName
        } while(($counter -lt $MaxCount) -and $isTaskRunning)
    
        if($isTaskRunning)
        {
            throw "$TaskName did not complete"
        }
    }
}

function Remove-ScheduledTask
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $TaskName
    )
    process
    {
        if(Test-ScheduledTaskDefined $TaskName)
        {
            return Unregister-ScheduledTask $TaskName -Confirm:$False
        }
        return $False
    }
}

function Start-ProcessInScheduledTask
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $TaskName,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $Path
    )
    process
    {
        $taskAction = New-ScheduledTaskAction -Execute $Path
        Register-ScheduledTask -Action $taskAction -TaskName $TaskName | Out-Null
        Start-ScheduledTask $TaskName
    }
}

function Wait-ForProcess
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $ProcessName,
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $MaxCount = 16
    )
    process
    {
        $counter = 0
        $isProcessRunning = $false
        while(($counter -lt $MaxCount) -and !$isProcessRunning)
        {
            Sleep 5
            $counter += 1
            $isProcessRunning = (Get-Process | Where-Object {$_.Name -eq $ProcessName}) -ne $null
        }
    
        throw "Process $ProcessName is not running"
    }
}

function Close-WindowProcessInScheduledTask
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $TaskName,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $ProcessName,
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string] $MaxCount = 16
    )
    process
    {
        function Test-ProcessRunning {
            return (Get-Process | Where-Object {$_.Name -eq $ProcessName}) -ne $null
        }

        if(-not (Test-ProcessRunning))
        {
            throw "Process $ProcessName is not running"
        }

        $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("(Get-Process | Where-Object {`$_.Name -eq `"$ProcessName`" -and `$_.MainWindowTitle -ne ''}).CloseMainWindow()"))
        $taskAction = New-ScheduledTaskAction -Execute PowerShell.exe -Argument "-EncodedCommand $encodedCommand"
        Register-ScheduledTask -Action $taskAction -TaskName $TaskName | Out-Null
    
        $counter = 0
        $isProcessRunning = $True
        while(($counter -lt $MaxCount) -and $isProcessRunning)
        {
            Sleep 5
        
            Start-ScheduledTask $TaskName
            Wait-ForScheduledTask $TaskName 60
        
            $counter += 1
            $isProcessRunning = Test-ProcessRunning
        }
        
        if($isProcessRunning)
        {
            throw "Failed to close $ProcessName"
        }
    }
}

Export-ModuleMember -Function 'Close-WindowProcessInScheduledTask'
Export-ModuleMember -Function 'Remove-ScheduledTask'
Export-ModuleMember -Function 'Start-ProcessInScheduledTask'
Export-ModuleMember -Function 'Test-ScheduledTaskDefined'
Export-ModuleMember -Function 'Test-ScheduledTaskRunning'
Export-ModuleMember -Function 'Wait-ForProcess'
Export-ModuleMember -Function 'Wait-ForScheduledTask'