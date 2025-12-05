[Setup]
AppName=Aronium POS
AppVersion=1.0.0
DefaultDirName={autopf}\Aronium POS
DefaultGroupName=Aronium POS
OutputDir=installer
OutputBaseFilename=Aronium_POS_Setup
Compression=lzma
SolidCompression=yes
AppPublisher=Aronium
AppPublisherURL=https://aronium.com
AppSupportURL=https://aronium.com/support
AppUpdatesURL=https://aronium.com/updates
UninstallDisplayIcon={app}\aronium.exe
SetupIconFile=assets\pos-system.png
WizardStyle=modern
WizardSizePercent=120,100
WizardImageFile=assets\pos-system.png
WizardSmallImageFile=assets\pos-system.png

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Aronium POS"; Filename: "{app}\aronium.exe"
Name: "{autodesktop}\Aronium POS"; Filename: "{app}\aronium.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\aronium.exe"; Description: "{cm:LaunchProgram,Aronium POS}"; Flags: nowait postinstall skipifsilent
