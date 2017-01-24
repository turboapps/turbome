@echo off
echo Preparing PostgreSQL
echo PostgreSQL home: %%POSTGRESQL%=%POSTGRESQL%
echo Data is stored in: %%PGDATA%%=%PGDATA%
echo If the folder doesn't exist, a new db will be created there
echo Alternative, mount a external folder to %PGDATA%, to store the data outside the container
echo Like turbo run --mount C:\my-data-folder=%PGDATA%
echo Default username and password are: postgres postgres
echo If you don't want to start the db, but have a command line
echo Use the --startup-file=cmd option
echo PostgreSQL uses default port: 5432

if not exist %PGDATA% (
  mkdir %PGDATA%
)

set LANG=en

cd %TEMP% 

if not exist %PGDATA%\PG_VERSION (
  echo postgres>tmp-pwd.file
  initdb --locale=en-us -U postgres -A password -E utf8 --pwfile=tmp-pwd.file
  del tmp-pwd.file
)
cd %PGDATA%

echo Starting DB now

postgres -D %PGDATA%