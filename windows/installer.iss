; Inno Setup script for Upwell Everyday (built by GitHub Actions on Windows)
[Setup]
AppName=Upwell Everyday
AppVersion={#AppVersion}
AppPublisher=Upwell Everyday
DefaultDirName={localappdata}\Programs\UpwellEveryday
DisableProgramGroupPage=yes
DisableDirPage=yes
PrivilegesRequired=lowest
OutputDir=..\dist
OutputBaseFilename=UpwellEveryday-Setup
SetupIconFile=icon.ico
UninstallDisplayIcon={app}\UpwellEveryday.exe
WizardStyle=modern
Compression=lzma2
SolidCompression=yes

[Files]
Source: "..\build\dist\UpwellEveryday.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{userprograms}\Upwell Everyday\Get new wallpapers now"; Filename: "{app}\UpwellEveryday.exe"; Parameters: "--refresh"
Name: "{userprograms}\Upwell Everyday\Uninstall Upwell Everyday"; Filename: "{uninstallexe}"
Name: "{userstartup}\Upwell Everyday"; Filename: "{app}\UpwellEveryday.exe"

[Run]
Filename: "schtasks.exe"; Parameters: "/Create /F /TN UpwellEveryday /SC DAILY /ST 07:00 /TR ""\""{app}\UpwellEveryday.exe\"""""; Flags: runhidden
Filename: "{app}\UpwellEveryday.exe"; Description: "Set today's wallpaper now"; Flags: postinstall nowait

[UninstallRun]
Filename: "schtasks.exe"; Parameters: "/Delete /F /TN UpwellEveryday"; Flags: runhidden; RunOnceId: "DelTask"

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\UpwellEveryday"
