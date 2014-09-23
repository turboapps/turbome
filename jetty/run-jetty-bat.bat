echo "Starting Jetty"
echo "Jetty home: %JETTY_HOME%"
echo "Web apps are in: %WEB_APPS%"

IF "%1"=="" GOTO start-jetty
echo "Coping %1 to %WEB_APPS%"
xcopy %1 %WEB_APPS%




:start-jetty
cd %JETTY_HOME%
"%JAVA_HOME%/bin/java" -jar %JETTY_HOME%/start.jar 