unit SettingsDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MainForm, dxCore, dxButtons, Registry;

type
  TLoginPaswdDialog = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    LoginEdit: TEdit;
    PaswdEdit: TEdit;
    Label3: TLabel;
    ServerAddressEdit: TEdit;
    dxButton1: TdxButton;
    dxButton2: TdxButton;
    AutorunChbox: TCheckBox;
    procedure CanselBtnClick(Sender: TObject);
    procedure okBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PaswdEditKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LoginPaswdDialog: TLoginPaswdDialog;

implementation

{$R *.dfm}

procedure Autorun(Flag:boolean; NameParam, Path:String);
var Reg:TRegistry;
begin
  if Flag then
  begin
     Reg := TRegistry.Create;
     Reg.RootKey := HKEY_CURRENT_USER;
     Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', false);
     Reg.WriteString(NameParam, Path);
     Reg.Free;
  end
  else
  begin
     Reg := TRegistry.Create;
     Reg.RootKey := HKEY_CURRENT_USER;
     Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',false);
     Reg.DeleteValue(NameParam);
     Reg.Free;
  end;
end;


procedure TLoginPaswdDialog.CanselBtnClick(Sender: TObject);
begin
  LoginPaswdDialog.Close;
end;

procedure TLoginPaswdDialog.okBtnClick(Sender: TObject);
begin
  Form1.login_setting.Text:=LoginPaswdDialog.LoginEdit.Text;
  Form1.paswd_setting.Text:=LoginPaswdDialog.PaswdEdit.Text;
  Form1.server_address_setting.Text:=LoginPaswdDialog.ServerAddressEdit.Text;
  Form1.autorun_setting.Checked := LoginPaswdDialog.AutorunChbox.Checked;
  if not Form1.PingSessionTimer.Enabled then
    begin
     Form1.TryConnectTimer.Interval := 1000;
     Form1.TryConnectTimer.Enabled := True;
    end;
  Autorun(Form1.autorun_setting.Checked,'CarbonTrayAgent', Application.ExeName);
  LoginPaswdDialog.Close;

end;

procedure TLoginPaswdDialog.FormShow(Sender: TObject);
begin
  LoginPaswdDialog.LoginEdit.Text := Form1.login_setting.Text;
  LoginPaswdDialog.PaswdEdit.Text := Form1.paswd_setting.Text;
  LoginPaswdDialog.ServerAddressEdit.Text:=Form1.server_address_setting.Text;
  LoginPaswdDialog.AutorunChbox.Checked := Form1.autorun_setting.Checked;
end;

procedure TLoginPaswdDialog.PaswdEditKeyPress(Sender: TObject;
  var Key: Char);
begin
if Key = #13 then
   okBtnClick(Sender);
end;

end.
