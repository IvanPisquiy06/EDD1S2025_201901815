unit uarbolbst;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uListaSimple;

procedure InsertarBST(var raiz: PNodoBST; nuevoContacto: PUsuario);
function BuscarBST(raiz: PNodoBST; email: String): Boolean;
procedure InOrden(raiz: PNodoBST; lista: TStrings);
procedure EliminarBST(var raiz: PNodoBST; email: String);

implementation

function EncontrarMinimo(raiz: PNodoBST): PNodoBST;
begin
  if (raiz = nil) or (raiz^.izquierda = nil) then
    Result := raiz
  else
    Result := EncontrarMinimo(raiz^.izquierda);
end;

procedure InsertarBST(var raiz: PNodoBST; nuevoContacto: PUsuario);
begin
  if raiz = nil then
  begin
    New(raiz);
    raiz^.contacto := nuevoContacto;
    raiz^.izquierda := nil;
    raiz^.derecha := nil;
  end
  else
  begin
    if nuevoContacto^.email < raiz^.contacto^.email then
      InsertarBST(raiz^.izquierda, nuevoContacto)
    else if nuevoContacto^.email > raiz^.contacto^.email then
      InsertarBST(raiz^.derecha, nuevoContacto);
  end;
end;

function BuscarBST(raiz: PNodoBST; email: String): Boolean;
begin
  if raiz = nil then
    Result := False
  else if email = raiz^.contacto^.email then
    Result := True
  else if email < raiz^.contacto^.email then
    Result := BuscarBST(raiz^.izquierda, email)
  else
    Result := BuscarBST(raiz^.derecha, email);
end;

procedure InOrden(raiz: PNodoBST; lista: TStrings);
begin
  if raiz <> nil then
  begin
    InOrden(raiz^.izquierda, lista);
    lista.AddObject(raiz^.contacto^.nombre + ' (' + raiz^.contacto^.email + ')', TObject(raiz^.contacto));
    InOrden(raiz^.derecha, lista);
  end;
end;

procedure EliminarBST(var raiz: PNodoBST; email: String);
var
  aux: PNodoBST;
  sucesor: PNodoBST;
begin
  if raiz = nil then Exit;

  if email < raiz^.contacto^.email then
    EliminarBST(raiz^.izquierda, email)
  else if email > raiz^.contacto^.email then
    EliminarBST(raiz^.derecha, email)
  else
  begin
    if (raiz^.izquierda = nil) then
    begin
      aux := raiz;
      raiz := raiz^.derecha;
      Dispose(aux);
    end
    else if (raiz^.derecha = nil) then
    begin
      aux := raiz;
      raiz := raiz^.izquierda;
      Dispose(aux);
    end
    else
    begin
      sucesor := EncontrarMinimo(raiz^.derecha);
      raiz^.contacto := sucesor^.contacto;
      EliminarBST(raiz^.derecha, sucesor^.contacto^.email);
    end;
  end;
end;

end.
