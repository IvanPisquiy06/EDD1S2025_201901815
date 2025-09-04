unit uListaSimple;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Dialogs, ulistadoble, upila;

type
  PUsuario = ^TUsuario;
  PContacto = ^TContacto;

  TContacto = record
    refUsuario: PUsuario;
    siguiente: PContacto;
    anterior: PContacto;
  end;

  TUsuario = record
    id: Integer;
    nombre: String;
    usuario: String;
    email: String;
    telefono: String;
    password: String;
    siguiente: PUsuario;
    bandejaEntrada: PCorreo;
    contactos: PContacto;
    pilaPapelera: PElementoPila;
    colaProgramadosFrente: PElementoCola;
    colaProgramadosFin: PElementoCola;
  end;

var
  listaUsuarios: PUsuario = nil;

procedure InsertarUsuario(var lista: PUsuario; id: Integer; nombre, usuario, email, telefono, password: String);
procedure MostrarUsuarios(lista: PUsuario);
procedure AgregarContacto(var lista: PContacto; nuevoUsuario: PUsuario);
function IniciarSesion(lista: PUsuario; email, password: String): PUsuario;
function ExisteUsuario(lista: PUsuario; email, usuario: String): Boolean;
function BuscarUsuarioEmail(lista: PUsuario; email: String): PUsuario;
function EsContacto(usuario: PUsuario; email: String): Boolean;

implementation

procedure InsertarUsuario(var lista: PUsuario; id: Integer; nombre, usuario, email, telefono, password: String);
var
  nuevo, aux: PUsuario;
begin
  New(nuevo);
  nuevo^.id := id;
  nuevo^.nombre := nombre;
  nuevo^.usuario := usuario;
  nuevo^.email := email;
  nuevo^.telefono := telefono;
  nuevo^.password:= password;
  nuevo^.siguiente := nil;
  nuevo^.bandejaEntrada := nil;
  nuevo^.pilaPapelera := nil;
  nuevo^.colaProgramadosFrente := nil;
  nuevo^.colaProgramadosFin := nil;

  if lista = nil then
    lista := nuevo
  else
  begin
    aux := lista;
    while aux^.siguiente <> nil do
      aux := aux^.siguiente;
    aux^.siguiente := nuevo;
  end;
end;

procedure MostrarUsuarios(lista: PUsuario);
var
  aux: PUsuario;
begin
  aux := lista;
  while aux <> nil do
  begin
    aux := aux^.siguiente;
  end;
end;

function IniciarSesion(lista: PUsuario; email, password: String): PUsuario;
var
  aux: PUsuario;
begin
  if lista = nil then
  begin
    Result := nil;
    Exit;
  end;

  aux := lista;
  while aux <> nil do
  begin
    if (aux^.email = email) and (aux^.password = password) then
    begin
      Result := aux;
      Exit;
    end;
    aux := aux^.siguiente;
  end;
  Result := nil;
end;

function ExisteUsuario(lista: PUsuario; email, usuario: String): Boolean;
var
  aux: PUsuario;
begin
  aux := lista;
  while aux <> nil do
  begin
    if (aux^.email = email) or (aux^.usuario = usuario) then
    begin
      Result := True;
      Exit;
    end;
    aux := aux^.siguiente;
  end;
  Result := False;
end;

function BuscarUsuarioEmail(lista: PUsuario; email: String): PUsuario;
var
  aux: PUsuario;
begin
  aux := lista;
  while aux <> nil do
  begin
    if aux^.email = email then
  begin
    Result := aux;
    Exit;
  end;
  aux := aux^.siguiente;
end;
Result := nil;
end;

procedure AgregarContacto(var lista: PContacto; nuevoUsuario: PUsuario);
var
  nuevo, aux: PContacto;
begin
     New(nuevo);
     nuevo^.refUsuario := nuevoUsuario;

     if lista = nil then
     begin
       lista := nuevo;
       nuevo^.siguiente := nuevo;
       nuevo^.anterior := nuevo;
     end
     else
     begin
          aux := lista^.anterior;
          aux^.siguiente := nuevo;
          nuevo^.anterior := aux;
          nuevo^.siguiente := lista;
          lista^.anterior := nuevo;
     end;
end;

function EsContacto(usuario: PUsuario; email: String): Boolean;
var
  aux:PContacto;
begin
  Result := False;
  if (usuario = nil) or (usuario^.contactos = nil) then Exit;

  aux := usuario^.contactos;
  repeat
    if aux^.refUsuario^.email = email then
    begin
      Result := True;
      Exit;
    end;
    aux := aux^.siguiente;
  until aux = usuario^.contactos;
end;

end.

