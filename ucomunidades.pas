unit uComunidades;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uListaSimple;

type
  PMensajeComunidad = ^TMensajeComunidad;
  TMensajeComunidad = record
    mensaje: String;
    autor: PUsuario;
    fecha: String;
    siguiente: PMensajeComunidad;
  end;

  PComunidad = ^TComunidad;
  TComunidad = record
    nombre: String;
    fechaCreacion: String;
    mensajes: PMensajeComunidad;
    izquierda: PComunidad;
    derecha: PComunidad;
  end;

var
  arbolComunidades: PComunidad = nil;

function CrearComunidad(var raiz: PComunidad; nombre: String): Boolean;

function BuscarComunidad(raiz: PComunidad; nombre: String): PComunidad;

procedure PublicarMensaje(comunidad: PComunidad; autor: PUsuario; mensaje: String);

implementation

function CrearComunidad(var raiz: PComunidad; nombre: String): Boolean;
begin
  if raiz = nil then
  begin
    New(raiz);
    raiz^.nombre := nombre;
    raiz^.fechaCreacion := DateTimeToStr(Now);
    raiz^.mensajes := nil;
    raiz^.izquierda := nil;
    raiz^.derecha := nil;
    Result := True;
  end
  else if nombre < raiz^.nombre then
    Result := CrearComunidad(raiz^.izquierda, nombre)
  else if nombre > raiz^.nombre then
    Result := CrearComunidad(raiz^.derecha, nombre)
  else
    Result := False;
end;

function BuscarComunidad(raiz: PComunidad; nombre: String): PComunidad;
begin
  if raiz = nil then
    Result := nil
  else if nombre = raiz^.nombre then
    Result := raiz
  else if nombre < raiz^.nombre then
    Result := BuscarComunidad(raiz^.izquierda, nombre)
  else
    Result := BuscarComunidad(raiz^.derecha, nombre);
end;

procedure PublicarMensaje(comunidad: PComunidad; autor: PUsuario; mensaje: String);
var
  nuevoMensaje: PMensajeComunidad;
begin
  if comunidad = nil then Exit;

  New(nuevoMensaje);
  nuevoMensaje^.mensaje := mensaje;
  nuevoMensaje^.autor := autor;
  nuevoMensaje^.fecha := DateTimeToStr(Now);

  nuevoMensaje^.siguiente := comunidad^.mensajes;
  comunidad^.mensajes := nuevoMensaje;
end;

end.
