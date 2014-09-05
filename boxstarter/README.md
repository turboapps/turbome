# Boxstarter

Project website: http://boxstarter.org/

Version: 2.4.88

Prerequisites: .net 4 or higher on the host or base container. This is preinstalled on Windows 8 and Server 2012.

To build: 

```
        spoon build -n=boxstarter /path/to/spoon.me
```
To install a Boxstarter package into your container from the Chocolatey or Myget Boxstarter repository:

```
		spoon run boxstarter
		Install-BoxstarterPackage -PackageName <packagename>
```

To install a Boxstarter package into your container from a html/text HTTP resource such as gist.github.com:

```
		spoon run boxstarter
		Install-BoxstarterPackage -PackageName http://<URL>
```
