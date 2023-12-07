PostgreSQL
================
PostgreSQL container, of http://www.postgresql.org

# Build
Ensure that the [run-postgre-sql.bat](https://github.com/turboapps/turbome/blob/master/postgresql/run-postgre-sql.bat) file is located in the same path as [turbo.me](https://github.com/turboapps/turbome/blob/master/postgresql/turbo.me). Then `turbo build /path/to/turbo.me`

# Getting Started
Just type `turbo run postgresql`, and PostgreSQL will start at the default port

    turbo run postgresql/postgresql

The PostgreSQL server must be started under an unprivileged user. Please ensure that when using `turbo run` command.
	
# Defaults
PostgreSQL uses default port: 5432
Default username and password are: postgres postgres

# Mount the data folder
The data folder is a C:\pg-data. If you want to mount it outside of the container use `--mount C:\folder-out-side-container=C:\pg-data`


# Getting command line
If you want to access the postgree tools, instead of the db: Use `--startup-file=cmd`, to launch a command line window
