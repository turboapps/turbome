@echo off

for /f %%x in ('wmic path win32_localtime get /format:list ^| findstr "="') do set %%x
set tag=%Year%.%Month%.%Day%

turbo build turbo.me %tag% --mount %~dp0=C:\Scripts --overwrite 