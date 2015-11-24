if not exist "C:\sql-content\already-copied" (
  if exist "C:\sql-content\DATA" (
    if "%programfiles(x86)%" == "" (
      xcopy /e /r /i /y "C:\sql-content\DATA" "%programfiles%\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA"
    ) else (
      xcopy /e /r /i /y "C:\sql-content\DATA" "%programfiles(x86)%\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA"
    )
  )

  if exist "C:\sql-content\script.sql" (
    xcopy /y "C:\sql-content\script.sql" "C:\script.sql"
  )

  echo.>"C:\sql-content\already-copied"
)