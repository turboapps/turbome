pushd ..
turbo build --overwrite --admin --mount %cd%\config=C:\temp %~dp0%turbo.me
popd