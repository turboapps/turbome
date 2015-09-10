NuGet Turbo Container
================
NuGet build tool, see https://www.nuget.org

# Running It.
Just type `turbo run nuget`. A window will open, where the `nuget` command is available.

#Build Stable Version
Firt, define the version you want to use with `set VERSION=[Version-Number]`, then run the back file `build.bat`. Example:

	set VERSION=2.8.1
	build.bat

The image will be named `nuget:[Version-Number]`, like `nuget:2.8.1`

#Build Local Version
The `local-turbo.me` picks up NuGet directly from `.\nuget.exe`. It is intended for continues builds, where the previous step left nuget there.