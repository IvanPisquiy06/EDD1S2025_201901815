unit uagregar;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ulistasimple, uarbolbst;

type

  { TFormAgregar }

  TFormAgregar = class(TForm)
    ButtonAgregar: TButton;
    EditEmail: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure ButtonAgregarClick(Sender: TObject);
  private
    usuarioActual: PUsuario;

  public
    procedure SetUsuarioActual(u: PUsuario);

  end;

var
  FormAgregar: TFormAgregar;

implementation

{$R *.lfm}

{ TFormAgregar }

procedure TFormAgregar.SetUsuarioActual(u: PUsuario);
begin
  usuarioActual := u;
end;

procedure TFormAgregar.ButtonAgregarClick(Sender: TObject);
var
  emailAgregar: String;
  usuarioAgregar: PUsuario;
begin
  usuarioAgregar := nil;

  if usuarioActual = nil then
  begin
    ShowMessage('Error: No se pudo identifigar el usuario actual.');
    Exit;
  end;

  emailAgregar := EditEmail.text;

  if emailAgregar = usuarioActual^.email then
  begin
    ShowMessage('No se puede agregar el correo del usuario como contacto');
    Exit;
  end;

  usuarioAgregar := BuscarUsuarioEmail(listaUsuarios, emailAgregar);

  if usuarioAgregar = nil then
  begin
      ShowMessage('No se encontro ningun usuario con el email: ' + emailAgregar);
      Exit;
  end;

  InsertarBST(usuarioActual^.contactosBST, usuarioAgregar);

  ShowMessage('Contacto "' + usuarioAgregar^.nombre + '" agregado exitosamente.');
  Close;
end;

end.

