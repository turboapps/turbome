IF NOT DEFINED SPN set SPN=spn
IF NOT DEFINED VERSION (
   echo "Expect %%VERSION%% to be set"
   exit /b 1
)
%SPN% build --name=maven:%VERSION% spoon.me