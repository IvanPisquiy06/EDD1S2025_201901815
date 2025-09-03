unit ucontactos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ulistasimple;

type

  { TFormContactos }

  TFormContactos = class(TForm)
    ButtonAnterior: TButton;
    ButtonSiguiente: TButton;
    Label1: TLabel;
    MemoInfo: TMemo;
    procedure ButtonSiguienteClick(Sender: TObject);
    procedure ButtonAnteriorClick(Sender: TObject);
  private
    usuarioActual: PUsuario;
    contactoActual: PContacto;
    procedure MostrarContacto;
  public
    procedure AbrirContactos(u: PUsuario);
  end;

var
  FormContactos: TFormContactos;

implementation

{$R *.lfm}

{ TFormContactos }

procedure TFormContactos.AbrirContactos(u: PUsuario);
begin
  usuarioActual := u;
  contactoActual := u^.contactos;
  MostrarContacto;
end;

procedure TFormContactos.MostrarContacto;
begin
  if contactoActual = nil then
     MemoInfo.Text := 'Sin contactos';
  else
    MemoInfo.Text := 'Nombre: ' + contactoActual^.refUsuario^.nombre +
                     ' | Email: ' + contactoActual^.refUsuario^.email +
                     ' | Tel: ' + contactoActual^.refUsuario^.telefono;
end;

procedure TFormContactos.ButtonSiguienteClick(Sender: TObject);
begin
  if (contactoActual <> nil) then
  begin
    contactoActual := contactoActual^.siguiente;
    MostrarContacto;
  end;
end;

procedure TFormContactos.ButtonAnteriorClick(Sender: TObject);
begin
  if (contactoActual <> nil) then
  begin
    contactoActual := contactoActual^.anterior;
    MostrarContacto;
  end;
end;

end.

