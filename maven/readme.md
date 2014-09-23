Apache Maven Spoon Container
================
Apache Maven build tool, see http://maven.apache.org

# Running It.
Just type `spoon run maven`. A window will open, where the `maven` command is available.


# Enviroment
JAVA_HOME => The JDK installation used
MAVEN_HOME => Where Maven resides

#Build Stable Version
Firt, define the version you want to use with `set VERSION=[Version-Number]`, then run the back file `build.bat`. Example:

	set VERSION=3.2.3
	build.bat

The image will be named `maven:[Version-Number]`, like `maven:3.2.3`

#Build Local Version
The `local-spoon.me` picks up Maven from the directory `./dist`. It is intended for continues builds, where the previous step left the Maven distribution in `./dist`