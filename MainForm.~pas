unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ImgList, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, ExtCtrls, PropFilerEh,
  PropStorageEh, IdGlobal, IdHash, IdHashMessageDigest, OleCtrls, SHDocVw,
  CoolTrayIcon, Menus, XPMan, ShellApi;

type
  TForm1 = class(TForm)
    ImageList1: TImageList;
    IdHTTP1: TIdHTTP;
    PingSessionTimer: TTimer;
    PropStorageEh1: TPropStorageEh;
    StorageManager: TRegPropStorageManEh;
    login_setting: TEdit;
    paswd_setting: TEdit;
    WebBrowser1: TWebBrowser;
    CoolTrayIcon1: TCoolTrayIcon;
    PopupMenuTray: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    TryConnectTimer: TTimer;
    N3: TMenuItem;
    N4: TMenuItem;
    server_address_setting: TEdit;
    N5: TMenuItem;
    N6: TMenuItem;
    autorun_setting: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure MakeAuth;
    procedure PingSession;
    procedure SessionActivated;
    procedure GETINGO;
    procedure GetMenu();
    procedure CustomMenuClick(Sender: TObject);
    procedure SessionDeactivated;
    procedure PingSessionTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CoolTrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TryConnectTimerTimer(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure PropStorageEh1AfterLoadProps(Sender: TObject);
    procedure CoolTrayIcon1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  ping_connecting_interval = 3000;

var
  Form1: TForm1;
  session_id: string;
  in_tray: boolean;
  session_ping: integer;
  ping_logged_interval: integer;
  last_ping: TDateTime;
  program_about: string;
  program_menu: string;

  popup_menu_initial_count: integer;
  
implementation

uses SettingsDialog;

{$R *.dfm}

function GetURLAsString(aURL: string): string;
var
  lHTTP: TIdHTTP;
begin
  lHTTP := TIdHTTP.Create(nil);
  lHTTP.ReadTimeout:=1000;
  try
    Result := lHTTP.Get(aURL);
  finally
    FreeAndNil(lHTTP);
  end;
end;

function MakeMd5(login, paswd, salt: string): string;
begin
  with TIdHashMessageDigest5.Create do
  try
      Result := TIdHash128.AsHex(HashValue(login+paswd+salt));
  finally
      Free;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
Form1.Hide;
in_tray := True;
CanClose:=False;
end;


procedure TForm1.PingSession;
var
word1, word2, word3, warning, email, msg, ret_code, word_prefix: string;
separator_pos: integer;
begin
   try
    session_ping := session_ping+1;
    msg:=GetURLAsString('http://'+server_address_setting.text+'/tray_agent.php?cmd=PING&login='+login_setting.Text+'&session='+session_id+'&param='+IntToStr(session_ping));
    last_ping:=Time;

    separator_pos := Pos(' ', msg);
    if separator_pos = -1 then
      begin
        raise Exception.Create('');
      end;
    ret_code := Copy(msg, 0, separator_pos-1);
    msg := Copy(msg, separator_pos+1, length(msg)-separator_pos+1);

    if ret_code = '0' then
       raise Exception.Create('');
    if ret_code = '1' then
        begin
        SessionActivated();
        separator_pos := Pos(' ', msg);
        word1:= Copy(msg, 0, separator_pos-1);
        msg := Copy(msg, separator_pos+1, length(msg)-separator_pos+1);

        separator_pos := Pos(' ', msg);
        word2:= Copy(msg, 0, separator_pos-1);
        msg := Copy(msg, separator_pos+1, length(msg)-separator_pos+1);

        separator_pos := Pos(' ', msg);
        warning:= Copy(msg, 0, separator_pos-1);
        msg := Copy(msg, separator_pos+1, length(msg)-separator_pos+1);

        email := msg;

        if email <> '' then
            ShowMessage(email);
        word_prefix:='Подключен';
        CoolTrayIcon1.IconIndex:=1;
        if warning = '1' then
            begin
            word_prefix:='Скоро лимит';
            CoolTrayIcon1.IconIndex:=2;
            end;
        if warning = '2' then
            begin
            word_prefix:='Баланс исчерпан';
            CoolTrayIcon1.IconIndex:=4;
            end;
        CoolTrayIcon1.Hint:=word_prefix+#13#10+'Баланс: '+word1+#13#10+'За сессию: '+word2;
        end;
    if ret_code = '2' then
        begin
        PingSessionTimer.Interval := ping_connecting_interval;
        CoolTrayIcon1.IconIndex:=3;
        CoolTrayIcon1.Hint:= msg;
        if session_ping*ping_connecting_interval > 60 * 1000 then
           raise Exception.Create('');
        end;
   except
    PingSessionTimer.Enabled:=False;
    ShowMessage('Сервер не отвечает!');
    CoolTrayIcon1.IconIndex:=4;
   end;
end;

procedure TForm1.SessionActivated;
begin
    PingSessionTimer.Interval := ping_logged_interval;
end;

procedure TForm1.GETINGO;
begin
    WebBrowser1.Navigate('http://'+server_address_setting.text+'/tray_agent.php?cmd=GETINFO&login='+login_setting.Text+'&session='+session_id);
end;


procedure TForm1.SessionDeactivated;
begin
    GetURLAsString('http://'+server_address_setting.text+'/tray_agent.php?cmd=LOGOUT&login='+login_setting.Text+'&session='+session_id+'&param='+IntToStr(session_ping));
    CoolTrayIcon1.IconIndex:=0;
    PingSessionTimer.Enabled:=False;
    WebBrowser1.GoHome;
    CoolTrayIcon1.Hint:='';
end;

procedure TForm1.CustomMenuClick(Sender: TObject);
var
    menuItem : TMenuItem;
begin
    if NOT (Sender is TMenuItem) then
    begin
      exit;
    end;
    menuItem := TMenuItem(sender);
    ShellExecute(self.WindowHandle, 'open', PChar(menuItem.Hint), nil, nil, SW_SHOWNORMAL);
end;

procedure TForm1.GetMenu();
var
    href, caption, menu_item_str: string;
    separator_pos, insert_pos:integer;
    sub_item: TMenuItem;
begin
    while popup_menu_initial_count <> PopupMenuTray.Items.Count do
        PopupMenuTray.Items.Delete(3);
    insert_pos:= 0;
    program_menu:= GetURLAsString('http://'+server_address_setting.text+'/tray_agent.php?cmd=GETMENU');
    separator_pos:= Pos(#10, program_menu);
    while separator_pos >0  do
        begin
            menu_item_str := Copy(program_menu, 0, separator_pos-1);
            program_menu := Copy(program_menu, separator_pos+1, length(program_menu)-separator_pos+1);
            separator_pos:= Pos('|', menu_item_str);
            if separator_pos < 1 then continue;
            caption := Copy(menu_item_str, 0, separator_pos-1);
            href := Copy(menu_item_str, separator_pos+1, length(menu_item_str)-separator_pos+1);
            separator_pos:= Pos(#10, program_menu);

            sub_item := TMenuItem.Create(PopupMenuTray);
            sub_item.Caption := caption;
            //sub_item.Name := '';
            sub_item.hint := href;
            sub_item.OnClick:= CustomMenuClick;

            PopupMenuTray.Items.Insert(3+insert_pos, sub_item);
            insert_pos := insert_pos+1;
        end;
end;

procedure TForm1.MakeAuth;
var
  salt, hash, session : string;
  ret_code, error_code, ping_time, session_id_str: string;
  separator_pos :integer;
begin
  try
    program_about:= GetURLAsString('http://'+server_address_setting.text+'/tray_agent.php?cmd=GETABOUT');
    GetMenu();
    salt:= GetURLAsString('http://'+server_address_setting.text+'/tray_agent.php?cmd=GET_SALT&login='+login_setting.Text);
    if salt = '-1' then
      begin
        error_code := 'Неверный логин или пароль';
        raise Exception.Create('');
      end;
    hash := MakeMd5(UpperCase(login_setting.text), paswd_setting.text, salt);
    session:= GetURLAsString('http://'+server_address_setting.text+'/tray_agent.php?cmd=LOGON2&login='+login_setting.Text+'&session='+hash);
// '3 662704168 600 0 Autorized! from ip 10.90.210.110'
    ret_code := Copy(session, 0, 1);
    session :=  Copy(session, 3, length(session)-2);
    if ret_code <> '3' then
      begin
        error_code := session;
        raise Exception.Create('');;
      end;

    separator_pos := Pos(' ', session);
    if separator_pos = -1 then
      begin
        error_code := 'Неверный формат ответа';
        raise Exception.Create('');;
      end;
    session_id_str := Copy(session, 0, separator_pos-1);
    session := Copy(session, separator_pos+1, length(session)-separator_pos+1);

    separator_pos := Pos(' ', session);
    if separator_pos = -1 then
      begin
        error_code := 'Неверный формат ответа';
        raise Exception.Create('');;
      end;
    ping_time := Copy(session, 0, separator_pos-1);
    session := Copy(session, separator_pos+1, length(session)-separator_pos+1);

    session_id := session_id_str;
    ping_logged_interval := StrToInt(ping_time)*1000;
    PingSessionTimer.Interval := ping_connecting_interval;
    PingSessionTimer.Enabled:=True;
    TryConnectTimer.Enabled:=False;
    session_ping := 0;
  except
    if error_code <> '' then
      ShowMessage(error_code)
    else
      ShowMessage('Ошибка авторизации!');
      TryConnectTimer.Enabled:=False;
      CoolTrayIcon1.IconIndex:=0;
  end;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
MakeAuth;
end;

procedure TForm1.PingSessionTimerTimer(Sender: TObject);
begin
if session_id <> '' then
  PingSession();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
session_id := '';
in_tray:=true;
PropStorageEh1.LoadProperties();
popup_menu_initial_count := PopupMenuTray.Items.Count;
end;

procedure TForm1.CoolTrayIcon1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case Button of // Проверяем какая кнопка была нажата
    mbLeft:
      {Действия, выполняемый по одинарному или двойному щелчку левой кнопки мыши на значке}
      begin
        if not (in_tray) then
        begin
          in_tray := True;
          Form1.Hide;
          exit;
        end;
          in_tray := False;
          N5Click(self);
          exit;
      end;
    mbRight:
      begin
        PopupMenuTray.Popup(X, Y);
      end;
  end;
end;

procedure TForm1.N1Click(Sender: TObject);
begin
LoginPaswdDialog.Show;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
Application.Terminate;
end;

procedure TForm1.TryConnectTimerTimer(Sender: TObject);
begin
CoolTrayIcon1.IconIndex:=3;
TryConnectTimer.Interval:=30000;
if (Form1.login_setting.Text = '') or (Form1.paswd_setting.Text = '') then
  begin
      LoginPaswdDialog.Show;
      TryConnectTimer.Enabled:=False;
      CoolTrayIcon1.IconIndex:=0;
      exit;
  end;
MakeAuth();
end;

procedure TForm1.N3Click(Sender: TObject);
begin
TryConnectTimer.Interval:=1000;
TryConnectTimer.Enabled:=True;
end;

procedure TForm1.N4Click(Sender: TObject);
begin
SessionDeactivated;
end;

procedure TForm1.PropStorageEh1AfterLoadProps(Sender: TObject);
begin
  if Form1.server_address_setting.Text = '' then
    Form1.server_address_setting.Text:='10.90.210.112';
end;

procedure TForm1.CoolTrayIcon1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
      if ( Time - last_ping > 5*1/24/3600) then
        begin
         PingSessionTimer.Interval := 1;
         last_ping:=Time;
        end;
end;


procedure TForm1.N5Click(Sender: TObject);
begin
  if not PingSessionTimer.Enabled then
   begin
    Application.MessageBox('Ошибка! Не выполнена авторизация.', 'Не выполнена авторизация', MB_OK);
    exit;
   end;
  GETINGO;
  Form1.Show;
end;


procedure TForm1.N6Click(Sender: TObject);
begin
    ShowMessage(program_about);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
    SessionDeactivated;
end;

end.
