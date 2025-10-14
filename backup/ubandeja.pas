unit ubandeja;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ActnList, ulistadoble, ulistasimple, upila, uarbolb;

type

  { TFormBandeja }

  TFormBandeja = class(TForm)
    ButtonFavorito: TButton;
    ButtonOrdenar: TButton;
    ButtonEliminar: TButton;
    Label1: TLabel;
    LabelNoLeidos: TLabel;
    ListBoxCorreos: TListBox;
    MemoMensaje: TMemo;
    procedure ButtonFavoritoClick(Sender: TObject);
    procedure ButtonOrdenarClick(Sender: TObject);
    procedure ButtonEliminarClick(Sender: TObject);
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
     noLeidos := 0;

     aux := usuarioActual^.bandejaEntrada;
     while aux <> nil do
     begin
       ListBoxCorreos.Items.Add('[' + aux^.estado + '] ' + aux^.asunto + ' - ' + aux^.remitente);
       if aux^.estado = 'NL' then
          Inc(noLeidos);
       aux := aux^.siguiente;
     end;
     LabelNoLeidos.Caption := 'No leidos: ' + IntToStr(noLeidos);
end;

procedure TFormBandeja.ListBoxCorreosClick(Sender: TObject);
var
  idx: Integer;

begin
     idx := ListBoxCorreos.ItemIndex;
     if idx < 0 then
     begin
       correoActual := nil;
       Exit;
     end;

     if correoActual <> nil then
  begin
    MemoMensaje.Text := correoActual^.mensaje;
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
     ListBoxCorreos.Sorted := True;
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

procedure TFormBandeja.ButtonEliminarClick(Sender: TObject);
begin
     if correoActual = nil then
  begin
     ShowMessage('Por favor, selecciona un correo para eliminar.');
     Exit;
  end;

  Push(usuarioActual^.pilaPapelera, correoActual);
  ShowMessage('Eliminando correo: ' + correoActual^.asunto);

  CargarBandeja(usuarioActual);
end;

end.

