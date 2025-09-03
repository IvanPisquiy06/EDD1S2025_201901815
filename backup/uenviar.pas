unit uenviar;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ulistasimple, ulistadoble;

type

  { TFormEnviar }

  TFormEnviar = class(TForm)
    ButtonEnviar: TButton;
    EditDestinatario: TEdit;
    EditAsunto: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MemoMensaje: TMemo;
    procedure ButtonEnviarClick(Sender: TObject);
  private
    usuarioActual: PUsuario;
  public
    procedure PrepararEnvio(u: PUsuario);
  end;

var
  FormEnviar: TFormEnviar;

implementation

{$R *.lfm}

{ TFormEnviar }

procedure TFormEnviar.PrepararEnvio(u: PUsuario);
begin
  usuarioActual := u;
end;

procedure TFormEnviar.ButtonEnviarClick(Sender: TObject);
var
  destinatario: PUsuario;
  nuevoId: Integer;
begin
  if usuarioActual = nil then Exit;

  if not EsContacto(usuarioActual, EditDestinatario.Text) then
  begin
    ShowMessage('Error: solo puedes enviar correos a tus contactos');
    Exit;
  end;

  destinatario := BuscarUsuarioEmail(listaUsuarios, EditDestinatario.Text);
  if destinatario = nil then
  begin
    ShowMessage('Error: destinatario no encontrado o no es tu contacto');
    Exit;
  end;

  nuevoId := Random(10000);
  InsertarCorreo(destinatario^.bandejaEntrada, nuevoId, usuarioActual^.email,
                                               'NL', EditAsunto.Text, DateTimeToStr(Now), MemoMensaje.Text, False);

  ShowMessage('Correo enviado a ' + destinatario^.nombre);
  Close;
end;

end.

