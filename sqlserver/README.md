# Create SQL Lab Suite images

Repo contains source files required to build images for SQL Lab Suite.

## SQL Server 2014 Lab Suite
[mssql2014-labsuite](https://turbo.net/hub/sqlserver/mssql2014-labsuite) provides a complete environment to run example SQL scripts. It includes preconfigured SQL Server 2014 Express and SQL Server Management Studio 2014.
Detailed instructions how to build the image can be found on the team wiki.

## Content Layer
Content layer provides content specific to the article for which the image is being created. Typically this is a SQL script and a sample database, but could also other resources.

Build a content layer image with a SQL file and a sample database
```
turbo build content-layer\build.me <path to SQL file> <path to directory with database sample>
```

Example
```
> turbo build --overwrite build.me "Wildcard Searches.sql" DATA
Using vm 11.8.740 from local
Step 0: meta namespace="sqldemo"
Step 1: meta name="article"
Step 2: meta tag="1.0.test"
Step 3: meta title="Article Name"
Step 4: meta description="Short description"
Step 5: meta publisher="Author"
Step 6: meta website="Link to the article"
Step 7: meta version="1.0.dateiso"
Step 8: copy Wildcard Searches.sql C:\sql-content\script.sql
Using image clean:24 from local
Step 9: copy DATA C:\sql-content\
Step 10: startup file (cmd.exe, /k, echo, It is a SQL Lab Suite content image intended to run with sqlserver/mssql2014-labsuite. Close the shell window and try 'turbo new <image-name>,sqlserver/mssql2014-labsuite')
Committing container c506178c to image sqldemo/article:1.0.test
Commit complete
Output image: sqldemo/article:1.0.test
Removed intermediate container c506178c7f3048439d9cbd51b0db3b57
```

Run the content layer with SQL Server Lab Suite
```
turbo new <content layer>,sqlserver/mssql2014-labsuite --route-block=tcp
```

Containerized SQL Server is running on the default TCP port 1433. Using route-block prevents conflicts with a local SQL Server instance. 

Example
```
> turbo new sqldemo/article:1.0.test,sqlserver/mssql2014-labsuite --route-block=tcp
Using vm 11.8.740 from local
Using image clean:24 from local
Using image vcredist:2008 from local
Using image article:1.0.test from local
Using image mssql2014-labsuite from local
Running new container ded5d461 with visibility public (use --private for a private container)
```

For more examples check samples folder.