unit ulogvisual;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls,
  uLogControl, uListaSimple;

type
  { TFormLogVisual }
  TFormLogVisual = class(TForm)
    ButtonDescargar: TButton;
    SaveDialog1: TSaveDialog;
    StringGridLog: TStringGrid;
    procedure ButtonDescargarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormLogVisual: TFormLogVisual;

implementation

{$R *.lfm}

{ TFormLogVisual }

procedure TFormLogVisual.FormCreate(Sender: TObject);
begin
  StringGridLog.ColCount := 3;
  StringGridLog.FixedCols := 0;
  StringGridLog.FixedRows := 1;
  StringGridLog.RowCount := 1;

  StringGridLog.Cells[0, 0] := 'Usuario (Email)';
  StringGridLog.Cells[1, 0] := 'Hora de Entrada';
  StringGridLog.Cells[2, 0] := 'Hora de Salida';

  StringGridLog.ColWidths[0] := 200;
  StringGridLog.ColWidths[1] := 150;
  StringGridLog.ColWidths[2] := 150;
end;

procedure TFormLogVisual.ButtonDescargarClick(Sender: TObject);
begin
  SaveDialog1.Title := 'Guardar Log de Sesiones';
  SaveDialog1.Filter := 'Archivo JSON (*.json)|*.json';
  SaveDialog1.FileName := 'log_sesiones.json';

  if SaveDialog1.Execute then
  begin
    try
      GenerarJSONLog(SaveDialog1.FileName);
      ShowMessage('Log de sesiones exportado exitosamente a ' + SaveDialog1.FileName);
    except
      on E: Exception do
        ShowMessage('Error al exportar el log: ' + E.Message);
    end;
  end;
end;

procedure TFormLogVisual.FormShow(Sender: TObject);
var
  aux: PLogSession;
  row: Integer;
  salidaStr: String;
begin
  StringGridLog.RowCount := 1;
  row := 1;

  aux := GetListaGlobalSesiones;

  while aux <> nil do
  begin
    StringGridLog.RowCount := row + 1;

    if aux^.usuario <> nil then
      StringGridLog.Cells[0, row] := aux^.usuario^.email
    else
      StringGridLog.Cells[0, row] := '(Usuario Nulo)';

    StringGridLog.Cells[1, row] := FormatDateTime('yyyy-mm-dd hh:nn:ss', aux^.entrada);

    if aux^.salida = 0 then
      salidaStr := '(sesión activa)'
    else
      salidaStr := FormatDateTime('yyyy-mm-dd hh:nn:ss', aux^.salida);

    StringGridLog.Cells[2, row] := salidaStr;

    Inc(row);
    aux := aux^.siguiente;
  end;

  if StringGridLog.RowCount = 1 then
  begin
    StringGridLog.RowCount := 2;
    StringGridLog.Cells[0, 1] := '(No hay registros de sesión)';
  end;
end;

end.
