[CmdletBinding()]
param
(
	[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Name of the output image")]
	[string] $OutputImage,
	[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Path to the SQL script")]
	[string] $SqlFile,
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Path to the database directory")]
    [string] $DatabaseDir,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Confirm test run")]
    [switch] $ConfirmRun,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Decline test run")]
    [switch] $DeclineRun,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Confirm image push")]
    [switch] $ConfirmPush,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Decline image push")]
    [switch] $DeclinePush,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Name of the image in the Turbo Hub")]
    [string] $RemoteImage
)

$TurboCmd = 'turbo'

<#
Prints clean output from Turbo CMD filtering out empty strings, removing spinning progress marquee (\|/-) and duplicate lines
#>
$global:lastOutput = $null
function Write-ProcessOutput
{
    param
    (  
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [AllowEmptyString()]
        [string]$Output
    )
    process
    {
        if(-not $Output)
        {
            return
        }

        $outputToUse = $Output -replace '[\\\/|\-]$', ''
        if($global:lastOutput -eq $outputToUse)
        {
            return
        }
        
        Set-Variable -Name 'lastOutput' -Value $outputToUse -Scope Global
        Write-Host $outputToUse -ForegroundColor Gray 
    }
}

function Assert-ZeroExitCode($exitCode)
{
    if($exitCode -ne 0)
    {
        throw "Error: Process returned non-zero exit code: $exitCode"
    }
}

function Should-Ask($decision)
{
    return $decision -eq $null
}

function Ask-Question($caption, $question, $defaultChoice)
{
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($caption, $question, $choices, $defaultChoice) 

    switch ($result)
    {
        0 { return $True }
        1 { return $False }
    }
}

function Check-RuntimeRequirements()
{
    Try
    {
        & $TurboCmd version | Out-Null
    }
    Catch
    {
        throw "Error: Turbo is not installed on host machine. "
    }

    # Not checking if .Net Framework is installed, because Turbo CMD requires.Net 4.0
    # According to MSDN the script is not calling API higher than .Net 2.0
}

function Build($config)
{
    $initialLocation = $pwd.Path
    Try
    {
        $tempDirName = [System.Guid]::NewGuid().ToString()
        Set-Location $env:temp
        $tempDir = New-Item -Type Directory -Name $tempDirName
        
        Try
        {
            Set-Location $tempDir
            Copy-Item -Path $config.SqlFile -Destination ([System.IO.Path]::Combine($tempDir.FullName, 'script.sql'))
            
            $tempDatabaseDir = New-Item -ItemType Directory -Name 'DATA'
            ForEach ($extension in '*.mdf', '*.ldf')
            {
                Get-ChildItem -Path $config.DatabaseDir -Filter $extension | Copy-Item -Destination $tempDatabaseDir
            }

            Invoke-WebRequest 'https://raw.githubusercontent.com/turboapps/turbome/master/sqlserver/content-layer/build.me' -OutFile "$tempDir\build.me"
            
            Write-Host "Executing: $TurboCmd build --overwrite --name $($config.OutputImage) build.me script.sql DATA"
            & $TurboCmd build --overwrite --name $config.OutputImage build.me script.sql DATA | Write-ProcessOutput
            Assert-ZeroExitCode $LASTEXITCODE
        }
        Finally
        {
            Set-Location $env:temp
            
            Try
            {
                Remove-Item -Recurse $tempDirName
            }
            Catch
            {
                # Use Write-Warning when moving to PowerShell 3.0
                Write-Host ("Failed to delete temp directory {0}: {1}" -f $tempDir.FullName, $_.Exception.Message) -ForegroundColor Yellow
            }
        }
    }
    Finally
    {
        Set-Location $initialLocation
    }
}

function Run($config)
{
    $executeRun = $config.ConfirmRun
    if($executeRun -eq $null)
    {
        $executeRun = Ask-Question 'Run Image' 'Would you like to run the image now?' 0
    }
    
    if($executeRun)
    {
        Write-Host "Executing: $TurboCmd try $($config.OutputImage),mssql2014-labsuite"
        & $TurboCmd try "$($config.OutputImage),mssql2014-labsuite" | Write-ProcessOutput
    }
}

function Get-RepoLink($image)
{
    if($image -notMatch "^((?<namespace>[^\s\/]+)\/)?(?<name>[^\s:]+)")
    {
        return $null
    }

    $name = $matches.name
    $namespace = $matches.namespace
    if(-not $namespace)
    {
        try
        {
            $loginLine = & $TurboCmd login | Select-String -Pattern "^[^\s]+\s+logged" | Select-Object -First 1
            if($loginLine -match "^(\S+)")
            {
                $namespace = $matches[0]
            }
        }
        catch { }
    }
    if(-not $namespace)
    {
        return $null  
    }

    return "https://turbo.net/hub/$namespace/$name"
}

function Push($config)
{
    $remoteImage = $config.RemoteImage

    $executePush = $config.ConfirmPush
    if(Should-Ask $executePush)
    {
        $executePush = Ask-Question 'Push Image' 'Would you like to push the image to the Turbo Hub?' 0

        if(-not $executePush)
        {
            return
        }

        if(-not $remoteImage)
        {
            $remoteImage = Read-Host -Prompt 'Provide name of the remote image or press [Enter] if defaults are ok'
        }
    }
    elseif(-not $executePush)
    {
        return
    }

    $pushParams = $config.OutputImage
    if($remoteImage)
    {
        $pushParams = -join $pushParams, ($remoteImage.Trim())
    }
    
    Write-Host "Executing: $TurboCmd push $pushParams"
    & $TurboCmd push $pushParams | Write-ProcessOutput
    Assert-ZeroExitCode $LASTEXITCODE

    if(-not $remoteImage)
    {
        $remoteImage = $config.OutputImage
    }
    $repoLink = Get-RepoLink $remoteImage
    if($repoLink)
    {
        Write-Host "You may visit repo page $repoLink in Turbo Hub and update image metadata"
    }
}

$sqlFileExists = Test-Path $SqlFile
if(-not $sqlFileExists)
{
    Write-Error "Error: Script file '$SqlFile' was not found"
    Exit -1
}

$databaseDirExists = Test-Path $DatabaseDir
if(-not $databaseDirExists)
{
    Write-Error "Error: Database directory '$DatabaseDir' was not found"
    Exit -1
}

function Get-Decision($confirm, $decline)
{
    $decision = $null
    if($confirm.IsPresent) { $decision = $True }
    if($decline.IsPresent) { $decision = $False }
    return $decision
}

$config = New-Object -TypeName PsObject -Property (@{
    'OutputImage' = $OutputImage;
    'SqlFile' = (Get-Item $SqlFile | % { $_.FullName });
    'DatabaseDir'= (Get-Item $DatabaseDir | % { $_.FullName });
    'ConfirmRun' = (Get-Decision $ConfirmRun $DeclineRun);
    'ConfirmPush' = (Get-Decision $ConfirmPush $DeclinePush) -or $RemoteImage;
    'RemoteImage' = $RemoteImage;
})

Try
{
    Check-RuntimeRequirements
    
    Build $config
    Run $config
    Push $config
}
Catch
{
    Write-Error $_.Exception.Message
    Write-Error $_.Exception.StackTrace
    Exit -1
}