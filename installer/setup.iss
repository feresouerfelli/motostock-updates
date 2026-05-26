; Inno Setup script for MotoStock Pro installer
; Save this file as setup.iss inside your project/installer folder

[Setup]
AppName=MotoStock Pro
AppVersion=1.0.3
DefaultDirName={pf}\MotoStock Pro
DefaultGroupName=MotoStock Pro
OutputBaseFilename=MotostockPro_Installer_1.0.3
Compression=lzma
SolidCompression=yes
WizardStyle=modern
SetupIconFile=..\windows\runner\resources\app_icon.ico
OutputDir=..\installer_output

[Files]
Source: "..\build\windows\x64\runner\Release\motostock_pro.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\MotoStock Pro"; Filename: "{app}\motostock_pro.exe"; WorkingDir: "{app}"; IconFilename: "{app}\motostock_pro.exe"
Name: "{commondesktop}\MotoStock Pro"; Filename: "{app}\motostock_pro.exe"; WorkingDir: "{app}"; IconFilename: "{app}\motostock_pro.exe"

[Run]
Filename: "{app}\motostock_pro.exe"; Description: "Launch MotoStock Pro"; Flags: nowait postinstall skipifsilent
