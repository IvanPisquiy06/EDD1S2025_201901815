unit uhashing;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, sha256;

function CalcularSHA256(texto: String): String;

implementation

function CalcularSHA256(texto: String): String;
var
  Hash: TSHA256Digest;
  Context: TSHA256Context;
begin
  SHA256Init(Context);
  SHA256Update(Context, PByte(texto)^, Length(texto));
  SHA256Final(Context, Hash);

  Result := SHA256DigestToHex(Hash);
end;

end.
