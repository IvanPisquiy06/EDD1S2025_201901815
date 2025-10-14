unit uborradores;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ulistasimple, uArbolAVL, ulistadoble, uenviar;

type
  { TFormBorradores }
  TFormBorradores = class(TForm)
    ButtonAbrir: TButton;
    ButtonEliminar: TButton;
    ButtonInOrden: TButton;
    ButtonPostOrden: TButton;
    ButtonPreOrden: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    LabelDestinatario: TLabel;
    LabelAsunto: TLabel;
    ListBoxBorradores: TListBox;
    MemoMensaje: TMemo;
    procedure ButtonAbrirClick(Sender: TObject);
    procedure ButtonEliminarClick(Sender: TObject);
    procedure ButtonInOrdenClick(Sender: TObject);
    procedure ButtonPostOrdenClick(Sender: TObject);
    procedure ButtonPreOrdenClick(Sender: TObject);
    procedure ListBoxBorradoresSelectionChange(Sender: TObject; User: boolean);
  private
    usuarioActual: PUsuario;
    procedure CargarBorradores(recorrido: Integer);
  public
    procedure AbrirBorradores(u: PUsuario);
  end;

var
  FormBorradores: TFormBorradores;

implementation

{$R *.lfm}

{ TFormBorradores }

procedure TFormBorradores.AbrirBorradores(u: PUsuario);
begin
  usuarioActual := u;
  CargarBorradores(2);
end;

procedure TFormBorradores.CargarBorradores(recorrido: Integer);
begin
  ListBoxBorradores.Clear;
  Label1.Caption := '';
  Label2.Caption := '';
  MemoMensaje.Clear;

  if usuarioActual = nil then Exit;

  case recorrido of
    1: PreOrden(usuarioActual^.borradores, ListBoxBorradores.Items);
    2: InOrden(usuarioActual^.borradores, ListBoxBorradores.Items);
    3: PostOrden(usuarioActual^.borradores, ListBoxBorradores.Items);
  end;
end;

procedure TFormBorradores.ListBoxBorradoresSelectionChange(Sender: TObject; User: boolean);
var
  correoSeleccionado: PCorreo;
begin
  if ListBoxBorradores.ItemIndex < 0 then Exit;

  correoSeleccionado := PCorreo(ListBoxBorradores.Items.Objects[ListBoxBorradores.ItemIndex]);

  if correoSeleccionado <> nil then
  begin
    Label1.Caption := correoSeleccionado^.destinatario;
    Label2.Caption := correoSeleccionado^.asunto;
    MemoMensaje.Text := correoSeleccionado^.mensaje;
  end;
end;

procedure TFormBorradores.ButtonPreOrdenClick(Sender: TObject);
begin
  CargarBorradores(1);
end;

procedure TFormBorradores.ButtonInOrdenClick(Sender: TObject);
begin
  CargarBorradores(2);
end;

procedure TFormBorradores.ButtonPostOrdenClick(Sender: TObject);
begin
  CargarBorradores(3);
end;

procedure TFormBorradores.ButtonEliminarClick(Sender: TObject);
var
  correoSeleccionado: PCorreo;
  alturaCambia: Boolean;
  idParaEliminar: Integer;
begin
  if ListBoxBorradores.ItemIndex < 0 then
  begin
    ShowMessage('Por favor, selecciona un borrador para eliminar.');
    Exit;
  end;

  correoSeleccionado := PCorreo(ListBoxBorradores.Items.Objects[ListBoxBorradores.ItemIndex]);
  idParaEliminar := correoSeleccionado^.id;

  alturaCambia := False;
  if EliminarAVL(usuarioActual^.borradores, idParaEliminar, alturaCambia) then
  begin
    ShowMessage('Borrador eliminado exitosamente.');
    CargarBorradores(2);
  end
  else
  begin
    ShowMessage('Error: No se pudo eliminar el borrador.');
  end;
end;

procedure TFormBorradores.ButtonAbrirClick(Sender: TObject);
var
  correoSeleccionado: PCorreo;
  formEnviar: TFormEnviar;
  alturaCambia: Boolean;
  idParaEliminar: Integer;
begin
  if ListBoxBorradores.ItemIndex < 0 then
  begin
    ShowMessage('Por favor, seleccione un borrador para abrir');
    Exit;
  end;

  correoSeleccionado := PCorreo(listBoxBorradores.Items.Objects[ListBoxBorradores.ItemIndex]);
  idParaEliminar := correoSeleccionado^.id;

  formEnviar := TFormEnviar.Create(Application);
  try
    formEnviar.PrepararEnvio(usuarioActual);
    formEnviar.CargarDesdeBorrador(correoSeleccionado);
    formEnviar.ShowModal
  finally
    formEnviar.Free;
  end;

  alturaCambia := False;
  if EliminarAVL(usuarioActual^.borradores, idParaEliminar, alturaCambia) then
  begin
    ShowMessage('El borrador original se ha eliminado');
    CargarBorradores(2);
  end;
end;

end.
