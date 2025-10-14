unit uvermensajes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uComunidades, uListaSimple;

type
  { TFormVerMensajes }
  TFormVerMensajes = class(TForm)
    LabelTitulo: TLabel;
    Label1: TLabel;
    ListBoxMensajes: TListBox;
  private
    { Private declarations }
  public
    procedure CargarMensajes(comunidad: PComunidad);
  end;

var
  FormVerMensajes: TFormVerMensajes;

implementation

{$R *.lfm}

{ TFormVerMensajes }

procedure TFormVerMensajes.CargarMensajes(comunidad: PComunidad);
var
  mensajeAux: PMensajeComunidad;
begin
  if comunidad = nil then
  begin
    LabelTitulo.Caption := 'Error: Comunidad no válida';
    Exit;
  end;

  LabelTitulo.Caption := 'Mensajes en: ' + comunidad^.nombre;
  ListBoxMensajes.Clear;

  mensajeAux := comunidad^.mensajes;

  if mensajeAux = nil then
  begin
    ListBoxMensajes.Items.Add('(No hay mensajes en esta comunidad)');
  end
  else
  begin
    while mensajeAux <> nil do
    begin
      ListBoxMensajes.Items.Add(
        '[' + mensajeAux^.fecha + '] ' +
        mensajeAux^.autor^.nombre + ': ' +
        mensajeAux^.mensaje
      );
      mensajeAux := mensajeAux^.siguiente;
    end;
  end;
end;

end.
