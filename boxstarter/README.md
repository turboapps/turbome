# Boxstarter

Project website: http://boxstarter.org/

## Limitations
This image is mostly a working POC to see how boxstarter can work with turbo containers. Container reboots are not possible and reboot the host and several chocolatey packages fail for various reasons. However many will work and Boxstarter will allow you to install packages from a gist if you do not want to create a package.

Version: 2.4.88

## Prerequisites 
.net 4 or higher on the host or base container. This is preinstalled on Windows 8 and Server 2012.

To build: 
Builds and `turbo run` must be performed from an admin command console or the Boxstarter console will fail to load.

```
        turbo build -n=boxstarter /path/to/turbo.me
```
To install a Boxstarter package into your container from the Chocolatey or Myget Boxstarter repository:

```
		turbo run boxstarter
		Install-BoxstarterPackage -PackageName console2
```

To install a Boxstarter package into your container from a html/text HTTP resource such as gist.github.com:

```
		turbo run boxstarter
		Install-BoxstarterPackage -PackageName http://<URL>
```
