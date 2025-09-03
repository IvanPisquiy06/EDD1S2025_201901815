unit upapelera;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, upila, ulistadoble, ulistasimple;

type

  { TFormPapelera }

  TFormPapelera = class(TForm)
    ButtonBuscar: TButton;
    ButtonEliminar: TButton;
    EditBuscar: TEdit;
    Label1: TLabel;
    ListBoxPapelera: TListBox;
    procedure ButtonEliminarClick(Sender: TObject);
    procedure ButtonBuscarClick(Sender: TObject);
  private
    usuarioActual: PUsuario;
    procedure CargarPila;
  public
    procedure AbrirPapelera(u: PUsuario);
  end;

var
  FormPapelera: TFormPapelera;

implementation

{$R *.lfm}

procedure TFormPapelera.CargarPila;
var
  aux: PElementoPila;
begin
  ListBoxPapelera.Clear;
  aux := usuarioActual^.pilaPapelera;
  while aux <> nil do
  begin
    ListBoxPapelera.Items.Add(aux^.correo^.asunto + ' - ' + aux^.correo^.remitente);
    aux := aux^.siguiente;
  end;
end;

procedure TFormPapelera.AbrirPapelera(u: PUsuario);
begin
  usuarioActual := u;
  CargarPila;
end;

procedure TFormPapelera.ButtonEliminarClick(Sender: TObject);
var
  eliminado: PCorreo;
begin
  eliminado := Pop(usuarioActual^.pilaPapelera);
  if eliminado <> nil then
     ShowMessage('Correo: ' + eliminado^.asunto + 'eliminado definitivamente')
  else
    ShowMessage('No se encontro correo con esa palabra');

end;

procedure TFormPapelera.ButtonBuscarClick(Sender: TObject);
var
  encontrado: PCorreo;
begin
  encontrado := BuscarPila(usuarioActual^.pilaPapelera, EditBuscar.Text);
  if encontrado <> nil then
     ShowMessage('Encontrado: ' + encontrado^.asunto + ' - ' + encontrado^.mensaje)
  else
    ShowMessage('No se encontro correo');
end;

end.

