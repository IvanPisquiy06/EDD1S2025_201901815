unit upila;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ulistadoble;

type
  PElementoPila = ^TElementoPila;
  TElementoPila = record
    correo: PCorreo;
    siguiente: PElementoPila;
  end;

  procedure Push(var pila: PElementoPila; correo: PCorreo);
  function Pop(var pila: PElementoPila): PCorreo;
  function BuscarPila(pila: PElementoPila; palabra: String): PCorreo;

implementation

procedure Push(var pila: PElementoPila; correo: PCorreo);
var
   nuevo: PElementoPila;
begin
  New(nuevo);
  nuevo^.correo := correo;
  nuevo^.siguiente := pila;
  pila := nuevo;
end;

function Pop(var pila: PElementoPila): PCorreo;
var
   temp: PElementoPila;
begin
  if Pila = nil then
     Exit(nil);
  temp := pila;
  Result := temp^.correo;
  pila := pila^.siguiente;
  Dispose(temp);
end;

function BuscarPila(var pila: PElementoPila; palabra: String): PCorreo;
var
   aux: PElementoPila;
begin
   Result := nil;
   aux := pila;
   while aux <> nil do
   begin
     if Pos(LowerCase(palabra), LowerCase(aux^.correo^.asunto)) > 0 then
     begin
       Result := aux^.correo;
       Exit;
     end;
     aux := aux^.siguiente;
   end;
end;
end.
