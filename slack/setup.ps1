# Slack setup script 
# https://github.com/turboapps/turbome/tree/master/slack 
# 
 
Import-Module Turbo 
$version = (Get-LatestChocoVersion -Package slack) 
"slack/slack:$version" | Set-Content image.txt 
 here
