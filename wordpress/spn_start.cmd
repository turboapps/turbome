@ECHO OFF
ECHO Starting mysql...
start "mysqld" "%spn_mysqld%"
ECHO Starting apache...
start "apache" "%spn_apache%"
ECHO Visit http://localhost:%spn_config_Port% to configure WordPress, if you haven't already.
ECHO ON