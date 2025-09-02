unit urootmenu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  ExtCtrls, ActnList, ulistasimple, fpjson, jsonparser, FileUtil;

type

  { TFormRoot }

  TFormRoot = class(TForm)
    ButtonCarga: TButton;
    Label1: TLabel;
    OpenDialogFile: TOpenDialog;
    procedure ButtonCargaClick(Sender: TObject);
  private

  public

  end;

var
  FormRoot: TFormRoot;

implementation

{$R *.lfm}

{ TFormRoot }

procedure TFormRoot.ButtonCargaClick(Sender: TObject);
var
  jsonData: TJSONData;
  jsonObj: TJSONObject;
  usuariosArr: TJSONArray;
  usuarioObj: TJSONObject;
  i: Integer;
  archivo: String;
begin
  if OpenDialogFile.Execute then
  begin
    archivo := OpenDialogFile.FileName;

    try
      jsonData := GetJSON(ReadFileToString(archivo));
      jsonObj := TJSONObject(jsonData);
      usuariosArr := jsonObj.Arrays['usuarios'];

      for i := 0 to usuariosArr.Count - 1 do
      begin
        usuarioObj := usuariosArr.Objects[i];
        InsertarUsuario(
        listaUsuarios,
        usuarioObj.Integers['id'],
        usuarioObj.Strings['nombre'],
        usuarioObj.Strings['usuario'],
        usuarioObj.Strings['email'],
        usuarioObj.Strings['telefono'],
        usuarioObj.Strings['password']
        );
      end;
        ShowMessage('Usuarios cargados exitosamente: ' + IntToStr(usuariosArr.Count));

    except
      on E: Exception do
         ShowMessage('Error al cargar JSON: ' + E.Message);
    end;
  end;
end;

end.

