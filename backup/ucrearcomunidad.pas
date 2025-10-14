unit ucrearcomunidad;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uComunidades;

type
  { TFormCrearComunidad }
  TFormCrearComunidad = class(TForm)
    ButtonCrear: TButton;
    EditNombreComunidad: TEdit;
    Label1: TLabel;
    procedure ButtonCrearClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormCrearComunidad: TFormCrearComunidad;

implementation

{$R *.lfm}

{ TFormCrearComunidad }

procedure TFormCrearComunidad.ButtonCrearClick(Sender: TObject);
var
  nombre: String;
begin
  nombre := EditNombreComunidad.Text;

  if Trim(nombre) = '' then
  begin
    ShowMessage('El nombre de la comunidad no puede estar vacío.');
    Exit;
  end;

  if CrearComunidad(arbolComunidades, nombre) then
  begin
    ShowMessage('Comunidad "' + nombre + '" creada exitosamente.');
    Close;
  end
  else
  begin
    ShowMessage('Error: Ya existe una comunidad con el nombre "' + nombre + '".');
  end;
end;

end.
