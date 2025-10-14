unit ucontactos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  uListaSimple, uarbolbst;

type

  { TFormContactos }

  TFormContactos = class(TForm)
    ButtonEliminar: TButton;
    Label1: TLabel;
    ListBoxContactos: TListBox;
    procedure ButtonEliminarClick(Sender: TObject);
  private
    usuarioActual: PUsuario;
  public
    procedure AbrirContactos(u: PUsuario);
  end;

var
  FormContactos: TFormContactos;

implementation

{$R *.lfm}

{ TFormContactos }

procedure TFormContactos.ButtonEliminarClick(Sender: TObject);
var
  contactoSeleccionado: PUsuario;
  emailParaEliminar: String;
begin
  if ListBoxContactos.ItemIndex < 0 then
  begin
    ShowMessage('Por favor, selecciona un contacto para eliminar.');
    Exit;
  end;

  contactoSeleccionado := PUsuario(ListBoxContactos.Items.Objects[ListBoxContactos.ItemIndex]);
  if contactoSeleccionado = nil then Exit;
  emailParaEliminar := contactoSeleccionado^.email;

  EliminarBST(usuarioActual^.contactosBST, emailParaEliminar);

  ShowMessage('Contacto eliminado exitosamente.');

  AbrirContactos(usuarioActual);
end;

procedure TFormContactos.AbrirContactos(u: PUsuario);
begin
  usuarioActual := u;
  ListBoxContactos.Clear;

  if (usuarioActual <> nil) and (usuarioActual^.contactosBST <> nil) then
  begin
    InOrden(usuarioActual^.contactosBST, ListBoxContactos.Items);
  end
  else
  begin
    ListBoxContactos.Items.Add('No hay contactos agregados')
  end;
end;

end.

