@echo off

if exist "C:\init-scripts\attach_db_executed" goto :eof

echo.>"C:\init-scripts\attach_db_executed"

set TurboLogin="sa"
set TurboPassword="password1"
set TurboQuery="\\.\pipe\MSSQL$SQLEXPRESS\sql\query"

set TurboDbName=""
set TurboDbFile=""
set TurboLogFile=""
set TurboDataPattern=""
set TurboSqlCmd=""

if "%programfiles(x86)%" == "" (
    set TurboDataPattern="%programfiles%\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\*.mdf"
    set TurboSqlCmd="%programfiles%\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\sqlcmd.exe"
) else (
    set TurboDataPattern="%programfiles(x86)%\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\*.mdf"
    set TurboSqlCmd="%programfiles(x86)%\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\sqlcmd.exe"
)

echo Looking for databases to attach...

for %%f in (%TurboDataPattern%) DO CALL :loopbody "%%f"
GOTO :eof

:loopbody
set TurboDbName=%~n1
set TurboDbFile=%1
set TurboLogFile="%~d1%~p1%~n1_log.ldf"

if "%TurboDbName%"=="master" goto :skip
if "%TurboDbName%"=="model" goto :skip
if "%TurboDbName%"=="MSDBData" goto :skip
if "%TurboDbName%"=="tempdb" goto :skip

echo Attaching %TurboDbName%

set TurboSqlScript=""

if exist %TurboLogFile% (    
   set TurboSqlScript="C:\init-scripts\attach_with_log.sql"
) else (
   set TurboSqlScript="C:\init-scripts\attach_no_log.sql"
)

set repeats=0
:attach_db_loop

%TurboSqlCmd% -S %TurboQuery% -U %TurboLogin% -P %TurboPassword% -b -V16 -e -r1 -m-1 -l 180 -t 180 -i %TurboSqlScript% -o "C:\init-scripts\sqlcmd_out.log"

if %ERRORLEVEL% EQU 0 goto :eof
if %repeats% GEQ 5 goto :eof
set /a repeats+=1
timeout /t 1
goto: attach_db_loop

:skip
echo Skipping %TurboDbName%

goto :eof