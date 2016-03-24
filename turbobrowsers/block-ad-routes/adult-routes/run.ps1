# Build turbobrowsers/block-adult-routes image
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# update routes.txt file
& turbo build --overwrite "$PsScriptRoot\extract_routes.me" --mount $PsScriptRoot\..=C:\mount
& turbo rmi extract_routes