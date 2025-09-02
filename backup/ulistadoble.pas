unit ulistadoble;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  PCorreo = ^TCorreo;
  TCorreo = record
    id: Integer;
    remitente: String;
    estado: String;
    programado: Boolean;
    asunto: String;
    fecha: String;
    mensaje: String;
    anterior: PCorreo;
    siguiente: PCorreo;
  end;

  procedure InsertarCorreo(var lista: PCorreo; id: Integer; remitente, estado, asunto, fecha, mensaje: String; programado: Boolean);
  procedure MostrarCorreos(lista: PCorreo);

implementation

procedure InsertarCorreo(var lista: PCorreo; id: Integer; remitente, estado, asunto, fecha, mensaje: String; programado: Boolean);
var
   nuevo, aux: PCorreo;
begin
  New(nuevo);
  nuevo^.id := id;
  nuevo^.remitente := remitente;
  nuevo^.estado := estado;
  nuevo^.asunto := asunto;
  nuevo^.fecha := fecha;
  nuevo^.mensaje := mensaje;
  nuevo^.programado := programado;
  nuevo^.siguiente := nil;
  nuevo^.anterior := nil;

  if lista = nil then
     lista := nuevo
  else
  begin
    aux := lista;
    while aux^.siguiente <> nil do
          aux := aux^.siguiente;
    aux^.siguiente := nuevo;
    nuevo^.anterior := aux;
  end;
end;

procedure MostrarCorreos(lista: PCorreo);
var
   aux := PCorreo;
begin
     aux := lista;
     while aux <> nil do
     aux := aux^.siguiente;
end;
end.

