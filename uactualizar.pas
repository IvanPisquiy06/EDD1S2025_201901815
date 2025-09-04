unit uactualizar;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ulistasimple;

type

  { TFormActualizar }

  TFormActualizar = class(TForm)
    ButtonActualizar: TButton;
    EditUsuario: TEdit;
    EditTelefono: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LabelCorreo: TLabel;
    LabelNombre: TLabel;
    procedure ButtonActualizarClick(Sender: TObject);
  private
    usuarioActual: PUsuario;
  public
    procedure AbrirPerfil(u: PUsuario);
  end;

var
  FormActualizar: TFormActualizar;

implementation

{$R *.lfm}

{ TFormActualizar }

procedure TFormActualizar.AbrirPerfil(u: PUsuario);
begin
  usuarioActual := u;
  EditUsuario.Text := u^.usuario;
  EditTelefono.Text := u^.telefono;
  LabelNombre.Caption := u^.nombre;
  LabelCorreo.Caption := u^.email;
end;

procedure TFormActualizar.ButtonActualizarClick(Sender: TObject);
begin
  if usuarioActual = nil then Exit;

  usuarioActual^.usuario := EditUsuario.Text;
  usuarioActual^.telefono := EditTelefono.Text;

  ShowMessage('Perfil actualizado exitosamente');
  Close;
end;

end.

