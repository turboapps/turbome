@echo off
echo "Starting Jetty"
echo "Jetty home: %%JETTY_HOME%%=%JETTY_HOME%"
echo "Web apps are in: %%WEB_APPS%%=%WEB_APPS%"
echo "Any war in that location will be picked up"
echo "Alternative, mount the folder with our war files to %WEB_APPS%" 
echo "Like turbo run --mount C:\my-wars=C:\Jetty\webapps"

if not exist %WEB_APPS% mkdir %WEB_APPS%

echo "Current wars:"
dir %WEB_APPS%

cd %JETTY_HOME%
"%JAVA_HOME%/bin/java" -jar %JETTY_HOME%/start.jar 