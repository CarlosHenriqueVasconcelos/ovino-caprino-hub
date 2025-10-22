#define MyAppName "Fazenda SÃ£o PetrÃ´nio"
#define MyCompany "flutter_desktop"
#define MyAppVersion "1.0.1"
#define MyAppExeName "flutter_desktop.exe"
; Adjust this if you place the .iss inside an 'installer' folder in your project root
#define BuildOutput "..\build\windows\x64\runner\Release"
#define SetupIcon "app_icon.ico"

[Setup]
AppId={{5dae5c10-d350-4b90-85eb-08eaf5d92b9b}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyCompany}
DefaultDirName={{pf}}\{#MyCompany}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=.
OutputBaseFilename=Setup-{#MyAppName}-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
SetupIconFile={#SetupIcon}
UninstallDisplayIcon={app}\{#MyAppExeName}
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "pt_BR"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na Ãrea de Trabalho"; GroupDescription: "Atalhos:"; Flags: unchecked

[Files]
Source: "{#BuildOutput}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Executar Fazenda SÃ£o PetrÃ´nio"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\logs"
