
function Stop-JenkinsJob {
    Invoke-WebRequest -Uri "$env:BUILD_URL/stop" -Method POST
}


Export-ModuleMember -Function 'Stop-JenkinsJob'