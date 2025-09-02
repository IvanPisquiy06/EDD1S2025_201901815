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

  end;

var
  FormMenu: TFormMenu;

implementation

{$R *.lfm}

procedure TFormMenu.ButtonBandejaClick(Sender: TObject);
var
  usuario : PUsuario;
begin
  FormBandeja := TFormBandeja.Create(Self);
  try
    FormBandeja.CargarBandeja(usuario);
    FormBandeja.ShowModal;
  finally
    FormBandeja.Free;
  end;
end;

end.

