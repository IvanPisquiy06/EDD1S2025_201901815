unit umenu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ubandeja, ulistasimple;

type

  { TFormMenu }

  TFormMenu = class(TForm)
    ButtonBandeja: TButton;
    ButtonEnviar: TButton;
    ButtonPapelera: TButton;
    ButtonProgramar: TButton;
    ButtonProgramados: TButton;
    ButtonAgregar: TButton;
    ButtonContactos: TButton;
    ButtonActualizar: TButton;
    ButtonReportes: TButton;
    Label1: TLabel;
  procedure ButtonBandejaClick(Sender : TObject);
  private

  public
  UsuarioActual: PUsuario;

  end;

var
  FormMenu: TFormMenu;

implementation

{$R *.lfm}

procedure TFormMenu.ButtonBandejaClick(Sender: TObject);
begin

  if UsuarioActual = nil then
  begin
    ShowMessage('Error fatal: No se pudo identificar al usuario actual.');
    Exit;
  end;

  FormBandeja := TFormBandeja.Create(Self);
  try
    FormBandeja.CargarBandeja(UsuarioActual);
    FormBandeja.ShowModal;
  finally
    FormBandeja.Free;
  end;
end;

end.

