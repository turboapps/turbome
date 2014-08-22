@ECHO OFF
ECHO Starting mysql...
start "mysqld" "%spn_mysqld%"
ECHO Starting apache...
start "apache" "%spn_apache%"
ECHO Visit http://localhost:%spn_config_Port%/install/index.php to configure osCommerce, if you haven't already.
ECHO ON