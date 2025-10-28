unit ureportes;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, ulistasimple, ulistadoble, upila, ucola, uarbolavl, uarbolb, ucomunidades,
  Process, ugrafos, ublockchain, Generics.Collections, FileUtil;

procedure ReporteUsuarios(lista: PUsuario; ruta: String);
procedure ReporteCorreos(usuario: PUsuario; ruta: String);
procedure ReportePapelera(usuario: PUsuario; ruta: String);
procedure ReporteProgramados(usuario: PUsuario; ruta: String);
procedure GenerarReporteBlockchain(ruta: String);

procedure ReporteContactos(usuario: PUsuario; ruta: String);
procedure ReporteBorradores(usuario: PUsuario; ruta: String);
procedure ReporteFavoritos(usuario: PUsuario; ruta: String);
procedure ReporteComunidades(ruta: String);
procedure EjecutarDot(dotFile, outFile: String);
procedure ReporteGrafoUsuarios(ruta: String);

implementation
uses uhuffman, Dialogs;

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

procedure GenerarReporteBlockchain(ruta: String);
var
  F: TextFile;
  bloqueActual: PBloque;
  blockName: String;
  dataString: String;
  dotFileName: String;
  pngFileName: String;
  genesisLabel: String;
begin
  bloqueActual := GetBlockchainHead;

  if bloqueActual = nil then
  begin
    ShowMessage('El Blockchain está vacío, no se puede generar el reporte.');
    Exit;
  end;

  pngFileName := IncludeTrailingPathDelimiter(ruta) + 'blockchain_report.png';
  dotFileName := ChangeFileExt(pngFileName, '.dot');

  AssignFile(F, dotFileName);
  Rewrite(F);

  WriteLn(F, 'digraph Blockchain {');
  WriteLn(F, '  rankdir=TB;');
  WriteLn(F, '  node [shape=record, style=filled, fillcolor="#f0f0f0", fontname="Arial"];');
  WriteLn(F, '  edge [dir=forward, arrowhead=vee];');
  WriteLn(F, '');

  while bloqueActual <> nil do
  begin
    blockName := 'block' + IntToStr(bloqueActual^.index);

    if bloqueActual^.index = 0 then
    begin
      dataString := 'Data: Genesis Block';
      genesisLabel := ' (Genesis)';
    end
    else
      dataString := Format('Data: ID: %d, Remitente: %s, Asunto: %s, Mensaje: %s',
                           [bloqueActual^.datos.ID,
                            StringReplace(bloqueActual^.datos.Remitente, '"', '\"', [rfReplaceAll]),
                            StringReplace(bloqueActual^.datos.Asunto, '"', '\"', [rfReplaceAll]),
                            StringReplace(Copy(bloqueActual^.datos.Mensaje, 1, 30) + '...', '"', '\"', [rfReplaceAll]) // Acortar mensaje
                           ]);
    genesisLabel := '';

    WriteLn(F, '  ', blockName, ' [label="');
    WriteLn(F, '    {<h>Block ', IntToStr(bloqueActual^.index), genesisLabel, '|');
    WriteLn(F, '    Index: ', IntToStr(bloqueActual^.index), '|');
    WriteLn(F, '    Timestamp: ', FormatDateTime('yyyy-mm-dd hh:nn:ss', bloqueActual^.timestamp), '|');
    WriteLn(F, '    ', dataString, '|');
    WriteLn(F, '    Nonce: ', IntToStr(bloqueActual^.nonce), '|');
    WriteLn(F, '    Prev Hash: ', Copy(bloqueActual^.hashAnterior, 1, 8), '...|');
    WriteLn(F, '    Hash: ', Copy(bloqueActual^.hash, 1, 8), '...');
    WriteLn(F, '    }"];');

    if bloqueActual^.index > 0 then
    begin
      WriteLn(F, '  block', IntToStr(bloqueActual^.index - 1), ' -> ', blockName, ';');
    end;

    bloqueActual := bloqueActual^.siguiente;
  end;

  WriteLn(F, '}');
  CloseFile(F);

  try
    EjecutarDot(dotFileName, pngFileName);
    ShowMessage('Reporte de Blockchain generado en: ' + pngFileName);
  except
    on E: Exception do
      ShowMessage('Error al generar el reporte de Blockchain: ' + E.Message);
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
var
  archivo: TextFile;
  aux: PElementoPila;
  dotFile, outFile: String;
  i: Integer;
begin
  if not DirectoryExists(ruta) then
    CreateDir(ruta);

  dotFile := ruta + '/papelera.dot';
  outFile := ruta + '/papelera.png';

  AssignFile(archivo, dotFile);
  Rewrite(archivo);

  WriteLn(archivo, 'digraph G {');
  WriteLn(archivo, 'rankdir=TB; node [shape=note, style=filled, fillcolor=lightgrey];');

  aux := usuario^.pilaPapelera;
  i := 0;
  while aux <> nil do
  begin
    WriteLn(archivo, 'p', aux^.correo^.id, ' [label="', aux^.correo^.asunto, '"];');

    if aux^.siguiente <> nil then
      WriteLn(archivo, 'p', aux^.correo^.id, ' -> p', aux^.siguiente^.correo^.id, ';');

    aux := aux^.siguiente;
    Inc(i);
  end;

  WriteLn(archivo, '}');
  CloseFile(archivo);
  EjecutarDot(dotFile, outFile);
end;


procedure ReporteProgramados(usuario: PUsuario; ruta: String);
var
  archivo: TextFile;
  aux: PElementoCola;
  dotFile, outFile: String;
begin
  if not DirectoryExists(ruta) then
    CreateDir(ruta);

  dotFile := ruta + '/programados.dot';
  outFile := ruta + '/programados.png';

  AssignFile(archivo, dotFile);
  Rewrite(archivo);

  WriteLn(archivo, 'digraph G {');
  WriteLn(archivo, 'rankdir=LR;');

  WriteLn(archivo, 'node [shape=record, style=filled, fillcolor=lightblue];');

  aux := usuario^.colaProgramadosFrente;
  while aux <> nil do
  begin
    WriteLn(archivo, 'q', aux^.correo^.id, ' [label="{ID: ', aux^.correo^.id,
            '|Asunto: ', aux^.correo^.asunto, '}"];');

    if aux^.siguiente <> nil then
      WriteLn(archivo, 'q', aux^.correo^.id, ' -> q', aux^.siguiente^.correo^.id, ';');

    aux := aux^.siguiente;
  end;

  if usuario^.colaProgramadosFrente <> nil then
  begin
    WriteLn(archivo, 'subgraph cluster_pointers {');
    WriteLn(archivo, '  label="Punteros de la Cola";');
    WriteLn(archivo, '  node [shape=box, style=filled, fillcolor=seagreen];');
    WriteLn(archivo, '  Frente -> q', usuario^.colaProgramadosFrente^.correo^.id, ';');
    WriteLn(archivo, '  Fin -> q', usuario^.colaProgramadosFin^.correo^.id, ';');
    WriteLn(archivo, '}');
  end;

  WriteLn(archivo, '}');
  CloseFile(archivo);

  EjecutarDot(dotFile, outFile);
end;

procedure GenerarNodosBST(raiz: PNodoBST; var archivo: TextFile);
begin
  if raiz <> nil then
  begin
    WriteLn(archivo, 'ct', raiz^.contacto^.id, ' [label="{',
            raiz^.contacto^.nombre, '|', raiz^.contacto^.email, '}"];');
    GenerarNodosBST(raiz^.izquierda, archivo);
    GenerarNodosBST(raiz^.derecha, archivo);
  end;
end;

procedure GenerarEnlacesBST(raiz: PNodoBST; var archivo: TextFile);
begin
  if raiz <> nil then
  begin
    if raiz^.izquierda <> nil then
      WriteLn(archivo, 'ct', raiz^.contacto^.id, ' -> ct', raiz^.izquierda^.contacto^.id, ';');
    if raiz^.derecha <> nil then
      WriteLn(archivo, 'ct', raiz^.contacto^.id, ' -> ct', raiz^.derecha^.contacto^.id, ';');
    GenerarEnlacesBST(raiz^.izquierda, archivo);
    GenerarEnlacesBST(raiz^.derecha, archivo);
  end;
end;

procedure ReporteContactos(usuario: PUsuario; ruta: String);
var
  archivo: TextFile;
  dotFile, outFile: String;
begin
  if not DirectoryExists(ruta) then CreateDir(ruta);
  dotFile := ruta + '/contactos.dot';
  outFile := ruta + '/contactos.png';
  AssignFile(archivo, dotFile);
  Rewrite(archivo);
  WriteLn(archivo, 'digraph G {');
  WriteLn(archivo, 'node [shape=record, style=filled, fillcolor=palegreen];');
  if (usuario <> nil) and (usuario^.contactosBST <> nil) then
  begin
    GenerarNodosBST(usuario^.contactosBST, archivo);
    GenerarEnlacesBST(usuario^.contactosBST, archivo);
  end;
  WriteLn(archivo, '}');
  CloseFile(archivo);
  EjecutarDot(dotFile, outFile);
end;

procedure GenerarNodosAVL(raiz: PNodoAVL; var archivo: TextFile);
begin
  if raiz <> nil then
  begin
    WriteLn(archivo, 'avl', raiz^.correo^.id, ' [label="{<izq>|<data> ID: ', raiz^.correo^.id, ' - FE: ', raiz^.factorEquilibrio,'|<der>}"];');
    GenerarNodosAVL(raiz^.izquierda, archivo);
    GenerarNodosAVL(raiz^.derecha, archivo);
  end;
end;

procedure GenerarEnlacesAVL(raiz: PNodoAVL; var archivo: TextFile);
begin
  if raiz <> nil then
  begin
    if raiz^.izquierda <> nil then
      WriteLn(archivo, '"avl', raiz^.correo^.id, '":izq -> "avl', raiz^.izquierda^.correo^.id, '":data;');
    if raiz^.derecha <> nil then
      WriteLn(archivo, '"avl', raiz^.correo^.id, '":der -> "avl', raiz^.derecha^.correo^.id, '":data;');
    GenerarEnlacesAVL(raiz^.izquierda, archivo);
    GenerarEnlacesAVL(raiz^.derecha, archivo);
  end;
end;

procedure ReporteBorradores(usuario: PUsuario; ruta: String);
var
  archivo: TextFile;
  dotFile, outFile: String;
begin
  if not DirectoryExists(ruta) then CreateDir(ruta);
  dotFile := ruta + '/borradores.dot';
  outFile := ruta + '/borradores.png';
  AssignFile(archivo, dotFile);
  Rewrite(archivo);
  WriteLn(archivo, 'digraph G {');
  WriteLn(archivo, 'node [shape=record, style=filled, fillcolor=khaki];');
  if (usuario <> nil) and (usuario^.borradores <> nil) then
  begin
    GenerarNodosAVL(usuario^.borradores, archivo);
    GenerarEnlacesAVL(usuario^.borradores, archivo);
  end;
  WriteLn(archivo, '}');
  CloseFile(archivo);
  EjecutarDot(dotFile, outFile);
end;

procedure GenerarNodosB(raiz: PPaginaB; var archivo: TextFile);
var
  i: Integer;
  etiqueta: String;
begin
  if raiz <> nil then
  begin
    etiqueta := '';
    for i := 1 to raiz^.contador do
    begin
      etiqueta := etiqueta + '<f' + IntToStr(i-1) + '>|<d' + IntToStr(i) + '> ID: ' + IntToStr(raiz^.claves[i]^.id);
    end;
    etiqueta := etiqueta + '|<f' + IntToStr(raiz^.contador) + '>';
    WriteLn(archivo, '"page', PtrUInt(raiz), '" [label="', etiqueta, '"];');

    for i := 1 to raiz^.contador + 1 do
      GenerarNodosB(raiz^.ramas[i], archivo);
  end;
end;

procedure GenerarEnlacesB(raiz: PPaginaB; var archivo: TextFile);
var
  i: Integer;
begin
  if raiz <> nil then
  begin
    for i := 1 to raiz^.contador + 1 do
    begin
      if raiz^.ramas[i] <> nil then
        WriteLn(archivo, '"page', PtrUInt(raiz), '":f', IntToStr(i-1), ' -> "page', PtrUInt(raiz^.ramas[i]), '";');
      GenerarEnlacesB(raiz^.ramas[i], archivo);
    end;
  end;
end;

procedure ReporteFavoritos(usuario: PUsuario; ruta: String);
var
  archivo: TextFile;
  dotFile, outFile: String;
begin
  if not DirectoryExists(ruta) then CreateDir(ruta);
  dotFile := ruta + '/favoritos.dot';
  outFile := ruta + '/favoritos.png';
  AssignFile(archivo, dotFile);
  Rewrite(archivo);
  WriteLn(archivo, 'digraph G {');
  WriteLn(archivo, 'node [shape=record, style=filled, fillcolor=coral];');
  if (usuario <> nil) and (usuario^.favoritos <> nil) then
  begin
    GenerarNodosB(usuario^.favoritos, archivo);
    GenerarEnlacesB(usuario^.favoritos, archivo);
  end;
  WriteLn(archivo, '}');
  CloseFile(archivo);
  EjecutarDot(dotFile, outFile);
end;

procedure GenerarNodosComunidades(raiz: PComunidad; var archivo: TextFile);
begin
  if raiz <> nil then
  begin
    WriteLn(archivo, '"com', raiz^.nombre, '" [label="', raiz^.nombre, '\n', raiz^.fechaCreacion, '"];');
    GenerarNodosComunidades(raiz^.izquierda, archivo);
    GenerarNodosComunidades(raiz^.derecha, archivo);
  end;
end;

procedure GenerarEnlacesComunidades(raiz: PComunidad; var archivo: TextFile);
begin
  if raiz <> nil then
  begin
    if raiz^.izquierda <> nil then
      WriteLn(archivo, '"com', raiz^.nombre, '" -> "', 'com', raiz^.izquierda^.nombre, '";');
    if raiz^.derecha <> nil then
      WriteLn(archivo, '"com', raiz^.nombre, '" -> "', 'com', raiz^.derecha^.nombre, '";');
    GenerarEnlacesComunidades(raiz^.izquierda, archivo);
    GenerarEnlacesComunidades(raiz^.derecha, archivo);
  end;
end;

procedure ReporteComunidades(ruta: String);
var
  archivo: TextFile;
  dotFile, outFile: String;
begin
  if not DirectoryExists(ruta) then CreateDir(ruta);
  dotFile := ruta + '/comunidades.dot';
  outFile := ruta + '/comunidades.png';
  AssignFile(archivo, dotFile);
  Rewrite(archivo);
  WriteLn(archivo, 'digraph G {');
  WriteLn(archivo, 'node [shape=box, style=filled, fillcolor=skyblue];');
  if arbolComunidades <> nil then
  begin
    GenerarNodosComunidades(arbolComunidades, archivo);
    GenerarEnlacesComunidades(arbolComunidades, archivo);
  end;
  WriteLn(archivo, '}');
  CloseFile(archivo);
  EjecutarDot(dotFile, outFile);
end;

procedure ReporteGrafoUsuarios(ruta: String);
var
  archivo: TextFile;
  dotFile, outFile: String;
  verticeAux: PVertice;
  aristaAux: PAdyacente;
begin
  ConstruirGrafoGlobal(listaUsuarios);

  if not DirectoryExists(ruta) then CreateDir(ruta);
  dotFile := ruta + '/grafo_usuarios.dot';
  outFile := ruta + '/grafo_usuarios.png';

  AssignFile(archivo, dotFile);
  Rewrite(archivo);

  WriteLn(archivo, 'digraph G {');
  WriteLn(archivo, 'label="Grafo de Relaciones de Usuarios";');
  WriteLn(archivo, 'node [shape=box, style=filled, fillcolor=lightblue];');

  verticeAux := grafoUsuarios;
  while verticeAux <> nil do
  begin
    WriteLn(archivo, 'u', verticeAux^.usuario^.id, ' [label="', verticeAux^.usuario^.usuario,'\n', verticeAux^.usuario^.email, '"];');

    aristaAux := verticeAux^.adyacentes;
    while aristaAux <> nil do
    begin
      WriteLn(archivo, 'u', verticeAux^.usuario^.id, ' -> u', aristaAux^.destino^.id, ';');
      aristaAux := aristaAux^.siguiente;
    end;

    verticeAux := verticeAux^.siguiente;
  end;

  WriteLn(archivo, '}');
  CloseFile(archivo);

  EjecutarDot(dotFile, outFile);
end;

end.

