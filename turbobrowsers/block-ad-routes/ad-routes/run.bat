REM update routes.txt file
turbo build --overwrite extract_routes.me --mount %~dp0=C:\mount
turbo rmi extract_routes

REM build block-ad-routes image
turbo build --overwrite --route-file=%~dp0routes.txt turbo.me