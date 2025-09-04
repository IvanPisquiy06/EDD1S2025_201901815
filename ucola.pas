unit ucola;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ulistadoble;

type
  PElementoCola = ^TElementoCola;
  TElementoCola = record
    correo: PCorreo;
    fechaHora: TDateTime;
    siguiente: PElementoCola;
  end;

procedure Encolar(var frente, fin: PElementoCola; correo: PCorreo; fechaHora: TDateTime);
function Desencolar(var frente, fin: PElementoCola): PCorreo;
function VerPrimero(frente: PElementoCola): PCorreo;

implementation

procedure Encolar(var frente, fin: PElementoCola; correo: PCorreo; fechaHora: TDateTime);
var
   nuevo: PElementoCola;
begin
  New(nuevo);
  nuevo^.correo := correo;
  nuevo^.fechaHora := fechaHora;
  nuevo^.siguiente := nil;

  if frente = nil then
  begin
    frente := nuevo;
    fin := nuevo;
  end
  else
  begin
    fin^.siguiente := nuevo;
    fin := nuevo;
  end;
end;

function Desencolar(var frente, fin: PElementoCola): PCorreo;
var
   temp: PElementoCola;
begin
  if frente = nil then Exit(nil);

  temp := frente;
  Result := temp^.correo;
  frente := frente^.siguiente;

  if frente = nil then
     fin := nil;

  Dispose(temp);
end;

function VerPrimero(frente: PElementoCola): PCorreo;
begin
  if frente = nil then Exit(nil);
  Result := frente^.correo;
end;

end.

