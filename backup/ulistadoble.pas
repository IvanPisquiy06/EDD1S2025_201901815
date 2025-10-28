unit ulistadoble;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uhuffman, Generics.Collections, Types; // <-- AÑADIDO Generics.Collections y Types

type
  PCorreo = ^TCorreo;
  TCorreo = record
    id: Integer;
    remitente: String;
    destinatario: String;
    estado: String;
    programado: Boolean;
    asunto: String;
    fecha: String;
    mensaje: String;
    tablaCodigos: TTablaCodigos;
    esPrivado: Boolean;
    anterior: PCorreo;
    siguiente: PCorreo;
  end;

  procedure InsertarCorreo(var lista: PCorreo; id: Integer; remitente, destinatario,
  estado, asunto, fecha, mensaje: String; esPrivado: Boolean);

  function SiguienteIdGlobalCorreo: Integer;

  // --- CORRECCIÓN AQUÍ ---
  // Ahora la interface coincide con la implementation
  procedure ActualizarIdGlobalCorreo(nuevoMaximo: Integer);
  // --- FIN DE LA CORRECCIÓN ---

  procedure MostrarCorreos(lista: PCorreo);

implementation

uses
  Contnrs; // 'Contnrs' y 'Types' se pueden mover aquí si 'uhuffman' no los necesita en su interface

var idGlobalCorreo: Integer = 0;

procedure InsertarCorreo(var lista: PCorreo; id: Integer; remitente, destinatario,
  estado, asunto, fecha, mensaje: String; esPrivado: Boolean);
var
  nuevo: PCorreo;
  aux: PCorreo;
  tablaDeCodigos: TTablaCodigos;
  mensajeComprimido: String;
begin
  mensajeComprimido := ComprimirHuffman(mensaje, tablaDeCodigos);

  New(nuevo);
  nuevo^.id := id;
  nuevo^.remitente := remitente;
  nuevo^.destinatario := destinatario;
  nuevo^.estado := estado;
  nuevo^.asunto := asunto;
  nuevo^.fecha := fecha;
  nuevo^.mensaje := mensajeComprimido;
  nuevo^.tablaCodigos := tablaDeCodigos;
  nuevo^.esPrivado := esPrivado;
  nuevo^.anterior := nil;
  nuevo^.siguiente := nil;

  if lista = nil then
  begin
    lista := nuevo;
  end
  else
  begin
    aux := lista;
    while aux^.siguiente <> nil do
      aux := aux^.siguiente;
    aux^.siguiente := nuevo;
    nuevo^.anterior := aux;
  end;
end;

function SiguienteIdGlobalCorreo: Integer;
begin
  Inc(idGlobalCorreo);
  Result := idGlobalCorreo;
end;

procedure ActualizarIdGlobalCorreo(nuevoMaximo: Integer);
begin
  if nuevoMaximo > idGlobalCorreo then
    idGlobalCorreo := nuevoMaximo;
end;

procedure MostrarCorreos(lista: PCorreo);
var
   aux: PCorreo;
begin
     aux := lista;
     while aux <> nil do
     aux := aux^.siguiente;
end;
end.
