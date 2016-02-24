rem not implemented: turbo try --isolate=merge python -- %~dp0generate-hostnames.py
turbo try --isolate=merge python -- %~dp0generate-routes.py --input-file %~dp0hostnames.txt --output-file %~dp0routes.txt
turbo build --route-file=%~dp0routes.txt --overwrite %~dp0turbo.me
