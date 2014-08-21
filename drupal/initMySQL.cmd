start "mysql" mysqld.exe

echo CREATE DATABASE drupal;> spn_cmd.txt

:createDB
mysql -u root < spn_cmd.txt
IF %ERRORLEVEL% NEQ 0 GOTO createDB

del spn_cmd.txt
mysqladmin.exe -u root shutdown