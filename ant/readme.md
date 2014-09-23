Apache Ant Spoon Container
================
Apache Ant build tool, see http://ant.apache.org

# Running It.
Just type `spoon run ant`. A window will open, where the `ant` command is available.


# Enviroment
JAVA_HOME => The JDK installation used
JAVACMD => The Java executable used by Ant
ANT_HOME => Where Ant resides

#Build Stable Version
Firt, define the version you want to use with `set VERSION=[Version-Number]`, then run the back file `build.bat`. Example:

	set VERSION=1.9.4
	build.bat

The image will be named `ant:[Version-Number]`, like `ant:1.9.4`

#Build Local Version
The `local-spoon.me` picks up Ant from the directory `./dist`. It is intended for continues builds, where the previous step left the ant distribution in `./dist`