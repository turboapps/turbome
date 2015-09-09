PostgreSQL
================
PostgreSQL container, of http://www.postgresql.org

# Getting Started
Just type `turbo run postgresql`, and PostgreSQL will start at the default port

    turbo run postgresql/postgresql
	
#Defaults
PostgreSQL uses default port: 5432
Default username and password are: postgres postgres

# Mount the data folder
The data folder is a C:\pg-data. If you want to mount it outside of the container use '--mount C:\folder-out-side-container=C:\pg-data'


#Getting command line
If you want to access the postgree tools, instead of the db: Use --startup-file=cmd, to launch a command line window
