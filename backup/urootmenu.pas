unit urootmenu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  ExtCtrls, ActnList, ulistasimple, fpjson, jsonparser, FileUtil, ureportes, ucrearcomunidad, uvermensajes;

type
  { TFormRoot }
  TFormRoot = class(TForm)
    ButtonVerMensajes: TButton;
    ButtonCargaCorreos: TButton;
    ButtonCargaUsuarios: TButton;
    ButtonCrearComunidad: TButton;
    ButtonUsuarios: TButton;
    Label1: TLabel;
    OpenDialogFile: TOpenDialog;
    procedure ButtonVerMensajesClick(Sender: TObject);
    procedure ButtonCargaCorreosClick(Sender: TObject);
    procedure ButtonCargaUsuariosClick(Sender: TObject);
    procedure ButtonCrearComunidadClick(Sender: TObject);
    procedure ButtonUsuariosClick(Sender: TObject);
    procedure ButtonUsuariosContextPopup(Sender: TObject);
  private
  public
  end;

var
  FormRoot: TFormRoot;

implementation

uses ulistadoble;

{$R *.lfm}

{ TFormRoot }

procedure TFormRoot.ButtonCargaUsuariosClick(Sender: TObject);
var
  JsonData: TJSONData;
  JsonArray: TJSONArray;
  JsonObject, UsuarioJSON: TJSONObject;
  i: Integer;
  FileContent: TStringList;
begin
  if OpenDialogFile.Execute then
  begin
    FileContent := TStringList.Create;
    try
      FileContent.LoadFromFile(OpenDialogFile.FileName);
      JsonData := GetJSON(FileContent.Text);
      JsonObject := TJSONObject(JsonData);
      JsonArray := TJSONArray(JsonObject.Find('usuarios'));

      for i := 0 to JsonArray.Count - 1 do
      begin
        UsuarioJSON := TJSONObject(JsonArray.Items[i]);
        InsertarUsuario(
          listaUsuarios,
          UsuarioJSON.Get('id', 0),
          UsuarioJSON.Get('nombre', ''),
          UsuarioJSON.Get('usuario', ''),
          UsuarioJSON.Get('email', ''),
          UsuarioJSON.Get('telefono', ''),
          UsuarioJSON.Get('password', '')
        );
      end;
      ShowMessage(IntToStr(JsonArray.Count) + ' usuarios han sido cargados exitosamente.');
    finally
      JsonData.Free;
      FileContent.Free;
    end;
  end;
end;

procedure TFormRoot.ButtonCargaCorreosClick(Sender: TObject);
var
  JsonData: TJSONData;
  JsonArray: TJSONArray;
  JsonObject, CorreoJSON: TJSONObject;
  i, correosCargados: Integer;
  FileContent: TStringList;
  destinatario: PUsuario;
  destinatarioEmail: String;
begin
  if OpenDialogFile.Execute then
  begin
    FileContent := TStringList.Create;
    correosCargados := 0;
    try
      FileContent.LoadFromFile(OpenDialogFile.FileName);
      JsonData := GetJSON(FileContent.Text);
      JsonObject := TJSONObject(JsonData);
      JsonArray := TJSONArray(JsonObject.Find('correos'));

      for i := 0 to JsonArray.Count - 1 do
      begin
        CorreoJSON := TJSONObject(JsonArray.Items[i]);
        destinatarioEmail := CorreoJSON.Get('destinatario', '');

        destinatario := BuscarUsuarioEmail(listaUsuarios, destinatarioEmail);
        if destinatario <> nil then
        begin
          InsertarCorreo(
            destinatario^.bandejaEntrada,
            CorreoJSON.Get('id', 0),
            CorreoJSON.Get('remitente', ''),
            destinatarioEmail,
            CorreoJSON.Get('estado', 'NL'),
            CorreoJSON.Get('asunto', ''),
            DateTimeToStr(Now),
            CorreoJSON.Get('mensaje', ''),
            False
          );
          Inc(correosCargados);
        end;
      end;
      ShowMessage(IntToStr(correosCargados) + ' correos han sido cargados exitosamente.');
    finally
      JsonData.Free;
      FileContent.Free;
    end;
  end;
end;

procedure TFormRoot.ButtonVerMensajesClick(Sender: TObject);
var
  nombreComunidad: String;
  comunidadEncontrada: PComunidad;
  Formulario: TFormVerMensajes;
begin
  if InputQuery('Ver Mensajes', 'Introduce el nombre de la comunidad:', nombreComunidad) then
  begin
    if Trim(nombreComunidad) = '' then
    begin
      ShowMessage('El nombre no puede estar vacío.');
      Exit;
    end;

    comunidadEncontrada := BuscarComunidad(arbolComunidades, nombreComunidad);

    if comunidadEncontrada = nil then
    begin
      ShowMessage('La comunidad "' + nombreComunidad + '" no fue encontrada.');
    end
    else
    begin
      Formulario := TFormVerMensajes.Create(Application);
      try
        Formulario.CargarMensajes(comunidadEncontrada);
        Formulario.ShowModal;
      finally
        Formulario.Free;
      end;
    end;
  end;
end;

procedure TFormRoot.ButtonCrearComunidadClick(Sender: TObject);
var
  Formulario: TFormCrearComunidad;
begin
  Formulario := TFormCrearComunidad.Create(Application);
  try
    Formulario.ShowModal;
  finally
    Formulario.Free;
  end;
end;

procedure TFormRoot.ButtonUsuariosClick(Sender: TObject);
var
  rutaReportes: String;
begin
  rutaReportes := 'Root-Reportes';

  ReporteUsuarios(listaUsuarios, rutaReportes);
  ReporteComunidades(rutaReportes);

  ShowMessage('Reportes de administrador generados en la carpeta "' + rutaReportes + '".');
end;

procedure TFormRoot.ButtonUsuariosContextPopup(Sender: TObject);
begin
end;

end.
