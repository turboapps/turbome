PostgreSQL container
================
PostgreSQL container, of http://www.postgresql.org

# Running It.
Just type `spoon run postgresql`, and PostgreSQL will start at the defaul port
# Mount the data folder
The data folder is a C:\pg-data. If you want to mount it outside of the container use '--mount C:\folder-out-side-container=C:\pg-data'

#Defaults
PostgreSQL uses default port: 5432
Default username and password are: postgres postgres

#Getting command line
If you want to access the postgree tools, instead of the db: Use --startup-file=cmd, to launch a command line window
