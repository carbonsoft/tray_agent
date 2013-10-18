program TrayAgent;

uses
  Forms,
  windows,
  MainForm in 'MainForm.pas' {Form1},
  SettingsDialog in 'SettingsDialog.pas' {LoginPaswdDialog};

{$R *.res}

var
  hwndPrev: HWND;
  myname: AnsiString;

begin
  Application.Initialize;

  myname:='����� �����������';
  hwndPrev := FindWindow('TForm1', pointer(myname));
  if hwndPrev <> 0 then
  begin
    Application.Terminate;
    exit;
  end;


  Application.ShowMainForm := False;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TLoginPaswdDialog, LoginPaswdDialog);
  Application.Run;
end.
