echo "Starting Jetty"
echo "Jetty home: %JETTY_HOME%"
echo "Web apps are in: %WEB_APPS%"

IF "%WAR_FILE%"=="" GOTO start-jetty
echo "Coping %WAR_FILE% to %WEB_APPS%"
xcopy %WAR_FILE% %WEB_APPS%




:start-jetty
cd %JETTY_HOME%
"%JAVA_HOME%/bin/java" -jar %JETTY_HOME%/start.jar 