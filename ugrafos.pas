unit ugrafos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uListaSimple;

type
  PAdyacente = ^TAdyacente;
  TAdyacente = record
    destino: PUsuario;
    siguiente: PAdyacente;
  end;

  PVertice = ^TVertice;
  TVertice = record
    usuario: PUsuario;
    adyacentes: PAdyacente;
    siguiente: PVertice;
  end;

var
  grafoUsuarios: PVertice = nil;

procedure InsertarVertice(usuario: PUsuario);

procedure InsertarArista(origen: PUsuario; destino: PUsuario);

procedure ConstruirGrafoGlobal(lista: PUsuario);

implementation

procedure InsertarVertice(usuario: PUsuario);
var
  nuevo: PVertice;
begin
  New(nuevo);
  nuevo^.usuario := usuario;
  nuevo^.adyacentes := nil;
  nuevo^.siguiente := grafoUsuarios;
  grafoUsuarios := nuevo;
end;

function BuscarVertice(usuario: PUsuario): PVertice;
var
  aux: PVertice;
begin
  aux := grafoUsuarios;
  while aux <> nil do
  begin
    if aux^.usuario = usuario then
    begin
      Result := aux;
      Exit;
    end;
    aux := aux^.siguiente;
  end;
  Result := nil;
end;

procedure InsertarArista(origen: PUsuario; destino: PUsuario);
var
  verticeOrigen: PVertice;
  nuevaArista: PAdyacente;
begin
  verticeOrigen := BuscarVertice(origen);
  if verticeOrigen <> nil then
  begin
    New(nuevaArista);
    nuevaArista^.destino := destino;
    nuevaArista^.siguiente := verticeOrigen^.adyacentes;
    verticeOrigen^.adyacentes := nuevaArista;
  end;
end;

procedure RecorrerContactosBST(raiz: PNodoBST; origen: PUsuario);
begin
  if raiz <> nil then
  begin
    InsertarArista(origen, raiz^.contacto);
    RecorrerContactosBST(raiz^.izquierda, origen);
    RecorrerContactosBST(raiz^.derecha, origen);
  end;
end;

procedure ConstruirGrafoGlobal(lista: PUsuario);
var
  auxUsuario: PUsuario;
begin
  grafoUsuarios := nil;

  auxUsuario := lista;
  while auxUsuario <> nil do
  begin
    InsertarVertice(auxUsuario);
    auxUsuario := auxUsuario^.siguiente;
  end;

  auxUsuario := lista;
  while auxUsuario <> nil do
  begin
    if auxUsuario^.contactosBST <> nil then
    begin
      RecorrerContactosBST(auxUsuario^.contactosBST, auxUsuario);
    end;
    auxUsuario := auxUsuario^.siguiente;
  end;
end;

end.
