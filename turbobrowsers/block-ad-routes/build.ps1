# Build turbobrowsers/block-ad-routes image
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

[CmdletBinding()]
param
(
[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
[string] $name,
[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
[string] $title,
[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
[string] $dir
)

 $routesFile = "$PSScriptRoot\$dir\routes.txt"
 $scriptFile = "$PSScriptRoot\turbo.me" 

 & turbo build --route-file=$routesFile --overwrite $scriptFile $name $title | Write-Host