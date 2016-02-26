# Builds routes.txt file
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

[CmdletBinding()]
param
(
[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
[string] $dir
)

$hostnamesFile = "$PSScriptRoot\$dir\hostnames.txt"
$routesFile = "$PSScriptRoot\$dir\routes.txt"
$scriptFile = "$PSScriptRoot\generate-routes.py"

& turbo try --isolate=merge python -- python $scriptFile --input-file $hostnamesFile --output-file $routesFile