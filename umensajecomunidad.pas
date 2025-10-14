unit umensajecomunidad;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uComunidades, uListaSimple, ucrearcomunidad;

type

  { TFormMensajeComunidad }

  TFormMensajeComunidad = class(TForm)
    ButtonPublicar: TButton;
    EditComunidad: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    MemoMensaje: TMemo;
    procedure ButtonPublicarClick(Sender: TObject);
  private
    usuarioActual: PUsuario;
  public
    procedure Abrir(u: PUsuario);
  end;

var
  FormMensajeComunidad: TFormMensajeComunidad;

implementation

{$R *.lfm}

{ TFormMensajeComunidad }

procedure TFormMensajeComunidad.Abrir(u: PUsuario);
begin
  usuarioActual := u;
end;

procedure TFormMensajeComunidad.ButtonPublicarClick(Sender: TObject);
var
  nombreComunidad: String;
  mensaje: String;
  comunidadDestino: PComunidad;
begin
  nombreComunidad := EditComunidad.Text;
  mensaje := MemoMensaje.Text;

  if (Trim(nombreComunidad) = '') or (Trim(mensaje) = '') then
  begin
    ShowMessage('Debe especificar una comunidad y un mensaje.');
    Exit;
  end;

  comunidadDestino := BuscarComunidad(arbolComunidades, nombreComunidad);

  if comunidadDestino = nil then
  begin
    ShowMessage('La comunidad "' + nombreComunidad + '" no existe.');
    CrearComunidad(arbolComunidades, nombreComunidad);
    ShowMessage('Se crea la comunidad: ' + nombreComunidad);
  end
  else
  begin
    PublicarMensaje(comunidadDestino, usuarioActual, mensaje);
    ShowMessage('Mensaje publicado exitosamente en "' + nombreComunidad + '".');
    Close;
  end;
end;

end.
