program haffman;

{$APPTYPE CONSOLE}

uses
  SysUtils;

const
  maxSizeByte = 255;
  maxBufferSize = 128;
type
  TByteFile = file of Byte;
  PList = ^TList;

  TList = record
    nameByte : Byte;
    numOfElements : Integer;
    next, right, left : PList;
  end;

  TCodeRec = record
    numOfElements : Integer;
    code : string;
  end;

  TCodeArr = array[0..maxSizeByte] of TCodeRec;

var
  i, j, count : byte;
  inputFile, outputFile : TByteFile;
  bufferByte, numOfBytes, tmp: byte;
  //bufferByteArr :
  formatFile : string;
  headSortByteList, endSortByteList, codeTree : PList;
  codeArr : TCodeArr;

function adrRepeatNameByteList (headList : PList; tmpByte : byte) : PList;
begin
  result:= nil;
  while (headList <> nil) do
  begin
    if (headList^.nameByte = tmpByte)
    then
    begin
      result:= headList;
      exit;
    end;
    headList:= headList^.next;
  end;
end;

procedure addEndList (var endList : PList; tmpByte : byte);
var
  tmpAdr : PList;
begin
  New(tmpAdr);

  if (endList = nil)
  then
    endList:= tmpAdr
  else
    endList^.next:= tmpAdr;

  tmpAdr^.nameByte:= tmpByte;
  tmpAdr^.numOfElements:= 1;
  tmpAdr^.right:= nil;
  tmpAdr^.left:= nil;
  tmpAdr^.next:= nil;

  endList:= tmpAdr;
  //test
  Writeln('ADDED!');
end;

procedure freeList(headList : PList);
var
  tmpAdr : PList;
begin
  tmpAdr:= headList;

  writeln;
  repeat
    headList:= tmpAdr;
    tmpAdr:= headList^.next;
    dispose(headList);
    writeln('DELETED!');
  until (tmpAdr = nil);
end;

procedure swapFieldNewList(firAdr, secAdr : PList);
var
  buff : integer;
begin
  //writeln(firAdr^.numOfElements, ' ', secAdr^.numOfElements);
  buff:= secAdr^.numOfElements;
  secAdr^.numOfElements:= firAdr^.numOfElements;
  firAdr^.numOfElements:= buff;
end;

function lengthList(headList : PList) : integer;
var
  len : integer;
begin
  len:= 0;
  while (headList <> nil) do
  begin
    inc(len);
    headList:= headList^.next;
  end;
  result:= len;
end;

function takePredAdrList(headList, lastAdr : PList) : PList;
begin
  result:= nil;
  while (headList^.next <> lastAdr) do
  begin
    headList:= headList^.next;
  end;
  result:= headList;
end;

procedure sortList(var headList, endList : PList);
var
  tmpHeadList, tmpEndList : PList;
  lenList, i : integer;
begin
  lenList:= lengthList(headList);
  tmpEndList:= endList;

  for i:=1 to lenList-1 do
  begin
    tmpHeadList:= headList;
    while (tmpHeadList <> tmpEndList) do
    begin
      //writeln(tmpHeadList^.numOfElements, ' ', tmpHeadList^.next^.numOfElements);
      if (tmpHeadList^.numOfElements > tmpHeadList^.next^.numOfElements)
      then
        swapFieldNewList(tmpHeadList, tmpHeadList^.next);
      //writeln(tmpHeadList^.numOfElements, ' ', tmpHeadList^.next^.numOfElements);
      tmpHeadList:= tmpHeadList^.next;
    end;
    tmpEndList:= takePredAdrList(headList, tmpEndList);
  end;
end;

//procedure makeRoot (headList : PList);
//var
//  tmpAdr, tmpHeadList : PList;
//begin
//  new(tmpAdr);
//  tmpAdr^.left:= headList;
//  tmpAdr^.right:= headList^.next;
//  tmpAdr^.numOfElements:= headList^.numOfElements + headList^.next^.numOfElements;
//
//  if (headList^.next^.next = nil)
//  then
//    headList:= tmpAdr
//  else
//  begin
//    headList:= headList^.next^.next;
//    tmpHeadList:= headList;
//
//    if (tmpAdr^.numOfElements > headList^.numOfElements)
//    then
//    begin
//      tmpAdr^.next:= tmpHeadList;
//      headList:= tmpAdr;
//    end;
//
//    while (tmpAdr^.numOfElements > tmpHeadList^.numOfElements) and (tmpHeadList <> nil) do
//    begin
//      tmpHeadList:= tmpHeadList^.next;
//    end;
//
//    if (tmpHeadList = nil)
//    then
//
//    else
//    begin
//      tmpAdr^.next:= tmpHeadList;
//    end;
//  end;
//end;

procedure addRootTree (var headList, currRoot : PList);
begin
  New(currRoot);
  currRoot^.next:= headList^.next^.next;
  currRoot^.numOfElements:= headList^.numOfElements + headList^.next^.numOfElements;
  currRoot^.left:= headList;
  currRoot^.right:= headList^.next;
  headList:= currRoot;
  //Write(currRoot^.numOfElements, '  ');
end;

procedure buildTree(var headList, endList : PList);
var
  currRoot : PList;
begin
  while (headList^.next <> nil) do
  begin
    addRootTree(headList, currRoot);
    sortList(headList, endList);
  end;
end;

procedure makeCodeArr(headList : PList; code : string);
begin
  if (headList^.left = nil) and (headList^.right = nil)
  then
  begin
    codeArr[headList^.nameByte].code:= code;
    inc(numOfBytes);
  end
  else
  begin
    makeCodeArr(headList^.left, code+'1');
    makeCodeArr(headList^.right, code+'0');
  end;
end;

function rol(num : Integer; count : byte) : Byte;
asm
  mov eax, num
  mov cl, count
  rol eax, cl
  mov result, al
end;

procedure inputIntNumInByteFile (var workFile : TByteFile; num : integer);
var
  buffer, count, i : Byte;
begin
  count:= 0;
  for i:=1 to 4 do
  begin
    Inc(count, 8);
    buffer:= rol(num, count);
    write(workFile, buffer);
  end;
end;

function charToByte (ch : char) : Byte;
begin
  case ch of
    '1' : result:= 1;
    '0' : Result:= 0;
  end;
end;

procedure CODDER (var workFile, resFile: TByteFile);
type
  TBuffArr = array[1..256] of byte;
var
  buffArr : TBuffArr;
  code : string;
  tmpByte, bufferByte, numItems : byte;
  codeIndex : integer;
begin
  numItems:= 0;
  bufferByte:= 0;

  while not eof(workFile) do
  begin
    read(workFile, tmpByte);

    //write('!',length(codeArr[tmpByte].code),'! ');

    codeIndex:= 0;
    while (codeIndex < length(codeArr[tmpByte].code)) do
    begin
      Inc(numItems);
      Inc(codeIndex);
      bufferByte:= (bufferByte shl 1) or charToByte(codeArr[tmpByte].code[codeIndex]);
      write(codeArr[tmpByte].code[codeIndex]);
      if (numItems = 8)
      then
      begin
        write(resFile, bufferByte);
        writeln('  ', bufferByte);
        numItems:= 0;
        bufferByte:= 0;
      end;
    end;
  end;

  write(resFile, bufferByte);//nado eshe poslat bufferbyte - vse chtp v nem ostalo
end;

procedure testOutputList(headList : PList);
begin
  while (headList <> nil) do
  begin
    //write(headList^.key, '  ');
    headList:= headList^.next;
  end;
end;

begin

  for i:=0 to maxSizeByte do
  begin
    codeArr[i].code:='';
    codeArr[i].numOfElements:=0;
  end;

  AssignFile(inputFile, 'inputFile.txt');
  Reset(inputFile);

  endSortByteList:= nil;

  while not eof(inputFile) do
  begin
    read(inputFile, bufferByte);

    if (endSortByteList = nil)
    then
    begin
      addEndList(headSortByteList, bufferByte);
      endSortByteList:= headSortByteList;
      Inc(codeArr[bufferByte].numOfElements);
      continue;
    end;

    if (adrRepeatNameByteList(headSortByteList, bufferByte) = nil)
    then
    begin
      addEndList(endSortByteList, bufferByte);
      Inc(codeArr[bufferByte].numOfElements);
    end
    else
    begin
      inc(adrRepeatNameByteList(headSortByteList, bufferByte)^.numOfElements);
      Inc(codeArr[bufferByte].numOfElements);
    end;
  end;
  CloseFile(inputFile);

  //testOutputList(headSortByteList);
  //Writeln;
  sortList(headSortByteList, endSortByteList);
  //testOutputList(headSortByteList);

  buildTree(headSortByteList, endSortByteList);

  numOfBytes:= 0;

  makeCodeArr(headSortByteList, '');

  for i:=0 to maxSizeByte do
  begin
    if (codeArr[i].numOfElements <> 0)
    then
    begin
      writeln(codearr[i].code, ' ', i);
    end;
  end;

  AssignFile(outputFile, 'smallFile.txt');// поставть тоже имя что и у начально только расширешие .bin
  Rewrite(outputFile); //первый байт оставить как шифр?

  formatFile:= 'txt';
  tmp:= Length(formatFile);
  write(outputFile, tmp);
  for i:=1 to Length(formatFile) do
  begin
    tmp:= Byte(ord(formatFile[i]));
    write(outputFile, tmp);
  end;

  inputIntNumInByteFile(outputFile, numOfBytes*5);  //numOfBytes*5 + 1?

  for i:=0 to maxSizeByte do    //pаписываю таблицу в файл
  begin
    if (codeArr[i].numOfElements > 0)
    then
    begin
      write(outputFile, i);

      inputIntNumInByteFile(outputFile, codeArr[i].numOfElements);
    end;
  end;

//codder
  AssignFile(inputFile, 'inputFile.txt');
  Reset(inputFile);

  CODDER(inputFile, outputFile);

  CloseFile(inputFile);
//end codder

  CloseFile(outputFile);

  freeList(headSortByteList);

  Readln;
end.
