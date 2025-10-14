unit uenviar;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ulistasimple, ulistadoble, uarbolavl;

type

  { TFormEnviar }

  TFormEnviar = class(TForm)
    ButtonGuardarBorrador: TButton;
    ButtonEnviar: TButton;
    EditDestinatario: TEdit;
    EditAsunto: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MemoMensaje: TMemo;
    procedure ButtonEnviarClick(Sender: TObject);
    procedure ButtonGuardarBorradorClick(Sender: TObject);
  private
    usuarioActual: PUsuario;
  public
    procedure PrepararEnvio(u: PUsuario);
    procedure CargarDesdeBorrador(correo: PCorreo);
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

procedure TFormEnviar.CargarDesdeBorrador(correo: PCorreo);
begin
  if correo = nil then Exit;

  EditDestinatario.Text := correo^.destinatario;
  EditAsunto.Text := correo^.asunto;
  MemoMensaje.Text := correo^.mensaje;
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
  InsertarCorreo(destinatario^.bandejaEntrada, nuevoId, usuarioActual^.email, EditDestinatario.Text,
                                               'NL', EditAsunto.Text, DateTimeToStr(Now), MemoMensaje.Text, False);

  ShowMessage('Correo enviado a ' + destinatario^.nombre);
  Close;
end;

procedure TFormEnviar.ButtonGuardarBorradorClick(Sender: TObject);
var
  nuevoCorreo: PCorreo;
  alturaCambia: Boolean;
begin
  if(usuarioActual = nil) or (MemoMensaje.Text = '') then
  begin
      ShowMessage('No se puede guardar un borrador vacio');
      Exit;
  end;

  New(nuevoCorreo);
  nuevoCorreo^.id := Random(10000);
  nuevoCorreo^.remitente := usuarioActual^.email;
  nuevoCorreo^.destinatario := EditDestinatario.Text;
  nuevoCorreo^.asunto := EditAsunto.Text;
  nuevoCorreo^.mensaje := MemoMensaje.Text;
  nuevoCorreo^.fecha := DateTimeToStr(Now);

  nuevoCorreo^.siguiente := nil;
  nuevoCorreo^.anterior := nil;

  alturaCambia := False;
  if InsertarAVL(usuarioActual^.borradores, nuevoCorreo, alturaCambia) then
  begin
      ShowMessage('Borrador guardado');
      Close;
  end
  else
  begin
    ShowMessage('Error: No se pudo guardar el borrador');
    Dispose(nuevoCorreo);
  end;
end;

end.

