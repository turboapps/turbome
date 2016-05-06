# Gets special folder using SHGetKnownFolderPath from Windows API
# 
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

$specialFolderGuidMapping = @{
    AddNewPrograms = [guid]"de61d971-5ebc-4f02-a3a9-6c82895e5c04";
    AdminTools = [guid]"724EF170-A42D-4FEF-9F26-B60E846FBA4F";
    AppUpdates = [guid]"a305ce99-f527-492b-8b1a-7e76fa98d6e4";
    CDBurning = [guid]"9E52AB10-F80D-49DF-ACB8-4330F5687855";
    ChangeRemovePrograms = [guid]"df7266ac-9274-4867-8d55-3bd661de872d";
    CommonAdminTools = [guid]"D0384E7D-BAC3-4797-8F14-CBA229B392B5";
    CommonOEMLinks = [guid]"C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D";
    CommonPrograms = [guid]"0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8";
    CommonStartMenu = [guid]"A4115719-D62E-491D-AA7C-E74B8BE3B067";
    CommonStartup = [guid]"82A5EA35-D9CD-47C5-9629-E15D2F714E6E";
    CommonTemplates = [guid]"B94237E7-57AC-4347-9151-B08C6C32D1F7";
    ComputerFolder = [guid]"0AC0837C-BBF8-452A-850D-79D08E667CA7";
    ConflictFolder = [guid]"4bfefb45-347d-4006-a5be-ac0cb0567192";
    ConnectionsFolder = [guid]"6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD";
    Contacts = [guid]"56784854-C6CB-462b-8169-88E350ACB882";
    ControlPanelFolder = [guid]"82A74AEB-AEB4-465C-A014-D097EE346D63";
    Cookies = [guid]"2B0F765D-C0E9-4171-908E-08A611B84FF6";
    Desktop = [guid]"B4BFCC3A-DB2C-424C-B029-7FE99A87C641";
    Documents = [guid]"FDD39AD0-238F-46AF-ADB4-6C85480369C7";
    Downloads = [guid]"374DE290-123F-4565-9164-39C4925E467B";
    Favorites = [guid]"1777F761-68AD-4D8A-87BD-30B759FA33DD";
    Fonts = [guid]"FD228CB7-AE11-4AE3-864C-16F3910AB8FE";
    Games = [guid]"CAC52C1A-B53D-4edc-92D7-6B2E8AC19434";
    GameTasks = [guid]"054FAE61-4DD8-4787-80B6-090220C4B700";
    History = [guid]"D9DC8A3B-B784-432E-A781-5A1130A75963";
    InternetCache = [guid]"352481E8-33BE-4251-BA85-6007CAEDCF9D";
    InternetFolder = [guid]"4D9F7874-4E0C-4904-967B-40B0D20C3E4B";
    Links = [guid]"bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968";
    LocalAppData = [guid]"F1B32785-6FBA-4FCF-9D55-7B8E7F157091";
    LocalAppDataLow = [guid]"A520A1A4-1780-4FF6-BD18-167343C5AF16";
    LocalizedResourcesDir = [guid]"2A00375E-224C-49DE-B8D1-440DF7EF3DDC";
    Music = [guid]"4BD8D571-6D19-48D3-BE97-422220080E43";
    NetHood = [guid]"C5ABBF53-E17F-4121-8900-86626FC2C973";
    NetworkFolder = [guid]"D20BEEC4-5CA8-4905-AE3B-BF251EA09B53";
    OriginalImages = [guid]"2C36C0AA-5812-4b87-BFD0-4CD0DFB19B39";
    PhotoAlbums = [guid]"69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C";
    Pictures = [guid]"33E28130-4E1E-4676-835A-98395C3BC3BB";
    Playlists = [guid]"DE92C1C7-837F-4F69-A3BB-86E631204A23";
    PrintersFolder = [guid]"76FC4E2D-D6AD-4519-A663-37BD56068185";
    PrintHood = [guid]"9274BD8D-CFD1-41C3-B35E-B13F55A758F4";
    Profile = [guid]"5E6C858F-0E22-4760-9AFE-EA3317B67173";
    ProgramData = [guid]"62AB5D82-FDC1-4DC3-A9DD-070D1D495D97";
    ProgramFiles = [guid]"905e63b6-c1bf-494e-b29c-65b732d3d21a";
    ProgramFilesX64 = [guid]"6D809377-6AF0-444b-8957-A3773F02200E";
    ProgramFilesX86 = [guid]"7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E";
    ProgramFilesCommon = [guid]"F7F1ED05-9F6D-47A2-AAAE-29D317C6F066";
    ProgramFilesCommonX64 = [guid]"6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D";
    ProgramFilesCommonX86 = [guid]"DE974D24-D9C6-4D3E-BF91-F4455120B917";
    Programs = [guid]"A77F5D77-2E2B-44C3-A6A2-ABA601054A51";
    Public = [guid]"DFDF76A2-C82A-4D63-906A-5644AC457385";
    PublicDesktop = [guid]"C4AA340D-F20F-4863-AFEF-F87EF2E6BA25";
    PublicDocuments = [guid]"ED4824AF-DCE4-45A8-81E2-FC7965083634";
    PublicDownloads = [guid]"3D644C9B-1FB8-4f30-9B45-F670235F79C0";
    PublicGameTasks = [guid]"DEBF2536-E1A8-4c59-B6A2-414586476AEA";
    PublicMusic = [guid]"3214FAB5-9757-4298-BB61-92A9DEAA44FF";
    PublicPictures = [guid]"B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5";
    PublicVideos = [guid]"2400183A-6185-49FB-A2D8-4A392A602BA3";
    QuickLaunch = [guid]"52a4f021-7b75-48a9-9f6b-4b87a210bc8f";
    Recent = [guid]"AE50C081-EBD2-438A-8655-8A092E34987A";
    RecycleBinFolder = [guid]"B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC";
    ResourceDir = [guid]"8AD10C31-2ADB-4296-A8F7-E4701232C972";
    RoamingAppData = [guid]"3EB685DB-65F9-4CF6-A03A-E3EF65729F3D";
    SampleMusic = [guid]"B250C668-F57D-4EE1-A63C-290EE7D1AA1F";
    SamplePictures = [guid]"C4900540-2379-4C75-844B-64E6FAF8716B";
    SamplePlaylists = [guid]"15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5";
    SampleVideos = [guid]"859EAD94-2E85-48AD-A71A-0969CB56A6CD";
    SavedGames = [guid]"4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4";
    SavedSearches = [guid]"7d1d3a04-debb-4115-95cf-2f29da2920da";
    SEARCH_CSC = [guid]"ee32e446-31ca-4aba-814f-a5ebd2fd6d5e";
    SEARCH_MAPI = [guid]"98ec0e18-2098-4d44-8644-66979315a281";
    SearchHome = [guid]"190337d1-b8ca-4121-a639-6d472d16972a";
    SendTo = [guid]"8983036C-27C0-404B-8F08-102D10DCFD74";
    SidebarDefaultParts = [guid]"7B396E54-9EC5-4300-BE0A-2482EBAE1A26";
    SidebarParts = [guid]"A75D362E-50FC-4fb7-AC2C-A8BEAA314493";
    StartMenu = [guid]"625B53C3-AB48-4EC1-BA1F-A1EF4146FC19";
    Startup = [guid]"B97D20BB-F46A-4C97-BA10-5E3608430854";
    SyncManagerFolder = [guid]"43668BF8-C14E-49B2-97C9-747784D784B7";
    SyncResultsFolder = [guid]"289a9a43-be44-4057-a41b-587a76d7e7f9";
    SyncSetupFolder = [guid]"0F214138-B1D3-4a90-BBA9-27CBC0C5389A";
    System = [guid]"1AC14E77-02E7-4E5D-B744-2EB1AE5198B7";
    SystemX86 = [guid]"D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27";
    Templates = [guid]"A63293E8-664E-48DB-A079-DF759E0509F7";
    TreeProperties = [guid]"5b3749ad-b49f-49c1-83eb-15370fbd4882";
    UserProfiles = [guid]"0762D272-C50A-4BB0-A382-697DCD729B80";
    UsersFiles = [guid]"f3ce0f7c-4901-4acc-8648-d5d44b04ef8f";
    Videos = [guid]"18989B1D-99B5-455B-841C-AB7C74E4DDFC";
    Windows = [guid]"F38BF404-1D43-42F2-9305-67DE0B28FC23";
}

$SpecialFolders = New-Object -TypeName PSObject
foreach ($mapping in $specialFolderGuidMapping.GetEnumerator()) {
    $SpecialFolders | Add-Member -MemberType NoteProperty -Name $mapping.Name -Value $mapping.Value
 }

Set-Variable -Name SpecialFolders -Option ReadOnly -Value $SpecialFolders

function Get-SpecialFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [guid] $folderGuid
    )
    process
    {
       try
       {
           return [TurboShell32]::GetKnownFolderPath($folderGuid);
       }
       catch
       {
           Add-Type @"
            using System;
            using System.Runtime.InteropServices;

            public class TurboShell32
            {
                [DllImport("shell32.dll")]
                private static extern int SHGetKnownFolderPath(
                    [MarshalAs(UnmanagedType.LPStruct)] 
                    Guid rfid,
                    uint dwFlags,
                    IntPtr hToken,
                    out IntPtr pszPath
                );

                public static string GetKnownFolderPath(Guid rfid)
                {
                    IntPtr pszPath;
                    if (SHGetKnownFolderPath(rfid, 0, IntPtr.Zero, out pszPath) != 0)
                        return "";
                    string path = Marshal.PtrToStringUni(pszPath);
                    Marshal.FreeCoTaskMem(pszPath);
                    return path;
                }
            }
"@
           return [TurboShell32]::GetKnownFolderPath($folderGuid); 
       }
    }
}

Export-ModuleMember -Variable SpecialFolders
Export-ModuleMember -Function Get-SpecialFolder
