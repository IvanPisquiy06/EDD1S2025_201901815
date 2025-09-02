unit ulogin;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ulistasimple, ucrearusuario, umenu, urootmenu;

type

  { TFormLogin }

  TFormLogin = class(TForm)
    ButtonLogin: TButton;
    ButtonCreate: TButton;
    EditEmail: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    EditPassword: TEdit;
    procedure ButtonLoginClick(Sender: TObject);
    procedure ButtonCreateClick(Sender: TObject);
  private

  public

  end;

var
  FormLogin: TFormLogin;

implementation

{$R *.lfm}

procedure TFormLogin.ButtonLoginClick(Sender: TObject);
var
  usuario: PUsuario;
  emailIngresado, passwordIngresado: String;

  FormularioMenu: TFormMenu;
  FormularioRoot: TFormRoot;
begin
  emailIngresado := Trim(EditEmail.Text);
  passwordIngresado := Trim(EditPassword.Text);

  usuario:= IniciarSesion(listaUsuarios, emailIngresado, passwordIngresado);
  if usuario <> nil then
     begin
          Self.Hide;
          if usuario^.usuario = 'root' then
          begin
               FormularioRoot := TFormRoot.Create(Application);
               try
                 FormularioRoot.ShowModal;
               finally
                 FormularioRoot.Free;
               end;
          end
          else
          begin
            FormularioMenu := TFormMenu.Create(Application);
            try
              FormularioMenu.ShowModal;
            finally
              FormularioMenu.Free;
            end;
          end;
          Self.Show;
          EditPassword.Clear;
          EditPassword.SetFocus;
     end
  else
      begin
        ShowMessage('Credenciales incorrectas');
        EditPassword.Clear;
        EditPassword.SetFocus;
      end;
end;

procedure TFormLogin.ButtonCreateClick(Sender: TObject);
begin
  FormCrear := TFormCrear.Create(Self);

  try
    FormCrear.ShowModal;
  finally
    FormCrear.Free;
  end;
end;

end.

