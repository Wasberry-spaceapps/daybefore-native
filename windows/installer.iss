[Setup]
AppName=Day Before
AppVersion=1.0.0
AppPublisher=Day Before
AppPublisherURL=https://daybefore.app
DefaultDirName={autopf}\Day Before
DefaultGroupName=Day Before
OutputDir=..\Output
OutputBaseFilename=DayBefore-Setup
Compression=lzma2/ultra64
SolidCompression=yes
SetupIconFile=DayBefore\icon.ico
UninstallDisplayIcon={app}\DayBefore.exe
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Files]
Source: "..\publish\win\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\Day Before"; Filename: "{app}\DayBefore.exe"
Name: "{autodesktop}\Day Before"; Filename: "{app}\DayBefore.exe"

[Run]
Filename: "{app}\DayBefore.exe"; Description: "Launch Day Before"; Flags: postinstall nowait skipifsilent
