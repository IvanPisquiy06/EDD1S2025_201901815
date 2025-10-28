unit ubandeja;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uListaSimple, uListaDoble, uHuffman, Generics.Collections, uarbolb, upila;

type
  { TFormBandeja }
  TFormBandeja = class(TForm)
    ButtonDescargar: TButton;
    ButtonEliminar: TButton;
    ButtonMarcarFavorito: TButton;
    ButtonMoverPrivado: TButton;
    ListBoxCorreos: TListBox;
    MemoMensaje: TMemo;
    SaveDialog1: TSaveDialog;

    procedure ButtonDescargarClick(Sender: TObject);
    procedure ButtonEliminarClick(Sender: TObject);
    procedure ButtonMarcarFavoritoClick(Sender: TObject);
    procedure ButtonMoverPrivadoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBoxCorreosClick(Sender: TObject);
  private
    UsuarioActual: PUsuario;
    correoActual: PCorreo;
    procedure CargarBandeja(u: PUsuario); // <-- Tu declaración original
  public
    procedure Abrir(u: PUsuario);
  end;

var
  FormBandeja: TFormBandeja;

implementation

uses uLZW, umerkle;

{$R *.lfm}

{ TFormBandeja }

procedure TFormBandeja.Abrir(u: PUsuario);
begin
  UsuarioActual := u;
end;

procedure TFormBandeja.CargarBandeja(u: PUsuario);
var
  aux: PCorreo;
begin
  ListBoxCorreos.Clear;
  MemoMensaje.Clear;
  correoActual := nil;

  aux := u^.bandejaEntrada;
  while aux <> nil do
  begin
    ListBoxCorreos.Items.AddObject(
      '[' + aux^.estado + '] ' + aux^.asunto + ' - ' + aux^.remitente,
      TObject(aux)
    );
    aux := aux^.siguiente;
  end;

  if ListBoxCorreos.Items.Count = 0 then
    ListBoxCorreos.Items.Add('(Bandeja de entrada vacía)');
end;

procedure TFormBandeja.FormShow(Sender: TObject);
begin
  CargarBandeja(UsuarioActual);
end;

procedure TFormBandeja.ListBoxCorreosClick(Sender: TObject);
var
  arbolHuffman: PHuffmanNode;
  mensajeDescomprimido: String;
begin
  if (ListBoxCorreos.ItemIndex < 0) or (ListBoxCorreos.Items.Objects[ListBoxCorreos.ItemIndex] = nil) then
  begin
    MemoMensaje.Clear;
    correoActual := nil;
    Exit;
  end;

  correoActual := PCorreo(ListBoxCorreos.Items.Objects[ListBoxCorreos.ItemIndex]);

  if correoActual <> nil then
  begin
    correoActual^.estado := 'L';
    ListBoxCorreos.Items[ListBoxCorreos.ItemIndex] := '[L] ' + correoActual^.asunto + ' - ' + correoActual^.remitente;

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
  end;
end;

procedure TFormBandeja.ButtonMarcarFavoritoClick(Sender: TObject);
var
  pagina: PPaginaB;
  mediana: PCorreo;
  crece: Boolean;
begin
  if correoActual = nil then
  begin
    ShowMessage('Por favor, selecciona un correo.');
    Exit;
  end;

  mediana := nil;
  crece := False;
  EmpujarB(correoActual, UsuarioActual^.favoritos, mediana, crece);
  ShowMessage('Correo "' + correoActual^.asunto + '" añadido a Favoritos.');
end;

procedure TFormBandeja.ButtonEliminarClick(Sender: TObject);
begin
  if correoActual = nil then
  begin
    ShowMessage('Por favor, selecciona un correo para eliminar.');
    Exit;
  end;

  Push(UsuarioActual^.papelera, correoActual);
  CargarBandeja(UsuarioActual);
  ShowMessage('Correo movido a la papelera.');
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

procedure TFormBandeja.ButtonMoverPrivadoClick(Sender: TObject);
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
    DateTimeToStr(Now),
    mensajeDescomprimido,
    True
  );

  arbolTemporal := CrearMerkleTree(UsuarioActual^.correosPrivados);
  if arbolTemporal <> nil then
    UsuarioActual^.merkleRoot := arbolTemporal^.hash
  else
    UsuarioActual^.merkleRoot := '';
  LiberarMerkleTree(arbolTemporal);

  Push(UsuarioActual^.papelera, correoActual);

  CargarBandeja(UsuarioActual);

  ShowMessage('¡Correo movido a Privados y asegurado con Merkle!');
end;

end.
