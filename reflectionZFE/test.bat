IF EXIST run.txt (
"C:\Program Files (x86)\Mozilla Firefox\firefox.exe" C:\MSS\utilities\AdministrativeWebStation.html
) ELSE (
sc stop "Micro Focus MSS Server"
START /WAIT C:\MSS\utilities\bin\InitialConfigurationUtility.exe
type NUL>run.txt
sc start "Micro Focus MSS Server"
cd "C:\Program Files (x86)\Mozilla Firefox"
START /WAIT firefox C:\ZFEInstaller\manual.html C:\MSS\utilities\AdministrativeWebStation.html
C:\ZFEInstaller\reflectionzfe-2.0.0.51-windows-x64.exe -q -c -varfile C:\ZFEInstaller\response.varfile
"C:\Program Files (x86)\Mozilla Firefox\firefox.exe" C:\MSS\utilities\AdministrativeWebStation.html
)


