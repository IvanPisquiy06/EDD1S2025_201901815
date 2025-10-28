unit uarbolb;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ulistadoble;

const
  ORDEN = 5;

type
  PPaginaB = ^TPaginaB;
  TPaginaB = record
    contador: Integer;
    claves: array[1..ORDEN-1] of PCorreo;
    ramas: array[1..ORDEN] of PPaginaB;
  end;

procedure InsertarB(var raiz: PPaginaB; correo: PCorreo);
function BuscarB(raiz: PPaginaB; id: Integer): PCorreo;
procedure RecorrerB(raiz: PPaginaB; lista: TStrings);
procedure EliminarB(var raiz: PPaginaB; id: Integer);

implementation

procedure Empujar(actual: PPaginaB; correo: PCorreo; var subeArriba: Boolean; var mediano: PCorreo; var nuevaPagina: PPaginaB); forward;
procedure MeterHoja(actual: PPaginaB; correo: PCorreo; rama: PPaginaB); forward;
procedure DividirPagina(actual: PPaginaB; var mediano: PCorreo; var nuevaPagina: PPaginaB); forward;

procedure EliminarRegistro(var pagina: PPaginaB; var underflow: Boolean; k: Integer); forward;
procedure Quitar(var pagina: PPaginaB; var underflow: Boolean; id: Integer); forward;
procedure Restablecer(var pagina: PPaginaB; var underflow: Boolean; pos: Integer); forward;

procedure Empujar(actual: PPaginaB; correo: PCorreo; var subeArriba: Boolean; var mediano: PCorreo; var nuevaPagina: PPaginaB);
var
  k: Integer;
begin
  if actual = nil then
  begin
    subeArriba := True;
    mediano := correo;
    nuevaPagina := nil;
  end
  else
  begin
    k := actual^.contador;
    while (k >= 1) and (correo^.id < actual^.claves[k]^.id) do
      Dec(k);

    Empujar(actual^.ramas[k+1], correo, subeArriba, mediano, nuevaPagina);

    if subeArriba then
    begin
      if actual^.contador < ORDEN - 1 then
      begin
        subeArriba := False;
        MeterHoja(actual, mediano, nuevaPagina);
      end
      else
      begin
        subeArriba := True;
        DividirPagina(actual, mediano, nuevaPagina);
      end;
    end;
  end;
end;

procedure MeterHoja(actual: PPaginaB; correo: PCorreo; rama: PPaginaB);
var
  i: Integer;
begin
  i := actual^.contador;
  while (i >= 1) and (correo^.id < actual^.claves[i]^.id) do
  begin
    actual^.claves[i+1] := actual^.claves[i];
    actual^.ramas[i+2] := actual^.ramas[i+1];
    Dec(i);
  end;
  actual^.claves[i+1] := correo;
  actual^.ramas[i+2] := rama;
  Inc(actual^.contador);
end;

procedure DividirPagina(actual: PPaginaB; var mediano: PCorreo; var nuevaPagina: PPaginaB);
var
  i, posMediana: Integer;
begin
  posMediana := (ORDEN) div 2;
  New(nuevaPagina);
  nuevaPagina^.contador := (ORDEN - 1) - posMediana;

  mediano := actual^.claves[posMediana];

  for i := 1 to nuevaPagina^.contador do
  begin
    nuevaPagina^.claves[i] := actual^.claves[i + posMediana];
    nuevaPagina^.ramas[i] := actual^.ramas[i + posMediana];
  end;
  nuevaPagina^.ramas[nuevaPagina^.contador + 1] := actual^.ramas[ORDEN];

  actual^.contador := posMediana - 1;
end;

procedure InsertarB(var raiz: PPaginaB; correo: PCorreo);
var
  subeArriba: Boolean;
  mediano: PCorreo;
  nuevaPagina, antiguaRaiz: PPaginaB;
begin
  subeArriba := False;
  mediano := nil;
  nuevaPagina := nil;

  Empujar(raiz, correo, subeArriba, mediano, nuevaPagina);

  if subeArriba then
  begin
    antiguaRaiz := raiz;
    New(raiz);
    raiz^.contador := 1;
    raiz^.claves[1] := mediano;
    raiz^.ramas[1] := antiguaRaiz;
    raiz^.ramas[2] := nuevaPagina;
  end;
end;

function BuscarB(raiz: PPaginaB; id: Integer): PCorreo;
var
  i: Integer;
begin
  Result := nil;
  if raiz = nil then Exit;

  i := raiz^.contador;
  while (i >= 1) and (id < raiz^.claves[i]^.id) do
    Dec(i);

  if (i > 0) and (id = raiz^.claves[i]^.id) then
    Result := raiz^.claves[i]
  else
    Result := BuscarB(raiz^.ramas[i+1], id);
end;

procedure RecorrerB(raiz: PPaginaB; lista: TStrings);
var
  i: Integer;
begin
  if raiz <> nil then
  begin
    for i := 1 to raiz^.contador do
    begin
      RecorrerB(raiz^.ramas[i], lista);
      lista.AddObject(IntToStr(raiz^.claves[i]^.id) + ' - ' + raiz^.claves[i]^.asunto, TObject(raiz^.claves[i]));
    end;
    RecorrerB(raiz^.ramas[raiz^.contador + 1], lista);
  end;
end;

procedure Quitar(var pagina: PPaginaB; var underflow: Boolean; id: Integer);
var
  k: Integer;
begin
  if pagina = nil then
  begin
    underflow := False;
    Exit;
  end;

  k := pagina^.contador;
  while (k >= 1) and (id < pagina^.claves[k]^.id) do Dec(k);

  if (k > 0) and (id = pagina^.claves[k]^.id) then
  begin
    EliminarRegistro(pagina, underflow, k);
  end
  else
  begin
    Quitar(pagina^.ramas[k+1], underflow, id);
    if underflow then Restablecer(pagina, underflow, k+1);
  end;
end;

procedure EliminarRegistro(var pagina: PPaginaB; var underflow: Boolean; k: Integer);
var
  i: Integer;
begin
  for i := k to pagina^.contador - 1 do
  begin
    pagina^.claves[i] := pagina^.claves[i+1];
    pagina^.ramas[i] := pagina^.ramas[i+1];
  end;
  pagina^.ramas[pagina^.contador] := pagina^.ramas[pagina^.contador+1];
  Dec(pagina^.contador);
  underflow := pagina^.contador < (ORDEN - 1) div 2;
end;

procedure MoverDerecha(var pagina: PPaginaB; pos: Integer);
var
  i: Integer;
begin
  for i := pagina^.ramas[pos]^.contador downto 1 do
  begin
    pagina^.ramas[pos]^.claves[i+1] := pagina^.ramas[pos]^.claves[i];
    pagina^.ramas[pos]^.ramas[i+1] := pagina^.ramas[pos]^.ramas[i];
  end;
  pagina^.ramas[pos]^.ramas[1] := pagina^.ramas[pos-1]^.ramas[pagina^.ramas[pos-1]^.contador + 1];
  Inc(pagina^.ramas[pos]^.contador);
  pagina^.ramas[pos]^.claves[1] := pagina^.claves[pos-1];
  pagina^.claves[pos-1] := pagina^.ramas[pos-1]^.claves[pagina^.ramas[pos-1]^.contador];
  Dec(pagina^.ramas[pos-1]^.contador);
end;

procedure MoverIzquierda(var pagina: PPaginaB; pos: Integer);
var
  i: Integer;
begin
  Inc(pagina^.ramas[pos-1]^.contador);
  pagina^.ramas[pos-1]^.claves[pagina^.ramas[pos-1]^.contador] := pagina^.claves[pos];
  pagina^.ramas[pos-1]^.ramas[pagina^.ramas[pos-1]^.contador + 1] := pagina^.ramas[pos]^.ramas[1];
  pagina^.claves[pos] := pagina^.ramas[pos]^.claves[1];
  Dec(pagina^.ramas[pos]^.contador);
  for i := 1 to pagina^.ramas[pos]^.contador do
  begin
    pagina^.ramas[pos]^.claves[i] := pagina^.ramas[pos]^.claves[i+1];
    pagina^.ramas[pos]^.ramas[i] := pagina^.ramas[pos]^.ramas[i+1];
  end;
  pagina^.ramas[pos]^.ramas[pagina^.ramas[pos]^.contador] := pagina^.ramas[pos]^.ramas[pagina^.ramas[pos]^.contador + 1];
end;

procedure Combinar(var pagina: PPaginaB; pos: Integer);
var
  i: Integer;
begin
  Inc(pagina^.ramas[pos-1]^.contador);
  pagina^.ramas[pos-1]^.claves[pagina^.ramas[pos-1]^.contador] := pagina^.claves[pos];
  pagina^.ramas[pos-1]^.ramas[pagina^.ramas[pos-1]^.contador + 1] := pagina^.ramas[pos]^.ramas[1];
  for i := 1 to pagina^.ramas[pos]^.contador do
  begin
    Inc(pagina^.ramas[pos-1]^.contador);
    pagina^.ramas[pos-1]^.claves[pagina^.ramas[pos-1]^.contador] := pagina^.ramas[pos]^.claves[i];
    pagina^.ramas[pos-1]^.ramas[pagina^.ramas[pos-1]^.contador + 1] := pagina^.ramas[pos]^.ramas[i+1];
  end;
  for i := pos to pagina^.contador - 1 do
  begin
    pagina^.claves[i] := pagina^.claves[i+1];
    pagina^.ramas[i] := pagina^.ramas[i+1];
  end;
  Dec(pagina^.contador);
end;

procedure Restablecer(var pagina: PPaginaB; var underflow: Boolean; pos: Integer);
begin
  if pos > 1 then
  begin
    if pagina^.ramas[pos-1]^.contador > (ORDEN - 1) div 2 then
      MoverDerecha(pagina, pos)
    else
      Combinar(pagina, pos);
  end
  else
  begin
    if pagina^.ramas[2]^.contador > (ORDEN - 1) div 2 then
      MoverIzquierda(pagina, 1)
    else
      Combinar(pagina, 2);
  end;
  underflow := pagina^.contador < (ORDEN - 1) div 2;
end;

procedure EliminarB(var raiz: PPaginaB; id: Integer);
var
  underflow: Boolean;
begin
  underflow := False;
  Quitar(raiz, underflow, id);
  if underflow and (raiz^.contador = 0) then
  begin
    raiz := raiz^.ramas[1];
  end;
end;

end.
