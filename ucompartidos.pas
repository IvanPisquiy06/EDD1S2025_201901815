unit ucompartidos;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uBlockchain, uListaSimple;

type
  { TFormCompartidos }
  TFormCompartidos = class(TForm)
    LabelEstado: TLabel;
    ListBoxBloques: TListBox;
    MemoDetalles: TMemo;
    procedure FormShow(Sender: TObject);
    procedure ListBoxBloquesSelectionChange(Sender: TObject; User: boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormCompartidos: TFormCompartidos;

implementation

{$R *.lfm}

{ TFormCompartidos }

procedure TFormCompartidos.FormShow(Sender: TObject);
var
  bloqueActual: PBloque;
begin
  InitBlockchain;
  ListBoxBloques.Clear;
  MemoDetalles.Clear;

  if VerificarCadena() then
  begin
    LabelEstado.Font.Color := clGreen;
    LabelEstado.Caption := 'Estado: Blockchain VERIFICADO.';
  end
  else
  begin
    LabelEstado.Font.Color := clRed;
    LabelEstado.Caption := '¡ALERTA! El Blockchain está corrupto o ha sido alterado.';
  end;

  bloqueActual := blockchain;
  if bloqueActual = nil then
  begin
    ListBoxBloques.Items.Add('(No hay bloques en la cadena)');
    Exit;
  end;

  while bloqueActual <> nil do
  begin
    ListBoxBloques.Items.AddObject(
      'Bloque #' + IntToStr(bloqueActual^.index) + ': ' + bloqueActual^.datos.asunto,
      TObject(bloqueActual)
    );
    bloqueActual := bloqueActual^.siguiente;
  end;
end;

procedure TFormCompartidos.ListBoxBloquesSelectionChange(Sender: TObject; User: boolean);
var
  bloqueSeleccionado: PBloque;
begin
  if ListBoxBloques.ItemIndex < 0 then Exit;

  bloqueSeleccionado := PBloque(ListBoxBloques.Items.Objects[ListBoxBloques.ItemIndex]);
  MemoDetalles.Clear;

  if bloqueSeleccionado <> nil then
  begin
    MemoDetalles.Lines.Add('--- Detalles del Bloque ---');
    MemoDetalles.Lines.Add('Índice: ' + IntToStr(bloqueSeleccionado^.index));
    MemoDetalles.Lines.Add('Timestamp: ' + DateTimeToStr(bloqueSeleccionado^.timestamp));
    MemoDetalles.Lines.Add('Nonce (Prueba de Trabajo): ' + IntToStr(bloqueSeleccionado^.nonce));
    MemoDetalles.Lines.Add('');
    MemoDetalles.Lines.Add('--- Datos del Correo ---');
    if bloqueSeleccionado^.index > 0 then
    begin
      MemoDetalles.Lines.Add('De: ' + bloqueSeleccionado^.datos.remitente^.nombre);
      MemoDetalles.Lines.Add('Para: ' + bloqueSeleccionado^.datos.destinatario^.nombre);
    end;
    MemoDetalles.Lines.Add('Asunto: ' + bloqueSeleccionado^.datos.asunto);
    MemoDetalles.Lines.Add('Mensaje:');
    MemoDetalles.Lines.Add(bloqueSeleccionado^.datos.mensaje);
    MemoDetalles.Lines.Add('');
    MemoDetalles.Lines.Add('--- Hashes de Seguridad ---');
    MemoDetalles.Lines.Add('Hash Anterior:');
    MemoDetalles.Lines.Add(bloqueSeleccionado^.hashAnterior);
    MemoDetalles.Lines.Add('Hash Propio:');
    MemoDetalles.Lines.Add(bloqueSeleccionado^.hash);
  end;
end;

end.
