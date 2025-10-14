unit ufavoritos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ulistasimple, uarbolb, ulistadoble;

type
  { TFormFavoritos }
  TFormFavoritos = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    LabelDe: TLabel;
    LabelAsunto: TLabel;
    ListBoxFavoritos: TListBox;
    MemoMensaje: TMemo;
    procedure ListBoxFavoritosSelectionChange(Sender: TObject; User: boolean);
  private
    usuarioActual: PUsuario;
  public
    procedure AbrirFavoritos(u: PUsuario);
  end;

var
  FormFavoritos: TFormFavoritos;

implementation

{$R *.lfm}

{ TFormFavoritos }

procedure TFormFavoritos.AbrirFavoritos(u: PUsuario);
begin
  usuarioActual := u;
  ListBoxFavoritos.Clear;

  if (usuarioActual <> nil) and (usuarioActual^.favoritos <> nil) then
  begin
    RecorrerB(usuarioActual^.favoritos, ListBoxFavoritos.Items);
  end
  else
  begin
    ListBoxFavoritos.Items.Add('(No tienes correos favoritos)');
  end;
end;

procedure TFormFavoritos.ListBoxFavoritosSelectionChange(Sender: TObject; User: boolean);
var
  correoSeleccionado: PCorreo;
begin
  if ListBoxFavoritos.ItemIndex < 0 then Exit;

  correoSeleccionado := PCorreo(ListBoxFavoritos.Items.Objects[ListBoxFavoritos.ItemIndex]);

  if correoSeleccionado <> nil then
  begin
    LabelDe.Caption := correoSeleccionado^.remitente;
    LabelAsunto.Caption := correoSeleccionado^.asunto;
    MemoMensaje.Text := correoSeleccionado^.mensaje;
  end;
end;

end.
