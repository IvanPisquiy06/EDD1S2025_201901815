unit ulogcontrol;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uListaSimple, fpjson, jsonparser;

type
  PLogSession = ^TLogSession;
  TLogSession = record
    usuario: PUsuario;
    entrada: TDateTime;
    salida: TDateTime;
    siguiente: PLogSession;
  end;

function IniciarSesionLog(u: PUsuario): PLogSession;
procedure CerrarSesionLog(sesion: PLogSession);
procedure GenerarJSONLog(ruta: String);
function GetListaGlobalSesiones: PLogSession;

implementation
var
  listaGlobalSesiones: PLogSession = nil;

function IniciarSesionLog(u: PUsuario): PLogSession;
var
  nuevaSesion: PLogSession;
begin
  New(nuevaSesion);
  nuevaSesion^.usuario := u;
  nuevaSesion^.entrada := Now;
  nuevaSesion^.salida := 0;

  nuevaSesion^.siguiente := listaGlobalSesiones;
  listaGlobalSesiones := nuevaSesion;

  Result := nuevaSesion;
end;

procedure CerrarSesionLog(sesion: PLogSession);
begin
  if (sesion <> nil) and (sesion^.salida = 0) then
  begin
    sesion^.salida := Now;
  end;
end;

function GetListaGlobalSesiones: PLogSession;
begin
  Result := listaGlobalSesiones;
end;

procedure GenerarJSONLog(ruta: String);
var
  jsonArray: TJSONArray;
  sesionObj: TJSONObject;
  aux: PLogSession;
  ss: TStringStream;
  salidaStr: String;
begin
  jsonArray := TJSONArray.Create;
  aux := listaGlobalSesiones;

  while aux <> nil do
  begin
    sesionObj := TJSONObject.Create;
    sesionObj.Add('usuario', aux^.usuario^.email);
    sesionObj.Add('entrada', FormatDateTime('yyyy-mm-dd hh:nn:ss', aux^.entrada));

    if aux^.salida = 0 then
      salidaStr := '(sesion activa)'
    else
      salidaStr := FormatDateTime('yyyy-mm-dd hh:nn:ss', aux^.salida);

    sesionObj.Add('salida', salidaStr);

    jsonArray.Add(sesionObj);
    aux := aux^.siguiente;
  end;

  try
    ss := TStringStream.Create(jsonArray.AsJSON);
    ss.SaveToFile(ruta);
  finally
    ss.Free;
    jsonArray.Free;
  end;
end;

end.
