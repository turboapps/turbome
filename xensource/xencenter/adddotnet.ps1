$output = turbo images | Select-String -Pattern ("xensource/xencenter")
$output -match "(?<namespace>[a-zA-Z-_]*)/(?<appname>[a-zA-Z-_]*)\s+(?<version>[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)" 
$repo = $Matches['namespace']+"/"+$Matches['appname']+":"+$Matches['version']

$workspace = "C:\CI\workspace"
$xstudioDir = "C:\XStudio"
& turbo export --type=svm "$repo" "$workspace\xencenter.svm"
& "$xstudioDir\XStudio.exe" /import /i "$workspace\xencenter.svm" /o "$workspace\xencenter" /l "$xstudioDir\CodersStudioSP170License.txt"
$before = "<Dependencies />"
$after = '  <Dependencies>
    <Dependency Identifier="microsoft/dotnet:4.6.1" Hash="ae2d47a4bcc48a88a07c716725c85159ff6e3a8126fa667efb5cba5061bf808f" BakedIn="False" />
  </Dependencies>'
(Get-Content "$workspace\xencenter\Import.xappl" ).Replace($before,$after) | Out-File "$workspace\xencenter\Import.xappl" -Encoding UTF8
& "$xstudioDir\XStudio.exe" "$workspace\xencenter\Import.xappl" /o "$workspace\xencenter2.svm" /l "$xstudioDir\CodersStudioSP170License.txt"
& turbo import svm "$workspace\xencenter2.svm" --overwrite "-n=$repo"