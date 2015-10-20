@echo off

set FrameRate=%1
set InputPattern=%2
set OutputFile=%3
set Encoder="c:\ffmpeg\ffmpeg.exe"
set FfmpgFilters="scale=-1:-1:flags=lanczos"

:GETPALETTEFILE
for /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined wmicdate set wmicdate=%%x
set PaletteFile=%TEMP%\palette-%wmicdate:~0,21%-%RANDOM%.png
if exist "%PaletteFile%" GOTO :GETPALETTEFILE 

%Encoder% -i "%InputPattern%" -vf "%FfmpgFilters%,palettegen" -y "%PaletteFile%"

if %ERRORLEVEL% NEQ 0 goto :Return

%Encoder% -framerate "%FrameRate%" -i "%InputPattern%" -i "%PaletteFile%" -lavfi "%FfmpgFilters% [x]; [x][1:v] paletteuse" -f gif -y "%OutputFile%"

:Return
del "%PaletteFile%"
exit /b %ERRORLEVEL%