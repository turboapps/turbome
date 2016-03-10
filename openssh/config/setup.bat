del id_rsa /F /Q
del id_rsa.pub /F /Q

REM generate client SSH keys with passphrase 123456
turbo try openssh/openssh --attach --isolate=merge --startup-file=C:\OpenSSH-Win32\ssh-keygen.exe -- -t rsa -f id_rsa -q -C turbo@turbo.net