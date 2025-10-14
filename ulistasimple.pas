unit uListaSimple;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Dialogs, ulistadoble, upila, ucola, uarbolavl, uarbolb;

type
  PNodoBST = ^TNodoBST;
  PUsuario = ^TUsuario;

  TNodoBST = record
    contacto: PUsuario;
    izquierda: PNodoBST;
    derecha: PNodoBST;
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
    contactosBST: PNodoBST;
    pilaPapelera: PElementoPila;
    borradores: PNodoAVL;
    colaProgramadosFrente: PElementoCola;
    colaProgramadosFin: PElementoCola;
    favoritos: PPaginaB;
  end;

var
  listaUsuarios: PUsuario = nil;

procedure InsertarUsuario(var lista: PUsuario; id: Integer; nombre, usuario, email, telefono, password: String);
procedure MostrarUsuarios(lista: PUsuario);
function IniciarSesion(lista: PUsuario; usuario, password: String): PUsuario;
function ExisteUsuario(lista: PUsuario; email, usuario: String): Boolean;
function BuscarUsuarioEmail(lista: PUsuario; email: String): PUsuario;
function EsContacto(usuario: PUsuario; email: String): Boolean;

implementation

uses
  uarbolbst;

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
  nuevo^.contactosBST := nil;
  nuevo^.pilaPapelera := nil;
  nuevo^.borradores := nil;
  nuevo^.colaProgramadosFrente := nil;
  nuevo^.colaProgramadosFin := nil;
  nuevo^.favoritos := nil;

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

function IniciarSesion(lista: PUsuario; usuario, password: String): PUsuario;
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
    if (aux^.usuario = usuario) and (aux^.password = password) then
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

function EsContacto(usuario: PUsuario; email: String): Boolean;
begin
  if (usuario = nil) or (usuario^.contactosBST = nil) then
  begin
    Result := False;
    Exit;
  end;

  Result := BuscarBST(usuario^.contactosBST, email);
end;

end.

