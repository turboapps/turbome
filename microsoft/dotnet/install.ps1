#
# Microsoft .net framework setup script
# https://github.com/turboapps/turbome/tree/master/microsoft/dotnet
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# NOTE: expected to be done on Win7 x64. Future versions of .net may not be compatible 
#       so this may not be desirable or possible.

& dotnet-installer.exe /norestart /q

# todo: setup "requires" a restart. not sure if we actually need this to get a proper snap.
#       if so, then need to split this up to before and after restart operations.

& c:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\CasPol.exe -q -m -cg All_Code FullTrust
& c:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\CasPol.exe -q -m -cg All_Code FullTrust

# todo: touch these files to get grabbed by the snap (i didn't have to in my tests)
# @SYSTEM@ -> msvcp120_clr0400.dll, msvcr120_clr0400.dll
# @SYSWOW64@ -> msvcp120_clr0400.dll, msvcr120_clr0400.dll
#

<#
#
# NOTE: if on a machine that previously had .net installed, then this step is required to workaround 
#       some things left behind after uninstall so will be missed in the snap.
#
# todo: need to do this before the snap
# todo: need to check to see if this step is required (look at the presence of some registry key or whatever)
#

& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\Microsoft.JScript.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\mscoree.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\mscorlib.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Drawing.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\System.EnterpriseServices.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\System.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Windows.Forms.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Web.tlb
 
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\Microsoft.JScript.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscoree.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscorlib.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Drawing.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.EnterpriseServices.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Windows.Forms.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe /unregister C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.tlb

# todo: may need to restart here. if so, maybe we can do the above before the post-install reboot?

& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\Microsoft.JScript.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\mscoree.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\mscorlib.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Drawing.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\System.EnterpriseServices.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\System.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Windows.Forms.tlb
& c:\windows\microsoft.net\framework\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework\v4.0.30319\System.Web.tlb

& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\Microsoft.JScript.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscoree.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscorlib.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Drawing.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.EnterpriseServices.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Windows.Forms.tlb
& c:\windows\microsoft.net\framework64\v4.0.30319\regtlibv12.exe C:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.tlb

#
#>