unit ucontactos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  uListaSimple, uarbolbst;

type

  { TFormContactos }

  TFormContactos = class(TForm)
    Label1: TLabel;
    ListBoxContactos: TListBox;
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

