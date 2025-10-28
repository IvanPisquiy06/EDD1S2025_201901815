unit uprivados;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uListaSimple, uListaDoble, uHuffman, umerkle, Generics.Collections,
  ureportes, FileUtil;

type
  { TFormPrivados }
  TFormPrivados = class(TForm)
    ButtonReporte: TButton;
    ButtonVerificar: TButton;
    LabelContador: TLabel;
    LabelEstado: TLabel;
    ListBoxPrivados: TListBox;
    MemoMensaje: TMemo;

    SaveDialog1: TSaveDialog;

    procedure ButtonReporteClick(Sender: TObject);
    procedure ButtonVerificarClick(Sender: TObject);
    procedure ListBoxPrivadosSelectionChange(Sender: TObject; User: boolean);
  private
    usuarioActual: PUsuario;
  public
    procedure Abrir(u: PUsuario);
  end;

var
  FormPrivados: TFormPrivados;

implementation

uses uGrafos;

{$R *.lfm}

{ TFormPrivados }

procedure TFormPrivados.Abrir(u: PUsuario);
var
  aux: PCorreo;
  contador: Integer;
begin
  usuarioActual := u;
  ListBoxPrivados.Clear;
  MemoMensaje.Clear;
  LabelEstado.Caption := 'Estado: Sin verificar.';
  contador := 0;

  aux := usuarioActual^.correosPrivados;
  while aux <> nil do
  begin
    ListBoxPrivados.Items.AddObject(
      '[' + aux^.estado + '] ' + aux^.asunto + ' - ' + aux^.remitente,
      TObject(aux)
    );
    Inc(contador);
    aux := aux^.siguiente;
  end;

  if ListBoxPrivados.Items.Count = 0 then
    ListBoxPrivados.Items.Add('(No tienes correos privados)');
end;

procedure TFormPrivados.ListBoxPrivadosSelectionChange(Sender: TObject; User: boolean);
var
  correoSeleccionado: PCorreo;
  arbolHuffman: PHuffmanNode;
  mensajeDescomprimido: String;
begin
  if (ListBoxPrivados.ItemIndex < 0) or (ListBoxPrivados.Items.Objects[ListBoxPrivados.ItemIndex] = nil) then
  begin
    MemoMensaje.Clear;
    Exit;
  end;

  correoSeleccionado := PCorreo(ListBoxPrivados.Items.Objects[ListBoxPrivados.ItemIndex]);

  if correoSeleccionado <> nil then
  begin
    if correoSeleccionado^.tablaCodigos <> nil then
    begin
      arbolHuffman := ConstruirArbolDesdeTabla(correoSeleccionado^.tablaCodigos);
      mensajeDescomprimido := DescomprimirHuffman(correoSeleccionado^.mensaje, arbolHuffman);
      // (Liberar arbolHuffman)
    end
    else
    begin
      mensajeDescomprimido := correoSeleccionado^.mensaje;
    end;
    MemoMensaje.Text := mensajeDescomprimido;
  end;
end;

procedure TFormPrivados.ButtonVerificarClick(Sender: TObject);
var
  merkleRootGuardado: String;
  merkleRootCalculado: String;
  arbolTemporal: PMerkleNode;
begin
  if usuarioActual = nil then Exit;

  merkleRootGuardado := usuarioActual^.merkleRoot;

  arbolTemporal := CrearMerkleTree(usuarioActual^.correosPrivados);

  if arbolTemporal <> nil then
    merkleRootCalculado := arbolTemporal^.hash
  else
    merkleRootCalculado := '';

  LiberarMerkleTree(arbolTemporal);

  if merkleRootGuardado = merkleRootCalculado then
  begin
    LabelEstado.Font.Color := clGreen;
    LabelEstado.Caption := 'VERIFICADO: La integridad de los correos está intacta.';
  end
  else
  begin
    LabelEstado.Font.Color := clRed;
    LabelEstado.Caption := '¡ALERTA! La bandeja de privados ha sido alterada.';
  end;
end;

procedure TFormPrivados.ButtonReporteClick(Sender: TObject);
var
  rutaReportes: String;
  fileName: String;
  merkleTreeActual: PMerkleNode;
  fileNamePNG: String;
begin
  if (UsuarioActual = nil) or (UsuarioActual^.correosPrivados = nil) then
  begin
    ShowMessage('No hay correos privados para generar el reporte.');
    Exit;
  end;

  merkleTreeActual := CrearMerkleTree(UsuarioActual^.correosPrivados);

  try
    rutaReportes := 'Usuario-' + UsuarioActual^.usuario + '-Reportes';
    ForceDirectories(rutaReportes);

    SaveDialog1.Title := 'Guardar Reporte de Árbol de Merkle';
    SaveDialog1.Filter := 'Archivo PNG (*.png)|*.png';
    SaveDialog1.FileName := IncludeTrailingPathDelimiter(rutaReportes) + 'merkle_privados.png';

    if SaveDialog1.Execute then
    begin
      fileNamePNG := SaveDialog1.FileName;
      fileName := ChangeFileExt(fileNamePNG, '.dot');

      GenerarReporteMerkleDOT(fileName, UsuarioActual^.email, UsuarioActual^.correosPrivados, merkleTreeActual);

      EjecutarDot(fileName, fileNamePNG);

      ShowMessage('Reporte de Árbol de Merkle generado en: ' + fileNamePNG);
    end;
  finally
    LiberarMerkleTree(merkleTreeActual);
  end;
end;

end.
