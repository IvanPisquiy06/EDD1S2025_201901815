unit uarbolavl;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ulistadoble;

type
  PNodoAVL = ^TNodoAVL;
  TNodoAVL = record
    correo: PCorreo;
    izquierda: PNodoAVL;
    derecha: PNodoAVL;
    factorEquilibrio: Integer;
  end;
function InsertarAVL(var raiz: PNodoAVL; correo: PCorreo; var alturaCambia: Boolean): Boolean;
function EliminarAVL(var raiz: PNodoAVL; idCorreo: Integer; var alturaCambia: Boolean): Boolean;

procedure PreOrden(raiz: PNodoAVL; lista: TStrings);
procedure InOrden(raiz: PNodoAVL; lista: TStrings);
procedure PostOrden(raiz: PNodoAVL; lista: TStrings);

implementation

function RotacionSimpleIzquierda(var n: PNodoAVL): PNodoAVL;
var
  n1: PNodoAVL;
begin
  n1 := n^.derecha;
  n^.derecha := n1^.izquierda;
  n1^.izquierda := n;
  Result := n1;
end;

function RotacionSimpleDerecha(var n: PNodoAVL): PNodoAVL;
var
  n1: PNodoAVL;
begin
  n1 := n^.izquierda;
  n^.izquierda := n1^.derecha;
  n1^.derecha := n;
  Result := n1;
end;

function RotacionDobleIzquierda(var n: PNodoAVL): PNodoAVL;
var
  n1: PNodoAVL;
begin
  n1 := n^.derecha^.izquierda;
  n^.derecha^.izquierda := n1^.derecha;
  n1^.derecha := n^.derecha;
  n^.derecha := n1^.izquierda;
  n1^.izquierda := n;
  Result := n1;
end;

function RotacionDobleDerecha(var n: PNodoAVL): PNodoAVL;
var
  n1: PNodoAVL;
begin
  n1 := n^.izquierda^.derecha;
  n^.izquierda^.derecha := n1^.izquierda;
  n1^.izquierda := n^.izquierda;
  n^.izquierda := n1^.derecha;
  n1^.derecha := n;
  Result := n1;
end;

function InsertarAVL(var raiz: PNodoAVL; correo: PCorreo; var alturaCambia: Boolean): Boolean;
var
  n1: PNodoAVL;
begin
  if raiz = nil then
  begin
    New(raiz);
    raiz^.correo := correo;
    raiz^.izquierda := nil;
    raiz^.derecha := nil;
    raiz^.factorEquilibrio := 0;
    alturaCambia := True;
    Result := True;
  end
  else if correo^.id < raiz^.correo^.id then
  begin
    if InsertarAVL(raiz^.izquierda, correo, alturaCambia) then
    begin
      if alturaCambia then
      begin
        case raiz^.factorEquilibrio of
          1:
            begin
              raiz^.factorEquilibrio := 0;
              alturaCambia := False;
            end;
          0:
            raiz^.factorEquilibrio := -1;
          -1:
            begin
              n1 := raiz^.izquierda;
              if n1^.factorEquilibrio = -1 then
                raiz := RotacionSimpleDerecha(raiz)
              else
                raiz := RotacionDobleDerecha(raiz);
              raiz^.factorEquilibrio := 0;
              alturaCambia := False;
            end;
        end;
      end;
      Result := True;
    end
    else
      Result := False;
  end
  else if correo^.id > raiz^.correo^.id then
  begin
    if InsertarAVL(raiz^.derecha, correo, alturaCambia) then
    begin
       if alturaCambia then
       begin
         case raiz^.factorEquilibrio of
           -1:
             begin
               raiz^.factorEquilibrio := 0;
               alturaCambia := False;
             end;
           0:
             raiz^.factorEquilibrio := 1;
           1:
             begin
               n1 := raiz^.derecha;
               if n1^.factorEquilibrio = 1 then
                 raiz := RotacionSimpleIzquierda(raiz)
               else
                 raiz := RotacionDobleIzquierda(raiz);

               raiz^.factorEquilibrio := 0;
               alturaCambia := False;
             end;
         end;
       end;
       Result := True;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;

function balancearIzquierda(var n: PNodoAVL; var alturaCambia: Boolean): PNodoAVL;
var
  n1: PNodoAVL;
  fe_n1: Integer;
begin
  n1 := n^.izquierda;
  case n1^.factorEquilibrio of
    -1: // Rotación simple derecha
      begin
        n^.factorEquilibrio := 0;
        n1^.factorEquilibrio := 0;
        Result := RotacionSimpleDerecha(n);
        alturaCambia := True;
      end;
    1:  // Rotación doble derecha
      begin
        fe_n1 := n1^.derecha^.factorEquilibrio;
        case fe_n1 of
          -1:
            begin
              n^.factorEquilibrio := 1;
              n1^.factorEquilibrio := 0;
            end;
          0:
            begin
              n^.factorEquilibrio := 0;
              n1^.factorEquilibrio := 0;
            end;
          1:
            begin
              n^.factorEquilibrio := 0;
              n1^.factorEquilibrio := -1;
            end;
        end;
        n1^.derecha^.factorEquilibrio := 0;
        Result := RotacionDobleDerecha(n);
        alturaCambia := True;
      end;
    0: // Caso especial, rotación simple derecha
      begin
        n^.factorEquilibrio := -1;
        n1^.factorEquilibrio := 1;
        Result := RotacionSimpleDerecha(n);
        alturaCambia := False;
      end;
  end;
end;

function balancearDerecha(var n: PNodoAVL; var alturaCambia: Boolean): PNodoAVL;
var
  n1: PNodoAVL;
  fe_n1: Integer;
begin
  n1 := n^.derecha;
  case n1^.factorEquilibrio of
    1:  // Rotación simple izquierda
      begin
        n^.factorEquilibrio := 0;
        n1^.factorEquilibrio := 0;
        Result := RotacionSimpleIzquierda(n);
        alturaCambia := True;
      end;
    -1: // Rotación doble izquierda
      begin
        fe_n1 := n1^.izquierda^.factorEquilibrio;
        case fe_n1 of
          -1:
            begin
              n^.factorEquilibrio := 0;
              n1^.factorEquilibrio := 1;
            end;
          0:
            begin
              n^.factorEquilibrio := 0;
              n1^.factorEquilibrio := 0;
            end;
          1:
            begin
              n^.factorEquilibrio := -1;
              n1^.factorEquilibrio := 0;
            end;
        end;
        n1^.izquierda^.factorEquilibrio := 0;
        Result := RotacionDobleIzquierda(n);
        alturaCambia := True;
      end;
    0: // Caso especial, rotación simple izquierda
      begin
        n^.factorEquilibrio := 1;
        n1^.factorEquilibrio := -1;
        Result := RotacionSimpleIzquierda(n);
        alturaCambia := False;
      end;
  end;
end;

function EliminarAVL(var raiz: PNodoAVL; idCorreo: Integer; var alturaCambia: Boolean): Boolean;
var
  sucesor: PNodoAVL;
begin
  if raiz = nil then
  begin
    Result := False;
    Exit;
  end;

  if idCorreo < raiz^.correo^.id then
  begin
    if EliminarAVL(raiz^.izquierda, idCorreo, alturaCambia) then
    begin
      if alturaCambia then
        raiz := balancearDerecha(raiz, alturaCambia);
      Result := True;
    end
    else
      Result := False;
  end
  else if idCorreo > raiz^.correo^.id then
  begin
    if EliminarAVL(raiz^.derecha, idCorreo, alturaCambia) then
    begin
      if alturaCambia then
        raiz := balancearIzquierda(raiz, alturaCambia);
      Result := True;
    end
    else
      Result := False;
  end
  else
  begin
    if (raiz^.izquierda = nil) or (raiz^.derecha = nil) then
    begin
      if raiz^.izquierda <> nil then
        sucesor := raiz^.izquierda
      else
        sucesor := raiz^.derecha;

      Dispose(raiz^.correo);
      Dispose(raiz);
      raiz := sucesor;
      alturaCambia := True;
    end
    else
    begin
      sucesor := raiz^.derecha;
      while sucesor^.izquierda <> nil do
        sucesor := sucesor^.izquierda;

      raiz^.correo := sucesor^.correo;
      if EliminarAVL(raiz^.derecha, sucesor^.correo^.id, alturaCambia) then
        if alturaCambia then
          raiz := balancearIzquierda(raiz, alturaCambia);
    end;
    Result := True;
  end;
end;

procedure PreOrden(raiz: PNodoAVL; lista: TStrings);
begin
  if raiz <> nil then
  begin
    lista.AddObject(IntToStr(raiz^.correo^.id) + ' - ' + raiz^.correo^.asunto, TObject(raiz^.correo));
    PreOrden(raiz^.izquierda, lista);
    PreOrden(raiz^.derecha, lista);
  end;
end;

procedure InOrden(raiz: PNodoAVL; lista: TStrings);
begin
  if raiz <> nil then
  begin
    InOrden(raiz^.izquierda, lista);
    lista.AddObject(IntToStr(raiz^.correo^.id) + ' - ' + raiz^.correo^.asunto, TObject(raiz^.correo));
    InOrden(raiz^.derecha, lista);
  end;
end;

procedure PostOrden(raiz: PNodoAVL; lista: TStrings);
begin
  if raiz <> nil then
  begin
    PostOrden(raiz^.izquierda, lista);
    PostOrden(raiz^.derecha, lista);
    lista.AddObject(IntToStr(raiz^.correo^.id) + ' - ' + raiz^.correo^.asunto, TObject(raiz^.correo));
  end;
end;

end.
