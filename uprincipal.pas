unit uprincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ulistasimple, ulogin;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure formCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
       InsertarUsuario(listausuarios, 0, 'Administrador', 'root', 'root@edd.com', '12345678', 'root123');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
       FormLogin := TFormLogin.Create(Self);
       Label1.Caption:='Se agrego Usuario root';
       try
         FormLogin.ShowModal;
       finally
         FormLogin.Free;
       end;
end;

end.

