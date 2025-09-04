unit ureportes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ulistasimple, ulistadoble, upila, ucola, Process;

procedure ReporteUsuarios(lista: PUsuario; ruta: String);
procedure ReporteCorreos(usuario: PUsuario; ruta: String);
procedure ReportePapelera(usuario: PUsuario; ruta: String);
procedure ReporteProgramados(usuario: PUsuario; ruta: String);
procedure ReporteContactos(usuario: PUsuario; ruta: String);

implementation

procedure EjecutarDot(dotFile, outFile: String);
var
AProcess: TProcess;
begin
  AProcess := TProcess.Create(nil);
  try
    AProcess.Executable := 'dot';
    AProcess.Parameters.Add('-Tpng');
    AProcess.Parameters.Add(dotFile);
    AProcess.Parameters.Add('-o');
    AProcess.Parameters.Add(outFile);
    AProcess.Options := [poWaitOnExit, poUsePipes];
    AProcess.Execute;
  finally
    AProcess.Free;
  end;
end;

procedure ReporteUsuarios(lista: PUsuario; ruta: String);
var
   archivo: TextFile;
   aux: PUsuario;
   dotFile, outFile: String;
begin
   if not DirectoryExists(ruta) then
      CreateDir(ruta);

   dotFile := ruta + '/usuarios.dot';
   outFile := ruta + '/usuarios.png';

   AssignFile(archivo, dotFile);
   Rewrite(archivo);

   WriteLn(archivo, 'digraph G {');
   WriteLn(archivo, 'rankdir=LR; node [shape=record, style=filled, fillcolor=lightblue];');

   aux := lista;
   while aux <> nil do
   begin
     WriteLn(archivo, 'u', aux^.id, ' [label="{', IntToStr(aux^.id), '|', aux^.nombre, '|', aux^.usuario, '}"];');
     if aux^.siguiente <> nil then
        WriteLn(archivo, 'u', aux^.id, ' -> u', aux^.siguiente^.id, ';');
     aux := aux^.siguiente;
   end;

   WriteLn(archivo, '}');
   CloseFile(archivo);

   EjecutarDot(dotFile, outFile);
end;

procedure ReporteCorreos(usuario: PUsuario; ruta: String);
var
   archivo: TextFile;
   aux: PCorreo;
   dotFile, outFile: String;
begin
  if not DirectoryExists(ruta) then
     CreateDir(ruta);

   dotFile := ruta + '/correos.dot';
   outFile := ruta + '/correos.png';

   AssignFile(archivo, dotFile);
   Rewrite(archivo);

   WriteLn(archivo, 'digraph G {');
   WriteLn(archivo, 'rankdir=LR; node [shape=record, style=filled, fillcolor=lightyellow];');

   aux := usuario^.bandejaEntrada;
   while aux <> nil do
   begin
     WriteLn(archivo, 'c', aux^.id, ' [label="{ID: ', IntToStr(aux^.id),
            '|Estado: ', aux^.estado,
            '|Asunto: ', aux^.asunto,
            '|De: ', aux^.remitente, '}"];');

     if aux^.siguiente <> nil then
        WriteLn(archivo, 'c', aux^.id, ' -> c', aux^.siguiente^.id, ';');
     if aux^.anterior <> nil then
      WriteLn(archivo, 'c', aux^.id, ' -> c', aux^.anterior^.id, ' [color=gray, constraint=false];');
     aux := aux^.siguiente;
   end;

   WriteLn(archivo, '}');
   CloseFile(archivo);

   EjecutarDot(dotFile, outFile);
end;

procedure ReportePapelera(usuario: PUsuario; ruta: String);
begin
end;

procedure ReporteProgramados(usuario: PUsuario; ruta: String);
begin
end;

procedure ReporteContactos(usuario: PUsuario; ruta: String);
begin
end;

end.

