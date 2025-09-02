unit ucrearusuario;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ulistasimple;

type

  { TFormCrear }

  TFormCrear = class(TForm)
    ButtonRegistrar: TButton;
    EditEmail: TEdit;
    EditNombre: TEdit;
    EditPassword: TEdit;
    EditTelefono: TEdit;
    EditUsuario: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure ButtonRegistrarClick(Sender: TObject);
  private

  public

  end;

var
  FormCrear: TFormCrear;

implementation

{$R *.lfm}

procedure TFormCrear.ButtonRegistrarClick(Sender: TObject);
var
  nuevoId: Integer;
begin
  if ExisteUsuario(listaUsuarios, EditEmail.Text, EditUsuario.Text) then
  begin
    ShowMessage('Error: El usuario o email ya existe');
    Exit;
  end;

  nuevoId := Random(1000);

  InsertarUsuario(listaUsuarios, nuevoId, EditNombre.Text, EditUsuario.Text, EditEmail.Text, EditTelefono.Text, EditPassword.Text);

  ShowMessage('Usuario creado exitosamente');
  Close;

end;

end.

