# Create a SQL Lab Suite content image
Content image provides content specific to the article for which the image is being created.
Typically this is a SQL script and a sample database, but could also other resources.
This document describes how to create a content image using a PowerShell script.

## Before you start
* Create a sample SQL Server database, detach it and copy to a separate directory
* Prepare a SQL script which should be executed in the demo
* Download `Build-ContentLayer.ps1` PowerShell script available on [GitHub](https://github.com/turboapps/turbome/blob/master/sqlserver/content-layer/Build-ContentLayer.ps1)
* Enable execution of PowerShell scripts. If execution of PowerShell scripts is disabled on your machine open PowerShell console as administrator and run Cmdlet `Set-ExecutionPolicy RemoteSigned`. RemoteSigned policy means that downloaded scripts must come from a trusted publisher. For more information about execution policies refer to Set-ExecutionPolicy Cmdlet documentation.

Tutorial section assumes that commands presented below are executed in the `C:\demo` working directory which contains 3 elements:
* `DATA` - directory with sample database files
* `script.sql` - SQL script with demo commands
* `Build-ContentLayer.ps1` - the PowerShell script downloaded before

Example
```
c:\demo>dir
 Volume in drive C has no label.
 Volume Serial Number is 3463-88A6

 Directory of c:\demo

12/14/2015  09:18 PM    <DIR>          .
12/14/2015  09:18 PM    <DIR>          ..
12/07/2015  05:37 PM            10,870 Build-ContentLayer.ps1
12/14/2015  03:06 PM    <DIR>          DATA
12/14/2015  02:15 PM               212 script.sql
               2 File(s)         11,082 bytes
               3 Dir(s)  104,580,628,480 bytes free

```

## Tutorial

Open PowerShell console in `c:\demo` working directory

```
c:\demo>powershell
Windows PowerShell
Copyright (C) 2014 Microsoft Corporation. All rights reserved.

PS c:\demo>
```

Run the PowerShell script to build an image with content layer in fully interactive mode. PowerShell script will ask to specify each required parameter. After successful build of the image, the script will stop and ask for permissions to execute a test run and push the image.

```
PS c:\demo> .\Build-ContentLayer.ps1
cmdlet Build-ContentLayer.ps1 at command pipeline position 1
Supply values for the following parameters:
(Type !? for Help.)
OutputImage: simpledemo
SqlFile: script.sql
DatabaseDir: DATA
Executing: turbo build --overwrite --name simpledemo build.me script.sql DATA
Using vm 11.8.751 from local
Step 0: copy script.sql C:\sql-content\script.sql
Using image clean:24 from local
Step 1: copy DATA C:\sql-content
Step 2: startup file (cmd.exe, /k, echo, It is a SQL Lab Suite content image int
ended to run with sqlserver/mssql2014-labsuite. Close the shell window and try '
turbo new <image-name>,sqlserver/mssql2014-labsuite')
Using image clean:24 from local
Committing container 07d24bb9 to image simpledemo (0%)
Committing container 07d24bb9 to image simpledemo
Commit complete
Output image: simpledemo
Removed intermediate container 07d24bb9c6314fcb8a497ee57b1ad57d
```
```
Run Image
Would you like to run the image now?
[Y] Yes  [N] No  [?] Help (default is "Y"): Y
Executing: turbo try SimpleDemo,mssql2014-labsuite
Using vm 11.8.751 from local
Using image clean:24 from local
Using image vcredist:2008 from local
Using image simpledemo from local
Using image mssql2014-labsuite:3 from local
Running new container 0fe37b34 with visibility private
Process exited with status 0
```
```
Push Image
Would you like to push the image to the Turbo Hub?
[Y] Yes  [N] No  [?] Help (default is "Y"): Y
Provide name of the remote image or press [Enter] if defaults are ok: sqlservercentral/simpledemo:1.0
```
```
Executing: turbo push SimpleDemo sqlservercentral/simpledemo:1.0
Using image simpledemo from local
Pushing image SimpleDemo to sqlservercentral/simpledemo:1 (0%)
Pushing image SimpleDemo to sqlservercentral/simpledemo:1 (0%; 0.00B of 64.2KB)
Pushing image SimpleDemo to sqlservercentral/simpledemo:1 (8%; 5.28KB of 64.2KB)
Pushing image SimpleDemo to sqlservercentral/simpledemo:1
Push complete
Image is public
You may visit repo page https://turbo.net/hub/sqlservercentral/simpledemo in Turbo Hub and update image metadata
PS C:\demo>
```

The script built a content layer image using `script.sql` file and a sample database from `DATA` directory. The output image was saved in the local repository as `simpledemo`. After successful build the PowerShell script executed a test run.

As soon as SQL Management Studio was closed the script asked if the image should have been published to the Turbo Hub. Finally, image was pushed to the `simpledemo` repository in `sqlservercentral` organization with tag `1:0`.

The PowerShell script can also be executed in non-interactive mode by passing required parameters in command line.

```
PS C:\demo> .\Build-ContentLayer.ps1 -SqlFile script.sql -DatabaseDir DATA -OutputImage simpledemo -DeclineRun -ConfirmPush -RemoteImage 'sqlservercentral/simpledemo:2.0'
Executing: turbo build --overwrite --name simpledemo build.me script.sql DATA
Using vm 11.8.751 from local
Step 0: copy script.sql C:\sql-content\script.sql
Using image clean:24 from local
Step 1: copy DATA C:\sql-content
Step 2: startup file (cmd.exe, /k, echo, It is a SQL Lab Suite content image int
ended to run with sqlserver/mssql2014-labsuite. Close the shell window and try '
turbo new <image-name>,sqlserver/mssql2014-labsuite')
Using image clean:24 from local
Committing container 3c070a39 to image simpledemo (0%)
Committing container 3c070a39 to image simpledemo
Commit complete
Output image: simpledemo
Removed intermediate container 3c070a39571f473799852f215202743f
Executing: turbo push simpledemo sqlservercentral/simpledemo:2.0
Using image simpledemo from local
Pushing image simpledemo to sqlservercentral/simpledemo:2 (0%)
Pushing image simpledemo to sqlservercentral/simpledemo:2 (0%; 0.00B of 64.2KB)
Pushing image simpledemo to sqlservercentral/simpledemo:2 (8%; 5.28KB of 64.2KB)
Pushing image simpledemo to sqlservercentral/simpledemo:2
Push complete
Image is public
You may visit repo page https://turbo.net/hub/sqlservercentral/simpledemo in Turbo Hub and update image metadata
PS C:\demo>
```