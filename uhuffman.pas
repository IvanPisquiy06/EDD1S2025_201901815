unit uhuffman;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Generics.Collections, Types;

type
  PHuffmanNode = ^THuffmanNode;
  THuffmanNode = record
    caracter: Char;
    frecuencia: Integer;
    izquierda: PHuffmanNode;
    derecha: PHuffmanNode;
  end;

  // 2. Tabla de Códigos
  TTablaCodigos = TDictionary<String, String>;

  // --- Funciones Públicas ---

function ComprimirHuffman(texto: String; out tabla: TTablaCodigos): String;
function DescomprimirHuffman(textoComprimido: String; raizArbol: PHuffmanNode): String;
function ConstruirArbolDesdeTabla(tabla: TTablaCodigos): PHuffmanNode;

implementation

// --- Lógica de la Lista de Prioridad ---
type
  TListaPrioridad = class(TFPList)
  private
    function GetNodo(Index: Integer): PHuffmanNode;
  public
    procedure InsertarOrdenado(nodo: PHuffmanNode);
    function ExtraerMinimo: PHuffmanNode;
    property Nodos[Index: Integer]: PHuffmanNode read GetNodo;
  end;

function TListaPrioridad.GetNodo(Index: Integer): PHuffmanNode;
begin
  Result := PHuffmanNode(inherited Get(Index));
end;

procedure TListaPrioridad.InsertarOrdenado(nodo: PHuffmanNode);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if nodo^.frecuencia < Nodos[i]^.frecuencia then
    begin
      Insert(i, nodo);
      Exit;
    end;
  end;
  Add(nodo);
end;

function TListaPrioridad.ExtraerMinimo: PHuffmanNode;
begin
  if Count = 0 then
  begin
    Result := nil;
    Exit;
  end;
  Result := Nodos[0];
  Delete(0);
end;

// --- Lógica de Construcción del Árbol ---

procedure ContarFrecuencias(texto: String; var freqs: TIntegerDynArray);
var
  c: Char;
  i: Integer; // Necesario para inicializar
begin
  SetLength(freqs, 256);
  // Inicializamos el array a 0
  for i := 0 to 255 do
    freqs[i] := 0;

  for c in texto do
    Inc(freqs[Byte(c)]);
end;

function ConstruirArbol(freqs: TIntegerDynArray): PHuffmanNode;
var
  lista: TListaPrioridad;
  i: Integer;
  nodo: PHuffmanNode;
  izq, der, padre: PHuffmanNode;
begin
  lista := TListaPrioridad.Create;
  try
    for i := 0 to 255 do
    begin
      if freqs[i] > 0 then
      begin
        New(nodo);
        nodo^.caracter := Char(i);
        nodo^.frecuencia := freqs[i];
        nodo^.izquierda := nil;
        nodo^.derecha := nil;
        lista.InsertarOrdenado(nodo);
      end;
    end;

    while lista.Count > 1 do
    begin
      izq := lista.ExtraerMinimo;
      der := lista.ExtraerMinimo;
      New(padre);
      padre^.caracter := #0;
      padre^.frecuencia := izq^.frecuencia + der^.frecuencia;
      padre^.izquierda := izq;
      padre^.derecha := der;
      lista.InsertarOrdenado(padre);
    end;
    Result := lista.ExtraerMinimo;
  finally
    lista.Free;
  end;
end;

// --- Lógica de Generación de Tabla de Códigos ---

procedure GenerarCodigos(nodo: PHuffmanNode; codigoActual: String; var tabla: TTablaCodigos);
begin
  if nodo = nil then Exit;
  if (nodo^.izquierda = nil) and (nodo^.derecha = nil) then
  begin
    tabla.Add(String(nodo^.caracter), codigoActual);
  end
  else
  begin
    GenerarCodigos(nodo^.izquierda, codigoActual + '0', tabla);
    GenerarCodigos(nodo^.derecha, codigoActual + '1', tabla);
  end;
end;

// --- Lógica de Compresión y Descompresión ---

function ComprimirHuffman(texto: String; out tabla: TTablaCodigos): String;
var
  freqs: TIntegerDynArray;
  raiz: PHuffmanNode;
  c: Char;
begin
  tabla := TTablaCodigos.Create;
  ContarFrecuencias(texto, freqs);
  raiz := ConstruirArbol(freqs);
  GenerarCodigos(raiz, '', tabla);

  Result := '';
  for c in texto do
  begin
    // --- 2. CORRECCIÓN AQUÍ ---
    // Reemplazamos GetValueOrDefault con un método más compatible
    if tabla.ContainsKey(String(c)) then
      Result := Result + tabla.Items[String(c)];
  end;
  // (Idealmente, aquí se liberaría la memoria del 'raiz')
end;

function DescomprimirHuffman(textoComprimido: String; raizArbol: PHuffmanNode): String;
var
  nodoActual: PHuffmanNode;
  bit: Char;
begin
  Result := '';
  if raizArbol = nil then Exit;

  nodoActual := raizArbol;
  for bit in textoComprimido do
  begin
    if bit = '0' then
      nodoActual := nodoActual^.izquierda
    else
      nodoActual := nodoActual^.derecha;

    // Comprobación de seguridad contra datos corruptos
    if nodoActual = nil then
    begin
      nodoActual := raizArbol;
      Continue;
    end;

    if (nodoActual^.izquierda = nil) and (nodoActual^.derecha = nil) then
    begin
      Result := Result + nodoActual^.caracter;
      nodoActual := raizArbol;
    end;
  end;
end;

function ConstruirArbolDesdeTabla(tabla: TTablaCodigos): PHuffmanNode;
var
  raiz, nodoActual: PHuffmanNode;
  par: TPair<String, String>;
  codigo: String;
  caracter: Char;
  bit: Char;
begin
  New(raiz);
  raiz^.izquierda := nil;
  raiz^.derecha := nil;
  raiz^.caracter := #0;

  for par in tabla do
  begin
    caracter := par.Key[1];
    codigo := par.Value;
    nodoActual := raiz;

    for bit in codigo do
    begin
      if bit = '0' then
      begin
        if nodoActual^.izquierda = nil then
        begin
          New(nodoActual^.izquierda);
          nodoActual^.izquierda^.izquierda := nil;
          nodoActual^.izquierda^.derecha := nil;
          nodoActual^.izquierda^.caracter := #0;
        end;
        nodoActual := nodoActual^.izquierda;
      end
      else
      begin
        if nodoActual^.derecha = nil then
        begin
          New(nodoActual^.derecha);
          nodoActual^.derecha^.izquierda := nil;
          nodoActual^.derecha^.derecha := nil;
          nodoActual^.derecha^.caracter := #0;
        end;
        nodoActual := nodoActual^.derecha;
      end;
    end;
    nodoActual^.caracter := caracter;
  end;
  Result := raiz;
end;

end.
