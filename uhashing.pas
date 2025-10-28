unit uhashing;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

function CalcularSHA256(texto: String): String;

implementation

function HashSDBM(const s: AnsiString): Cardinal;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(s) do
    Result := Cardinal(s[i]) + (Result shl 6) + (Result shl 16) - Result;
end;

function CalcularSHA256(texto: String): String;
var
  hashValue: Cardinal;
begin
  hashValue := HashSDBM(AnsiString(texto));

  Result := IntToHex(hashValue, 8) + IntToHex(hashValue xor $F0F0F0F0, 8);
end;

end.
