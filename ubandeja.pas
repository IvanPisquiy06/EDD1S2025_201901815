unit ubandeja;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ActnList, Menus, ulistadoble, ulistasimple, upila, uarbolb, uhuffman;

type
  { TFormBandeja }
  TFormBandeja = class(TForm)
    ButtonPrivado: TButton;
    ButtonDescargar: TButton;
    ButtonFavorito: TButton;
    ButtonOrdenar: TButton;
    ButtonEliminar: TButton;
    Label1: TLabel;
    LabelNoLeidos: TLabel;
    ListBoxCorreos: TListBox;
    MemoMensaje: TMemo;
    SaveDialog1: TSaveDialog;
    procedure ButtonDescargarClick(Sender: TObject);
    procedure ButtonFavoritoClick(Sender: TObject);
    procedure ButtonOrdenarClick(Sender: TObject);
    procedure ButtonEliminarClick(Sender: TObject);
    procedure ButtonPrivadoClick(Sender: TObject);
    procedure ListBoxCorreosClick(Sender: TObject);
  private
    usuarioActual: PUsuario;
    correoActual: PCorreo;
  public
    procedure CargarBandeja(u: PUsuario);
  end;

var
  FormBandeja: TFormBandeja;

implementation
uses uLZW, umerkle;

{$R *.lfm}

{ TFormBandeja }

procedure TFormBandeja.CargarBandeja(u: PUsuario);
var
  aux: PCorreo;
  noLeidos: Integer;
begin
  usuarioActual := u;
  correoActual := nil;
  ListBoxCorreos.Clear;
  MemoMensaje.Clear;
  noLeidos := 0;

  aux := usuarioActual^.bandejaEntrada;
  while aux <> nil do
  begin
    ListBoxCorreos.Items.AddObject('[' + aux^.estado + '] ' + aux^.asunto + ' - ' + aux^.remitente, TObject(aux));
    if aux^.estado = 'NL' then
      Inc(noLeidos);
    aux := aux^.siguiente;
  end;
  LabelNoLeidos.Caption := 'No leidos: ' + IntToStr(noLeidos);
end;

procedure TFormBandeja.ListBoxCorreosClick(Sender: TObject);
var
  idx: Integer;
  arbolHuffman: PHuffmanNode;
  mensajeDescomprimido: String;
begin
  idx := ListBoxCorreos.ItemIndex;
  if idx < 0 then
  begin
    correoActual := nil;
    MemoMensaje.Clear;
    Exit;
  end;

  correoActual := PCorreo(ListBoxCorreos.Items.Objects[idx]);

  if correoActual <> nil then
  begin
    if correoActual^.tablaCodigos <> nil then
    begin
      arbolHuffman := ConstruirArbolDesdeTabla(correoActual^.tablaCodigos);
      mensajeDescomprimido := DescomprimirHuffman(correoActual^.mensaje, arbolHuffman);
    end
    else
    begin
      mensajeDescomprimido := correoActual^.mensaje;
    end;

    MemoMensaje.Text := mensajeDescomprimido;

    if correoActual^.estado = 'NL' then
    begin
      correoActual^.estado := 'L';
      ListBoxCorreos.Items[idx] := '[L] ' + correoActual^.asunto + ' - ' + correoActual^.remitente;
      CargarBandeja(usuarioActual);
      ListBoxCorreos.ItemIndex := idx;
    end;
  end;
end;
procedure TFormBandeja.ButtonOrdenarClick(Sender: TObject);
begin
  ListBoxCorreos.Sorted := not ListBoxCorreos.Sorted;
end;

procedure TFormBandeja.ButtonFavoritoClick(Sender: TObject);
begin
  if correoActual = nil then
  begin
    ShowMessage('No hay ningún correo seleccionado para marcar como favorito.');
    Exit;
  end;

  InsertarB(usuarioActual^.favoritos, correoActual);
  ShowMessage('Correo "' + correoActual^.asunto + '" agregado a favoritos.');
end;

procedure TFormBandeja.ButtonDescargarClick(Sender: TObject);
var
  arbolHuffman: PHuffmanNode;
  mensajeDescomprimido: String;
  mensajeComprimidoLZW: String;
  listaGuardar: TStringList;
begin
  if correoActual = nil then
  begin
    ShowMessage('Por favor, selecciona un correo de la lista para descargar.');
    Exit;
  end;

  if correoActual^.tablaCodigos <> nil then
  begin
    arbolHuffman := ConstruirArbolDesdeTabla(correoActual^.tablaCodigos);
    mensajeDescomprimido := DescomprimirHuffman(correoActual^.mensaje, arbolHuffman);
  end
  else
  begin
    mensajeDescomprimido := correoActual^.mensaje;
  end;

  ShowMessage('Comprimiendo mensaje con LZW...');
  mensajeComprimidoLZW := ComprimirLZW(mensajeDescomprimido);

  SaveDialog1.Title := 'Guardar Mensaje Comprimido (LZW)';
  SaveDialog1.Filter := 'Archivo de Texto (*.txt)|*.txt';
  SaveDialog1.FileName := correoActual^.asunto + '_lzw.txt';

  if SaveDialog1.Execute then
  begin
    try
      listaGuardar := TStringList.Create;
      listaGuardar.Text := mensajeComprimidoLZW;
      listaGuardar.SaveToFile(SaveDialog1.FileName);
      listaGuardar.Free;
      ShowMessage('Mensaje (comprimido con LZW) guardado en ' + SaveDialog1.FileName);
    except
      on E: Exception do
        ShowMessage('Error al guardar el archivo: ' + E.Message);
    end;
  end;
end;

procedure TFormBandeja.ButtonEliminarClick(Sender: TObject);
begin
  if correoActual = nil then
  begin
    ShowMessage('Por favor, selecciona un correo para eliminar.');
    Exit;
  end;

  Push(usuarioActual^.pilaPapelera, correoActual);
  ShowMessage('Correo "' + correoActual^.asunto + '" movido a la papelera.');

  CargarBandeja(usuarioActual);
end;

procedure TFormBandeja.ButtonPrivadoClick(Sender: TObject);
var
  mensajeDescomprimido: String;
  arbolHuffman: PHuffmanNode;
  arbolTemporal: PMerkleNode;
begin
  if correoActual = nil then
  begin
    ShowMessage('Por favor, selecciona un correo para mover a privados.');
    Exit;
  end;

  if correoActual^.tablaCodigos <> nil then
  begin
    arbolHuffman := ConstruirArbolDesdeTabla(correoActual^.tablaCodigos);
    mensajeDescomprimido := DescomprimirHuffman(correoActual^.mensaje, arbolHuffman);
  end
  else
  begin
    mensajeDescomprimido := correoActual^.mensaje;
  end;

  InsertarCorreo(
    UsuarioActual^.correosPrivados,
    correoActual^.id,
    correoActual^.remitente,
    correoActual^.destinatario,
    'NL',
    correoActual^.asunto,
    correoActual^.fecha,
    mensajeDescomprimido,
    True
  );

  arbolTemporal := CrearMerkleTree(UsuarioActual^.correosPrivados);
  if arbolTemporal <> nil then
    UsuarioActual^.merkleRoot := arbolTemporal^.hash
  else
    UsuarioActual^.merkleRoot := '';
  LiberarMerkleTree(arbolTemporal);

  Push(UsuarioActual^.pilaPapelera, correoActual);

  CargarBandeja(usuarioActual);

  ShowMessage('¡Correo movido a Privados y asegurado con Merkle!');
end;

end.
