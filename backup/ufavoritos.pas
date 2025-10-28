unit ufavoritos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ulistasimple, uarbolb, ulistadoble, uhuffman, Genercis.Collections;

type
  { TFormFavoritos }
  TFormFavoritos = class(TForm)
    ButtonEliminar: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    LabelDe: TLabel;
    LabelAsunto: TLabel;
    ListBoxFavoritos: TListBox;
    MemoMensaje: TMemo;
    procedure ButtonEliminarClick(Sender: TObject);
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
  arbolHuffman: PHuffmanNode;
  mensajeDescomprimido: String;
begin
  if ListBoxFavoritos.ItemIndex < 0 then Exit;

  correoSeleccionado := PCorreo(ListBoxFavoritos.Items.Objects[ListBoxFavoritos.ItemIndex]);

  if correoSeleccionado <> nil then
  begin
    LabelDe.Caption := correoSeleccionado^.remitente;
    LabelAsunto.Caption := correoSeleccionado^.asunto;

    if correoSeleccionado^.tablaCodigos <> nil then
    begin
      arbolHuffman := ConstruirArbolDesdeTabla(correoSeleccionado^.tablaCodigos);
      mensajeDescomprimido := DescomprimirHuffman(correoSeleccionado^.mensaje, arbolHuffman);
    end
    else
    begin
      mensajeDescomprimido := correoSeleccionado^.mensaje;
    end;

    MemoMensaje.Text := mensajeDescomprimido;
  end;
end;

procedure TFormFavoritos.ButtonEliminarClick(Sender: TObject);
var
  correoSeleccionado: PCorreo;
  idParaEliminar: Integer;
begin
  if ListBoxFavoritos.ItemIndex < 0 then
  begin
    ShowMessage('Por favor, selecciona un favorito para eliminar.');
    Exit;
  end;

  correoSeleccionado := PCorreo(ListBoxFavoritos.Items.Objects[ListBoxFavoritos.ItemIndex]);
  if correoSeleccionado = nil then Exit;
  idParaEliminar := correoSeleccionado^.id;

  EliminarB(usuarioActual^.favoritos, idParaEliminar);

  ShowMessage('Correo eliminado de favoritos.');

  AbrirFavoritos(usuarioActual);
end;

end.
