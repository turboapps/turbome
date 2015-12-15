# Create a SQL Lab Suite content image
Content image provides content specific to the article for which the image is being created.
Typically this is a SQL script and a sample database, but could also other resources.
This document describes how to create a content image using a PowerShell script.
For example content images visit [SQL Server Central](https://turbo.net/hub/sqlservercentral) repository in the Turbo Hub.

## Before you start
* Create a sample SQL Server database, detach it and copy to a separate directory
* Prepare a SQL script which should be executed in the demo
* Download `Build-ContentLayer.ps1` PowerShell script available on [GitHub](https://github.com/turboapps/turbome/blob/master/sqlserver/content-layer/Build-ContentLayer.ps1)
* Enable execution of PowerShell scripts on the host machine. If execution of PowerShell scripts is disabled, open PowerShell console as administrator and run `Set-ExecutionPolicy RemoteSigned` Cmdlet.
RemoteSigned policy prohibits running downloaded scripts unless they come from a trusted publisher.
For more information about execution policies refer to [Set-ExecutionPolicy Cmdlet](https://technet.microsoft.com/en-us/library/ee176961.aspx) documentation.

Tutorial section assumes that commands presented below are executed in the `C:\demo` working directory which contains 3 elements:
* `DATA` - directory with a sample database
* `script.sql` - SQL script to run the demo
* `Build-ContentLayer.ps1` - the PowerShell script downloaded before

### Example
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

* Open PowerShell console in `c:\demo` working directory

```
c:\demo>powershell
Windows PowerShell
Copyright (C) 2014 Microsoft Corporation. All rights reserved.

PS c:\demo>
```

* Run the PowerShell script to build an image with content layer.

The script will be executed in a fully interactive mode.
If a parameter is required, the script will stop and print a question asking a user to provide it.
The script can also be run in a batch mode without interruptions.
An example of such run is presented at the end of this section.

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

The script built a content layer image using `script.sql` file and a sample database from `DATA` directory. The output image was saved in the local repository as `simpledemo`.

* Execute a test run.

After a successful build of the image, the script will stop and ask for permissions to perform a test run.
This step is optional and provided to enable final validation of the image.
The content layer will be executed in a container with the mssql2014-labsuite image which provides SQL Server 2014 Express and SQL Server Management Studio 2014.
The sample database will be automatically attached to the SQL Server instance during bootstrap.
Then the SQL Server Management Studio will be launched. The SQL script provided by the content layer will be opened in the current query window.
To complete the test run close the SQL Server Management Studio.

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

* Publish the image to the Turbo Hub.

After a test run, the PowerShell script will stop and ask for permissions to push the content layer to the remote repository.
This step is optional. If a push is performed, the image will be available to run from the website.

```
Push Image
Would you like to push the image to the Turbo Hub?
[Y] Yes  [N] No  [?] Help (default is "Y"): Y
Provide name of the remote image or press [Enter] if defaults are ok: sqlservercentral/simpledemo:1.0
```
```
Executing: turbo push simpledemo sqlservercentral/simpledemo:1.0
Using image simpledemo from local
Pushing image simpledemo to sqlservercentral/simpledemo:1 (0%)
Pushing image simpledemo to sqlservercentral/simpledemo:1 (0%; 0.00B of 64.2KB)
Pushing image simpledemo to sqlservercentral/simpledemo:1 (8%; 5.28KB of 64.2KB)
Pushing image simpledemo to sqlservercentral/simpledemo:1
Push complete
Image is public
You may visit repo page https://turbo.net/hub/sqlservercentral/simpledemo in Turbo Hub and update image metadata
PS C:\demo>
```

The image was pushed to the `simpledemo` repository in `sqlservercentral` organization with tag `1:0`.

Finally, you may follow the hyperlink printed in the script output to visit the repository page in the Turbo Hub. 

### Batch mode

The PowerShell script allows to pass required parameters in a command line. If a parameter is specified beforehand, the script will not stop execution and ask to provide it.

The example below builds a content layer image and pushes it to a remote repository without performing a test run.

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

For more information about command line syntax use `Get-Help` Cmdlet.

```
PS C:\demo> Get-Help .\Build-ContentLayer.ps1

NAME
    C:\demo\Build-ContentLayer.ps1

SYNOPSIS
    Script builds content layer images for SQL Server 2014 Lab Suite.


SYNTAX
    C:\demo\Build-ContentLayer.ps1 [-OutputImage] <String> [-SqlFile] <String>
    [-DatabaseDir] <String> [-ConfirmRun] [-DeclineRun] [-ConfirmPush]
    [-DeclinePush] [[-RemoteImage] <String>] [<CommonParameters>]
```

