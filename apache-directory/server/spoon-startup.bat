@echo off
echo "Soon will start up ApacheDS"
echo "If you want to store the data outside the container,"
echo "Please mount the C:\ApacheDB\instances"
echo "Example spoon run --mount C:\DataOnHost=C:\ApacheDB\instances"
echo "If you don't want to launch the container, but manipulate config files"
echo "Use --startup-file=cmd to get a command prompt"
echo "Default port will be 10389"
echo "Default admin is: uid=admin,ou=system  Password: secret"

set PATH=%PATH%;%JAVA_HOME%/bin

rem Restore instances
if not exist "C:\ApacheDS\instances" mkdir C:\ApacheDS\instances\
for /F %%i in ('dir /b /a "C:\ApacheDS\instances\*"') do (
    echo "Found existing data in instances"
    goto launch
)
rem Workaround for spoon bug
7z x instances.7z

:launch
cd C:\ApacheDS\bin\
C:\ApacheDS\bin\apacheds.bat