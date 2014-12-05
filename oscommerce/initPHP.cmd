REM Copy php.ini file from template
copy c:\php\php.ini-production c:\php\php.ini

REM Uncomment extension directory and give full path. Cannot use relative path unless you start apache from the php directory (it's relative to where you start the process from).
fart -C c:\php\php.ini "; extension_dir = \"ext\"" "extension_dir = \"c:/php/ext\""  & ver > nul

REM uncomment requirement extension
fart c:\php\php.ini ";extension=php_mysql.dll" "extension=php_mysql.dll"  & ver > nul
fart c:\php\php.ini ";extension=php_gd2.dll" "extension=php_gd2.dll"  & ver > nul
fart c:\php\php.ini ";extension=php_curl.dll" "extension=php_curl.dll"  & ver > nul
fart c:\php\php.ini ";extension=php_openssl.dll" "extension=php_openssl.dll"  & ver > nul