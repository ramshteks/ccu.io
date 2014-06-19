; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "ccu.io automation platfrom on NodeJS"
#define MyAppShortName "ccu.io"
#define MyAppLCShortName "ccu.io"
#define MyAppVersion "@@version"
#define MyAppPublisher "ccu.io"
#define MyAppURL "http://ccu.io/"
#define MyAppIcon "ccu.io.ico"


[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{AC49B7F2-6226-4465-AA4B-A93AF47E40E7}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\ccu.io
;DisableDirPage=yes
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\..\delivery
OutputBaseFilename={#MyAppShortName}Installer.{#MyAppVersion}
SetupIconFile={#MyAppIcon}
Compression=lzma
SolidCompression=yes
UsePreviousAppDir=yes
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\{#MyAppIcon}
CloseApplications=yes


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "german";  MessagesFile: "compiler:Languages\German.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"


[Files]
Source: "v0.10.29\node.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: not Is64BitInstallMode
Source: "v0.10.29\nodex64.exe"; DestDir: "{app}"; DestName: "node.exe"; Flags: ignoreversion; Check: Is64BitInstallMode
Source: "install.js"; DestDir: "{app}"; Flags: ignoreversion
Source: "uninstall.js"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppIcon}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\.windows-ready\data\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files


[Icons]
Name: "{group}\{#MyAppName} Settings"; Filename: "http://localhost:8080"; IconFilename: "{app}\{#MyAppIcon}"
Name: "{group}\{#MyAppName} Uninstall"; Filename: "{uninstallexe}"
Name: "{group}\Start {#MyAppName} Service"; Filename: "{app}\restart_ccu_io.bat start"; Parameters: "start ccu_io"
Name: "{group}\Stop {#MyAppName} Service"; Filename: "{app}\restart_ccu_io.bat stop"; Parameters: "stop ccu_io"
Name: "{group}\Restart {#MyAppName} Service"; Filename: "{app}\restart_ccu_io.bat"; Parameters: "restart ccu_io"

[Code]
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: integer;
begin
  Result := '';
  if FileExists(ExpandConstant('{app}\restart_ccu_io.bat')) then begin
     Exec(ExpandConstant('{app}\restart_ccu_io.bat'), 'stop', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

function FileReplaceString(const FileName, SearchString, ReplaceString: string):boolean;
var
  MyFile : TStrings;
  MyText : string;
begin
  MyFile := TStringList.Create;

  try
    result := true;

    try
      MyFile.LoadFromFile(FileName);
      MyText := MyFile.Text;

      if StringChangeEx(MyText, SearchString, ReplaceString, True) > 0 then //Only save if text has been changed.
      begin;
        MyFile.Text := MyText;
        MyFile.SaveToFile(FileName);
      end;
    except
      result := false;
    end;
  finally
    MyFile.Free;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  fileName : string;
  lang : string;
begin
  if  CurStep=ssPostInstall then
    begin
      lang := ActiveLanguage();
      if lang = 'russian' then begin
        lang := 'ru';
      end
      else begin
          if lang = 'german' then begin
            lang := 'de';
          end
          else begin
            lang := '';
          end;
      end;
      if lang <> '' then begin
          fileName := ExpandConstant('{app}\settings-dist.json');
          FileReplaceString(fileName, '"language": "en"', '"language": "' + lang + '"');
      end;
    end;
end;

[Run]
; postinstall launch
Filename: "{app}\node.exe"; Parameters: "install.js"; Flags: runhidden;
Filename: "{app}\restart_ccu_io.bat"; Parameters: "start"; Flags: runhidden;
; Add Firewall Rules
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall add rule name=""Node In"" program=""{app}\node.exe"" dir=in action=allow enable=yes"; Flags: runhidden;
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall add rule name=""Node Out"" program=""{app}\node.exe"" dir=out action=allow enable=yes"; Flags: runhidden;
Filename: http://localhost:8080/ccu.io/; Description: "Control page"; Flags: postinstall shellexec

[UninstallRun]
; Removes System Service
Filename: "{app}\node.exe"; Parameters: "uninstall.js"; Flags: runhidden;

; Remove Firewall Rules
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""Node In"" program=""{app}\node.exe"""; Flags: runhidden;
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""Node Out"" program=""{app}\node.exe"""; Flags: runhidden;

; Remove all leftovers
Filename: "{sys}\del"; Parameters: """{app}\daemon\*""";
Filename: "{sys}\rmdir"; Parameters: "-r ""{app}\daemon""";
Filename: "{sys}\rmdir"; Parameters: "-r ""{app}""";
