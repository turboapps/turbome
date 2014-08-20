start "mysql" mysqld.exe

echo CREATE DATABASE wordpress;> spn_cmd.txt

:createDB
mysql -u root < spn_cmd.txt
IF %ERRORLEVEL% NEQ 0 GOTO createDB

mysqladmin.exe -u root shutdown