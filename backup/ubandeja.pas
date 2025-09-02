unit ubandeja;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ActnList, ulistadoble, ulistasimple;

type

  { TFormBandeja }

  TFormBandeja = class(TForm)
    ButtonOrdenar: TButton;
    ButtonEliminar: TButton;
    Label1: TLabel;
    LabelNoLeidos: TLabel;
    ListBoxCorreos: TListBox;
    MemoMensaje: TMemo;
    procedure ButtonOrdenarClick(Sender: TObject);
    procedure ButtonEliminarClick(Sender: TObject);
    procedure ListBoxCorreosClick(Sender: TObject);
  private
         usuarioActual: PUsuario;
  public
        procedure CargarBandeja(u: PUsuario);
  end;

var
  FormBandeja: TFormBandeja;

implementation

{$R *.lfm}

{ TFormBandeja }

procedure TFormBandeja.ListBoxCorreosClick(Sender: TObject);
var
  idx: Integer;
  aux: PCorreo;
  i: Integer;

begin
     idx := ListBoxCorreos.ItemIndex;
     if idx < 0 then Exit;

     aux := usuarioActual^.bandejaEntrada;
     i := 0;
     while (aux <> nil) and (i < idx) do
     begin
       aux := aux^.siguiente;
       Inc(i);
     end;

     if aux <> nil then
     begin
       MemoMensaje.Text := aux^.mensaje;
       aux^.estado := 'L';
       ListBoxCorreos.Items[idx] := '[L] ' + aux^.asunto + ' - ' + aux^.remitente;
     end;
end;

procedure TFormBandeja.ButtonOrdenarClick(Sender: TObject);
begin
     ListBoxCorreos.Sorted := True;
end;

procedure TFormBandeja.ButtonEliminarClick(Sender: TObject);
var
  idx: Integer;
  aux: PCorreo;
  i: Integer;
begin
     idx := ListBoxCorreos.ItemIndex;
     if idx < 0 then Exit;

     aux := usuarioActual^.bandejaEntrada;
     i := 0;
     while (aux <> nil) and (i < idx) do
     begin
       aux := aux^.siguiente;
       Inc(i);
     end;

     if aux <> nil then
     begin
       ShowMessage('Eliminando correo: ' + aux^.asunto);
     end;

     CargarBandeja(usuarioActual);
end;

end.

