if (db_id('$(TurboDbName)') is null)
begin
    CREATE DATABASE $(TurboDbName) ON (FILENAME = '$(TurboDbFile)') FOR ATTACH;
end