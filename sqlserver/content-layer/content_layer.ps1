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

function PrintFatal($errorMsg)
{
    Write-Host $errorMsg -ForegroundColor Red
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

            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile('https://raw.githubusercontent.com/turboapps/turbome/master/sqlserver/content-layer/build.me', "$tempDir\build.me")

            & "turbo.exe" build --overwrite --name $config.OutputImage build.me script.sql DATA
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

$sqlFileExists = Test-Path $SqlFile
if(-not $sqlFileExists)
{
    PrintFatal "Script file '$SqlFile' was not found"
    Exit -1
}

$databaseDirExists = Test-Path $DatabaseDir
if(-not $databaseDirExists)
{
    PrintFatal "Database directory '$DatabaseDir' was not found"
    Exit -1
}

$config = New-Object -TypeName PsObject -Property (@{
    'OutputImage' = $OutputImage;
    'SqlFile' = (Get-Item $SqlFile | % { $_.FullName });
    'DatabaseDir'= (Get-Item $DatabaseDir | % { $_.FullName });
})  

Try
{
    Build $config
}
Catch
{
    PrintFatal $_.Exception.Message
    PrintFatal $_.Exception.StackTrace
    Exit -1
}