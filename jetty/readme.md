Jetty Spoon Container
================
Jetty Servlet container, of http://www.eclipse.org/jetty/

# Running It.
Just type `spoon run jetty`, and Jetty will start at port 8080.
# Run War File
The war files are expected in %WEB_APPS% (C:\Jetty\webapps). Copy your war file to there.
Alternatively you can map a folder containing your war files to that folder: `spoon run --mount C:\my-wars=C:\Jetty\webapps jetty/jetty`

# Base Image
You can use this as a base image. Copy you war-file or context file to the location defined by %WEB_APPS%.

# Enviroment
WEB_APPS => Folder where the web apps reside
JETTY_HOME => Folder where Jetty resides

#Build It
You can build this image with `spoon build spoon.me`