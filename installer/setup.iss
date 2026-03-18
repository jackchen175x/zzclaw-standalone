; 周子 Claw Standalone Installer - Inno Setup Script
; Produces a professional guided .exe installer for Windows
; Compile: ISCC.exe /DAppVersion=x.y.z /DSourceDir=...\build\win-x64 /DOutputDir=...\output setup.iss

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

#ifndef SourceDir
  #define SourceDir "..\build\win-x64"
#endif

#ifndef OutputDir
  #define OutputDir "..\output"
#endif

[Setup]
AppId={{B8F4E3C2-AD5E-4F6G-C7B9-2E3F4G5H6I7J}
AppName=周子 Claw
AppVersion={#AppVersion}
AppVerName=周子 Claw {#AppVersion}
AppPublisher=周子科技 (ZhouZi Tech)
AppPublisherURL=https://github.com/jackchen175x/zzclaw-standalone
AppSupportURL=https://github.com/jackchen175x/zzclaw-standalone/issues
AppUpdatesURL=https://github.com/jackchen175x/zzclaw-standalone/releases
DefaultDirName={autopf}\ZZClaw
DefaultGroupName=周子 Claw
AllowNoIcons=yes
LicenseFile=..\LICENSE
OutputDir={#OutputDir}
OutputBaseFilename=zzclaw-{#AppVersion}-win-x64-setup
SetupIconFile=..\assets\zzclaw.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ChangesEnvironment=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\zzclaw.cmd
VersionInfoCompany=ZhouZi Tech
VersionInfoDescription=周子 Claw - AI 智能体引擎
VersionInfoProductName=周子 Claw
MinVersion=10.0

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
BeveledLabel=ZhouZi Tech · 周子 Claw Setup

[CustomMessages]
AddToPath=Add 周子 Claw to PATH (recommended)
FinishMessage=周子 Claw installed!%n%nOpen a terminal and type zzclaw to get started.%n%nGitHub: https://github.com/jackchen175x/zzclaw-standalone

[Tasks]
Name: "addtopath"; Description: "{cm:AddToPath}"; GroupDescription: "Configuration:"; Flags: checkedonce

[Files]
Source: "{#SourceDir}\node.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\zzclaw.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\VERSION"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\node_modules\*"; DestDir: "{app}\node_modules"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\周子 Claw 终端"; Filename: "{cmd}"; Parameters: "/k ""{app}\zzclaw.cmd"""; WorkingDir: "{userdocs}"; Comment: "打开 周子 Claw 终端"
Name: "{group}\卸载 周子 Claw"; Filename: "{uninstallexe}"

[Run]
Filename: "{cmd}"; Parameters: "/k echo 周子 Claw {#AppVersion} 安装成功！输入 zzclaw 开始使用。&& ""{app}\zzclaw.cmd"" --version"; Description: "打开终端验证安装"; Flags: nowait postinstall skipifsilent unchecked

[UninstallDelete]
Type: filesandordirs; Name: "{app}\node_modules"
Type: files; Name: "{app}\node.exe"
Type: files; Name: "{app}\zzclaw.cmd"
Type: files; Name: "{app}\VERSION"

[Code]
// Add/remove install directory from user PATH
procedure AddToUserPath(Dir: string);
var
  OldPath: string;
begin
  if not RegQueryStringValue(HKEY_CURRENT_USER,
    'Environment', 'Path', OldPath) then
    OldPath := '';
  if Pos(Uppercase(Dir), Uppercase(OldPath)) = 0 then
  begin
    if OldPath <> '' then
      OldPath := OldPath + ';';
    OldPath := OldPath + Dir;
    RegWriteStringValue(HKEY_CURRENT_USER,
      'Environment', 'Path', OldPath);
  end;
end;

procedure RemoveFromUserPath(Dir: string);
var
  OldPath, NewPath, Item: string;
  I: Integer;
begin
  if not RegQueryStringValue(HKEY_CURRENT_USER,
    'Environment', 'Path', OldPath) then
    Exit;
  NewPath := '';
  while Length(OldPath) > 0 do
  begin
    I := Pos(';', OldPath);
    if I = 0 then
    begin
      Item := OldPath;
      OldPath := '';
    end else begin
      Item := Copy(OldPath, 1, I - 1);
      OldPath := Copy(OldPath, I + 1, Length(OldPath));
    end;
    Item := Trim(Item);
    if (Length(Item) > 0) and (CompareText(Item, Dir) <> 0) then
    begin
      if NewPath <> '' then
        NewPath := NewPath + ';';
      NewPath := NewPath + Item;
    end;
  end;
  RegWriteStringValue(HKEY_CURRENT_USER,
    'Environment', 'Path', NewPath);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    if IsTaskSelected('addtopath') then
      AddToUserPath(ExpandConstant('{app}'));
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
    RemoveFromUserPath(ExpandConstant('{app}'));
end;

// Notify Windows about PATH change
procedure BroadcastEnvironmentChange;
var
  Dummy: Longint;
begin
  // SendMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 'Environment')
  // Inno Setup doesn't have direct access, but the PATH change takes effect on next terminal open
end;
