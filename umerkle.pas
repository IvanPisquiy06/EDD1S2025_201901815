unit umerkle;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, uListaDoble, uHashing,
  Generics.Collections, Generics.Defaults;

type
  PMerkleNode = ^TMerkleNode;
  TMerkleNode = record
    hash: String;
    izquierda: PMerkleNode;
    derecha: PMerkleNode;
  end;

function CrearMerkleTree(listaCorreos: PCorreo): PMerkleNode;
procedure LiberarMerkleTree(var raiz: PMerkleNode);
procedure GenerarReporteMerkleDOT(outputFile: String; usuarioEmail: String; listaCorreos: PCorreo; merkleRootNode: PMerkleNode);

implementation
uses uhuffman;

procedure EscribirNodoMerkleDOT(var F: TextFile; nodo: PMerkleNode; var nodeCounter: Integer);
var
  currentNodeId: String;
  leftNodeId: String;
  rightNodeId: String;
begin
  if nodo = nil then Exit;

  Inc(nodeCounter);
  currentNodeId := 'm' + IntToStr(nodeCounter);

  WriteLn(F, '  ', currentNodeId, ' [shape=box, label="Hash: ', Copy(nodo^.hash, 1, 8), '..."];');

  if nodo^.izquierda <> nil then
  begin
    Inc(nodeCounter);
    leftNodeId := 'm' + IntToStr(nodeCounter);
    WriteLn(F, '  ', currentNodeId, ' -> ', leftNodeId, ';');
    EscribirNodoMerkleDOT(F, nodo^.izquierda, nodeCounter);
  end;

  if nodo^.derecha <> nil then
  begin
    Inc(nodeCounter);
    rightNodeId := 'm' + IntToStr(nodeCounter);
    WriteLn(F, '  ', currentNodeId, ' -> ', rightNodeId, ';');
    EscribirNodoMerkleDOT(F, nodo^.derecha, nodeCounter);
  end;
end;

procedure GenerarReporteMerkleDOT(outputFile: String; usuarioEmail: String; listaCorreos: PCorreo; merkleRootNode: PMerkleNode);
var
  F: TextFile;
  auxCorreo: PCorreo;
  nodeCounter: Integer;
  correoNodeId: String;
  merkleRootId: String;

  merkleNodesQueue: TQueue<PMerkleNode>;
  currentCorreo: PCorreo;
  currentMerkleNode: PMerkleNode;
  merkleNodeIds: TDictionary<PMerkleNode, String>;
  correoNodeIds: TDictionary<PCorreo, String>;
  merkleQueueForLeaves: TQueue<PMerkleNode>;
  leafMerkleNodes: TList<PMerkleNode>;
  traversalQueue: TQueue<PMerkleNode>;
  i: Integer;
  leftNodeId: String;
  rightNodeId: String;
  currentNodeId: String;
  leafNodeId: String;
  detailCorreoId: String;
  merkleLeafId: String;
  hashCorreo: String;
begin
  AssignFile(F, outputFile);
  Rewrite(F);

  WriteLn(F, 'digraph MerkleTree {');
  WriteLn(F, '  rankdir=TB;');
  WriteLn(F, '  node [shape=box, style=filled, fillcolor="#f0f0f0"];');
  WriteLn(F, '  edge [dir=forward];');
  WriteLn(F, '');
  WriteLn(F, '  subgraph cluster_0 {');
  WriteLn(F, '    label="Correos Privados de ', usuarioEmail, '";');
  WriteLn(F, '    style=filled;');
  WriteLn(F, '    color=lightgrey;');

  merkleNodeIds := TDictionary<PMerkleNode, String>.Create;
  correoNodeIds := TDictionary<PCorreo, String>.Create;
  merkleNodesQueue := TQueue<PMerkleNode>.Create;

  nodeCounter := 0;

  currentCorreo := listaCorreos;
  while currentCorreo <> nil do
  begin
    Inc(nodeCounter);
    correoNodeId := 'c' + IntToStr(nodeCounter);
    correoNodeIds.Add(currentCorreo, correoNodeId);

    hashCorreo := CalcularSHA256(IntToStr(currentCorreo^.id) + currentCorreo^.remitente + currentCorreo^.destinatario + currentCorreo^.asunto + currentCorreo^.mensaje);

    WriteLn(F, '  ', correoNodeId, ' [shape=box, style=filled, fillcolor="#CCEEFF", label="De: ', currentCorreo^.remitente, '\nAsunto: ', currentCorreo^.asunto, '\nHash: ', Copy(hashCorreo, 1, 8), '..."];');
    currentCorreo := currentCorreo^.siguiente;
  end;

  if merkleRootNode <> nil then
  begin
    Inc(nodeCounter);
    merkleRootId := 'm' + IntToStr(nodeCounter);
    merkleNodeIds.Add(merkleRootNode, merkleRootId);
    WriteLn(F, '  ', merkleRootId, ' [shape=box, label="MERKLE ROOT\nHash: ', Copy(merkleRootNode^.hash, 1, 8), '..."];');
    merkleNodesQueue.Enqueue(merkleRootNode);

    while merkleNodesQueue.Count > 0 do
    begin
      currentMerkleNode := merkleNodesQueue.Dequeue;
      currentNodeId := merkleNodeIds.Items[currentMerkleNode];

      if currentMerkleNode^.izquierda <> nil then
      begin
        Inc(nodeCounter);
        leftNodeId := 'm' + IntToStr(nodeCounter);
        merkleNodeIds.Add(currentMerkleNode^.izquierda, leftNodeId);
        WriteLn(F, '  ', leftNodeId, ' [shape=box, label="Hash: ', Copy(currentMerkleNode^.izquierda^.hash, 1, 8), '..."];');
        WriteLn(F, '  ', currentNodeId, ' -> ', leftNodeId, ';');
        merkleNodesQueue.Enqueue(currentMerkleNode^.izquierda);
      end;

      if currentMerkleNode^.derecha <> nil then
      begin
        Inc(nodeCounter);
        rightNodeId := 'm' + IntToStr(nodeCounter);
        merkleNodeIds.Add(currentMerkleNode^.derecha, rightNodeId);
        WriteLn(F, '  ', rightNodeId, ' [shape=box, label="Hash: ', Copy(currentMerkleNode^.derecha^.hash, 1, 8), '..."];');
        WriteLn(F, '  ', currentNodeId, ' -> ', rightNodeId, ';');
        merkleNodesQueue.Enqueue(currentMerkleNode^.derecha);
      end;
    end;
  end;
  currentCorreo := listaCorreos;
  leafMerkleNodes := TList<PMerkleNode>.Create;
  traversalQueue := TQueue<PMerkleNode>.Create;

  if merkleRootNode <> nil then
    traversalQueue.Enqueue(merkleRootNode);

  while traversalQueue.Count > 0 do
  begin
    currentMerkleNode := traversalQueue.Dequeue;
    if (currentMerkleNode^.izquierda = nil) and (currentMerkleNode^.derecha = nil) then
    begin
      leafMerkleNodes.Add(currentMerkleNode);
    end else
    begin
      if currentMerkleNode^.izquierda <> nil then
        traversalQueue.Enqueue(currentMerkleNode^.izquierda);
      if currentMerkleNode^.derecha <> nil then
        traversalQueue.Enqueue(currentMerkleNode^.derecha);
    end;
  end;

  // Conectar nodos hoja Merkle a nodos correo
  currentCorreo := listaCorreos;
  for i := 0 to leafMerkleNodes.Count - 1 do
  begin
    if currentCorreo = nil then break;

    // Solo conectamos si los diccionarios contienen las llaves
    if merkleNodeIds.ContainsKey(leafMerkleNodes.Items[i]) and correoNodeIds.ContainsKey(currentCorreo) then
    begin
      leafNodeId := merkleNodeIds.Items[leafMerkleNodes.Items[i]];
      detailCorreoId := correoNodeIds.Items[currentCorreo];
      WriteLn(F, '  ', leafNodeId, ' -> ', detailCorreoId, ';');
    end;

    currentCorreo := currentCorreo^.siguiente;
  end;

  leafMerkleNodes.Free;
  traversalQueue.Free;

  WriteLn(F, '  }');
  WriteLn(F, '}');
  CloseFile(F);

  merkleNodesQueue.Free;
  merkleNodeIds.Free;
  correoNodeIds.Free;
end;


function CrearMerkleTree(listaCorreos: PCorreo): PMerkleNode;
var
  hashes: TList<String>;
  currentCorreo: PCorreo;
  nodes: TList<PMerkleNode>;
  i: Integer;
  leftNode, rightNode, newNode: PMerkleNode;
  newHash: String;
  newLevelNodes: TList<PMerkleNode>;
  datosCorreo: String;
begin
  hashes := TList<String>.Create;
  currentCorreo := listaCorreos;

  while currentCorreo <> nil do
  begin
    datosCorreo := IntToStr(currentCorreo^.id) +
                   currentCorreo^.remitente +
                   currentCorreo^.destinatario +
                   currentCorreo^.asunto +
                   currentCorreo^.mensaje;
    hashes.Add(CalcularSHA256(datosCorreo));
    currentCorreo := currentCorreo^.siguiente;
  end;

  if hashes.Count = 0 then
  begin
    hashes.Free;
    Result := nil;
    Exit;
  end;

  nodes := TList<PMerkleNode>.Create;
  for i := 0 to hashes.Count - 1 do
  begin
    New(newNode);
    newNode^.hash := hashes.Items[i];
    newNode^.izquierda := nil;
    newNode^.derecha := nil;
    nodes.Add(newNode);
  end;

  while nodes.Count > 1 do
  begin
    if Odd(nodes.Count) then
      nodes.Add(nodes.Items[nodes.Count - 1]);

    newLevelNodes := TList<PMerkleNode>.Create;

    i := 0;
    while i < nodes.Count do
    begin
      leftNode := nodes.Items[i];
      rightNode := nodes.Items[i + 1];

      newHash := CalcularSHA256(leftNode^.hash + rightNode^.hash);

      New(newNode);
      newNode^.hash := newHash;
      newNode^.izquierda := leftNode;
      newNode^.derecha := rightNode;
      newLevelNodes.Add(newNode);

      Inc(i, 2);
    end;
    nodes.Free;
    nodes := newLevelNodes;
  end;

  if nodes.Count > 0 then
    Result := nodes.Items[0]
  else
    Result := nil;

  nodes.Free;
  hashes.Free;
end;

procedure LiberarMerkleTree(var raiz: PMerkleNode);
begin
  if raiz <> nil then
  begin
    LiberarMerkleTree(raiz^.izquierda);
    LiberarMerkleTree(raiz^.derecha);
    Dispose(raiz);
    raiz := nil;
  end;
end;

end.
