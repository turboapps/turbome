[CmdletBinding()]
param
(
	[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Name of the output image")]
	[string] $OutputImage,
	[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Path to the SQL script")]
	[string] $SqlFile,
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage="Path to the database directory")]
    [string] $DatabaseDir
)

$TurboCmd = 'turbo.exe'

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

            & $TurboCmd build --overwrite --name $config.OutputImage build.me script.sql DATA | Write-ProcessOutput
            if($LASTEXITCODE -ne 0)
            {
                throw "Error: Build returned exit code $LASTEXITCODE"
            }
        }
        Finally
        {
            Set-Location $env:temp
            Remove-Item -Recurse $tempDirName
        }
    }
    Finally
    {
        Set-Location $initialLocation
    }
}

function Run($config)
{
    $result = Ask-Question 'Run Image' 'Would you like to run the image now?' 0
    if(-not $result)
    {
        return
    }

    & $TurboCmd try ('{0},mssql2014-labsuite' -f $config.OutputImage) | Write-ProcessOutput
}

function Push($config)
{
    $result = Ask-Question 'Push Image' 'Would you like to push the image to the Turbo hub?' 0
    if(-not $result)
    {
        return
    }

    $remoteImageName = Read-Host -Prompt 'Provide name of the remote image or press [Enter] if defaults are ok'
    $pushParams = $config.OutputImage
    if($remoteImageName)
    {
        $pushParams = -join $pushParams, ' ', $remoteImageName
    }
    & $TurboCmd push $pushParams | Write-ProcessOutput
    if($LASTEXITCODE -ne 0)
    {
        throw "Error: Push returned exit code $LASTEXITCODE"
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

$config = New-Object -TypeName PsObject -Property (@{
    'OutputImage' = $OutputImage;
    'SqlFile' = (Get-Item $SqlFile | % { $_.FullName });
    'DatabaseDir'= (Get-Item $DatabaseDir | % { $_.FullName });
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