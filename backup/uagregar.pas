unit uagregar;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ulistasimple;

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
  nuevoContacto: PUsuario;
begin
  if EditEmail.Text = '' then Exit;

  nuevoContacto := BuscarUsuarioEmail(listaUsuarios, EditEmail.Text);
  if nuevoContacto = nil then
  Begin
    ShowMessage('Error: usuario no existe en el sistema');
    Exit;
  end;

  AgregarContacto(usuarioActual^.contactos, nuevo);
  ShowMessage('Contacto agregado: ' + nuevo^.nombre);
  Close;
end;

end.

