echo. >> c:\Apache2\conf\httpd.conf
echo LoadModule php5_module "C:/php/php5apache2.dll">> c:\Apache2\conf\httpd.conf
echo AddHandler application/x-httpd-php .php>> c:\Apache2\conf\httpd.conf
echo PHPIniDir "C:/php">> c:\Apache2\conf\httpd.conf
%spn_fart% c:\Apache2\conf\httpd.conf "DirectoryIndex index.html index.html.var" "DirectoryIndex index.php index.html index.html.var" & ver > nul