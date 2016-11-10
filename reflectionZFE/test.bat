set FF=%programfiles(x86)%\Mozilla Firefox\firefox.exe
IF EXIST run.txt (
"%FF%" C:\MSS\utilities\AdministrativeWebStation.html
) ELSE (
sc stop "Micro Focus MSS Server"
START /WAIT C:\MSS\utilities\bin\InitialConfigurationUtility.exe
type NUL>run.txt
sc start "Micro Focus MSS Server"
cd %programfiles(x86)%\Mozilla Firefox
START /WAIT firefox C:\ZFEInstaller\manual.html C:\MSS\utilities\AdministrativeWebStation.html
C:\ZFEInstaller\reflectionzfe-2.0.0.51-windows-x64.exe -q -c -varfile C:\ZFEInstaller\response.varfile
firefox C:\MSS\utilities\AdministrativeWebStation.html
)


