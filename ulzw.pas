unit uLZW;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Generics.Collections;

function ComprimirLZW(texto: String): String;

implementation

function ComprimirLZW(texto: String): String;
var
  tabla: TDictionary<String, Integer>;
  p, c: String;
  pc: String;
  codigoActual: Integer;
  i: Integer;
  listaCodigos: TList<Integer>;
  resultado: TStringBuilder;
begin
  tabla := TDictionary<String, Integer>.Create;
  for i := 0 to 255 do
    tabla.Add(String(Char(i)), i);

  codigoActual := 256;
  p := '';
  listaCodigos := TList<Integer>.Create;

  for i := 1 to Length(texto) do
  begin
    c := texto[i];
    pc := p + c;

    if tabla.ContainsKey(pc) then
    begin
      p := pc;
    end
    else
    begin
      listaCodigos.Add(tabla[p]);

      if codigoActual < 4096 then
      begin
        tabla.Add(pc, codigoActual);
        Inc(codigoActual);
      end;

      p := c;
    end;
  end;

  if p <> '' then
    listaCodigos.Add(tabla[p]);

  resultado := TStringBuilder.Create;
  for i := 0 to listaCodigos.Count - 1 do
  begin
    resultado.Append(IntToStr(listaCodigos[i]));
    if i < listaCodigos.Count - 1 then
      resultado.Append(',');
  end;

  Result := resultado.ToString;

  tabla.Free;
  listaCodigos.Free;
  resultado.Free;
end;

end.
