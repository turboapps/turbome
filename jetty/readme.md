Jetty Spoon Container
================
Jetty Servlet container, of http://www.eclipse.org/jetty/

# Running It.
Just type `spoon run jetty`, and Jetty will start at port 8080.
# Run War File
Just type `spoon run jetty my-war.war`, Jetty will start and your web app available at port 8080, /my-war.

# Base Image
You can use this as a base image. Copy you war-file or context file to the location defined by %WEB_APPS%.

# Enviroment
WEB_APPS => Folder where the web apps reside
JETTY_HOME => Folder where Jetty resides

#Build It
You can build this image with `spoon build spoon.me`