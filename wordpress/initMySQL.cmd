start "mysql" mysqld.exe

echo CREATE DATABASE wordpress;> spn_cmd.txt

mysql -u root < spn_cmd.txt

mysqladmin.exe -u root shutdown