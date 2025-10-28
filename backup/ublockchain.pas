unit uBlockchain;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, uHashing, Generics.Collections;

const
  DIFICULTAD = 3;

type
  TDatosCorreoBlock = record
    ID: Integer;
    Remitente: String;
    Asunto: String;
    Mensaje: String;
  end;

  PBloque = ^TBloque;
  TBloque = record
    index: Integer;
    timestamp: TDateTime;
    datos: TDatosCorreoBlock;
    nonce: Integer;
    hash: String;
    hashAnterior: String;
    siguiente: PBloque;
  end;

// (La variable 'blockchain' ya NO se declara aquí)

procedure InitBlockchain;
procedure MinarYAnadirBloque(datos: TDatosCorreoBlock);
function VerificarCadena: Boolean;
function GetBlockchainHead: PBloque; // <-- NUEVO GETTER

implementation

var
  blockchain: PBloque = nil; // <-- Variable privada
  DificultadString: String;  // <-- Variable privada

procedure InitBlockchain;
begin
  if DificultadString = '' then
  begin
    DificultadString := StringOfChar('0', DIFICULTAD);
    blockchain := nil;
  end;
end;

function CalcularHashBloque(index: Integer; timestamp: TDateTime; datos: TDatosCorreoBlock; nonce: Integer; hashAnt: String): String;
var
  dataString: String;
begin
  dataString := IntToStr(index) +
                DateTimeToStr(timestamp) +
                IntToStr(datos.ID) +
                datos.Remitente +
                datos.Asunto +
                datos.Mensaje +
                IntToStr(nonce) +
                hashAnt;
  Result := CalcularSHA256(dataString);
end;

function GetUltimoBloque: PBloque;
var
  aux: PBloque;
begin
  InitBlockchain;
  if blockchain = nil then
  begin
    Result := nil;
    Exit;
  end;
  aux := blockchain;
  while aux^.siguiente <> nil do
    aux := aux^.siguiente;
  Result := aux;
end;

procedure CrearBloqueGenesis;
var
  genesisDatos: TDatosCorreoBlock;
begin
  InitBlockchain; // Asegura la inicialización

  New(blockchain);
  blockchain^.index := 0;
  blockchain^.timestamp := Now;

  genesisDatos.ID := 0;
  genesisDatos.Remitente := 'Sistema';
  genesisDatos.Asunto := 'Bloque Genesis';
  genesisDatos.Mensaje := '';

  blockchain^.datos := genesisDatos;
  blockchain^.nonce := 0;
  blockchain^.hashAnterior := '0';
  blockchain^.hash := CalcularHashBloque(0, blockchain^.timestamp, genesisDatos, 0, '0');
  blockchain^.siguiente := nil;
end;

function Minar(index: Integer; timestamp: TDateTime; datos: TDatosCorreoBlock; hashAnt: String): TPair<Integer, String>;
var
  nonce: Integer;
  hashCalculado: String;
begin
  InitBlockchain; // Asegura DificultadString
  nonce := 0;
  repeat
    Inc(nonce);
    hashCalculado := CalcularHashBloque(index, timestamp, datos, nonce, hashAnt);
  until hashCalculado.StartsWith(DificultadString);

  Result := TPair<Integer, String>.Create(nonce, hashCalculado);
end;

procedure MinarYAnadirBloque(datos: TDatosCorreoBlock);
var
  ultimoBloque: PBloque;
  nuevoBloque: PBloque;
  nuevoTimestamp: TDateTime;
  nuevoIndex: Integer;
  nuevoHashAnterior: String;
  minado: TPair<Integer, String>;
begin
  InitBlockchain; // Asegura inicialización
  if blockchain = nil then
    CrearBloqueGenesis;

  ultimoBloque := GetUltimoBloque;
  nuevoTimestamp := Now;
  nuevoIndex := ultimoBloque^.index + 1;
  nuevoHashAnterior := ultimoBloque^.hash;

  minado := Minar(nuevoIndex, nuevoTimestamp, datos, nuevoHashAnterior);

  New(nuevoBloque);
  nuevoBloque^.index := nuevoIndex;
  nuevoBloque^.timestamp := nuevoTimestamp;
  nuevoBloque^.datos := datos;
  nuevoBloque^.nonce := minado.Key;
  nuevoBloque^.hash := minado.Value;
  nuevoBloque^.hashAnterior := nuevoHashAnterior;
  nuevoBloque^.siguiente := nil;

  ultimoBloque^.siguiente := nuevoBloque;
end;

function VerificarCadena: Boolean;
var
  bloqueActual, bloqueAnterior: PBloque;
  hashCalculado: String;
begin
  InitBlockchain; // Asegura inicialización
  if blockchain = nil then
  begin
    Result := True;
    Exit;
  end;

  bloqueAnterior := blockchain;
  bloqueActual := blockchain^.siguiente;

  while bloqueActual <> nil do
  begin
    hashCalculado := CalcularHashBloque(
      bloqueActual^.index,
      bloqueActual^.timestamp,
      bloqueActual^.datos,
      bloqueActual^.nonce,
      bloqueActual^.hashAnterior
    );
    if hashCalculado <> bloqueActual^.hash then
    begin
      Result := False;
      Exit;
    end;
    if bloqueActual^.hashAnterior <> bloqueAnterior^.hash then
    begin
       Result := False;
       Exit;
    end;
    bloqueAnterior := bloqueActual;
    bloqueActual := bloqueActual^.siguiente;
  end;
  Result := True;
end;

function GetBlockchainHead: PBloque;
begin
  InitBlockchain;
  Result := blockchain;
end;

end.
