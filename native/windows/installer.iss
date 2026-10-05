#define MyAppExeName "daybefore.exe"
[Setup]
AppId={{D1A2B3C4-E5F6-7890-1234-567890ABCDEF}
AppName=Day Before
AppVersion=0.1.4
AppPublisher=Day Before
AppPublisherURL=https://daybefore.app
AppSupportURL=https://daybefore.app
AppUpdatesURL=https://daybefore.app
DefaultDirName={autopf}\Day Before
DisableProgramGroupPage=yes
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=..\build\windows\installer
OutputBaseFilename=DayBefore-Setup
SetupIconFile=runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\Day Before"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\Day Before"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,Day Before}"; Flags: nowait postinstall skipifsilent
