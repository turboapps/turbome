iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
& Start-Sleep -s 90 
& refreshenv 
& choco install dotnet4.5.2 -y
