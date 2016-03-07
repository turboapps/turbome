# Build turbobrowsers/block-ad-routes image
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# update routes.txt file
& turbo build --overwrite "$PsScriptRoot\extract_routes.me" --mount $PsScriptRoot=C:\mount
& turbo rmi extract_routes

# build block-ad-routes image
& turbo build --overwrite --route-file="$PsScriptRoot\routes.txt" "$PsScriptRoot\turbo.me"
& turbo config --hub=stage.turbo.net
& turbo push turbobrowsers/block-ad-routes
& turbo config --hub=turbo.net
& turbo push turbobrowsers/block-ad-routes