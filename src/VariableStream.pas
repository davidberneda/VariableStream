// @davidberneda
// 2017
unit VariableStream;

interface

{
  TVariableStream class, to store data items of different lengths (sizes).

  For example:

    "Strings" (each string needs a different number of bytes)

  It also works with any other variable type, like "arrays of..." any type.

}

uses
  Classes, SysUtils;

type
  TIndex=Integer;
  TSize=Integer;
  TOneOrMore=1..High(TIndex);

  TIndexRec=packed record
  public
    Position : TIndex;
    Size : TSize;
  end;

  TStreamClass=class of TStream;

  TVariableStream=class
  private
    FCount,
    FLast : TIndex;

    FData,
    FIndex : TStream;

    function BytesAt(const Index: TIndex):TBytes;
    procedure CheckIndex(const Index: TIndex);
    function IndexAt(const Index: TIndex):TIndexRec;
    procedure RaiseBadIndex(const Index:TIndex);
    procedure WriteIndexAt(const Index: TIndex; const ARec:TIndexRec);
  protected
    FUserOwned : Boolean;
  public
    Constructor Create(const AIndex,AData:TStream); overload; virtual;
    Constructor Create(const AClass:TStreamClass); overload; virtual;

    Destructor Destroy; override;

    procedure Clear;
    procedure Trim;

    property Count:TIndex read FCount;
  end;

  TVariableStream<T>=class abstract(TVariableStream)
  private
    procedure Put(const Index: TIndex; const Value: T);
    procedure WriteData(const ARec: TIndexRec; const Value:T);
  protected
    function DataBytesOf(const Value:T):TBytes; virtual; abstract;
    function DataSize(const Value:T):TSize; virtual; abstract;
    function Get(const Index: TIndex): T; virtual; abstract;
  public
    function Append(const Value:T):TIndex;
    procedure Delete(const Index:TIndex; const ACount:TOneOrMore=1);

    property Items[const Index:TIndex]:T read Get write Put; default;
  end;

  EVariableStreamException=class(Exception);

  // Example:
  // Strings of variable length

  TStringsStream=class(TVariableStream<String>)
  protected
    function DataBytesOf(const Value:String):TBytes; override;
    function DataSize(const Value:String):TSize; override;
    function Get(const Index: TIndex): String; override;
  public
    Encoding : TEncoding;

    Constructor Create(const AIndex,AData:TStream); override;
  end;

implementation

{ TVariableStream }

Constructor TVariableStream.Create(const AIndex, AData: TStream);
begin
  inherited Create;

  FIndex:=AIndex;
  FData:=AData;

  FCount:=FIndex.Size div SizeOf(TIndexRec);
  FLast:=FData.Size;
end;

Constructor TVariableStream.Create(const AClass: TStreamClass);
begin
  Create(AClass.Create,AClass.Create);
end;

Destructor TVariableStream.Destroy;
var tmp : TSize;
begin
  tmp:=Count*SizeOf(TIndexRec);

  if FIndex.Size<>tmp then
     FIndex.Size:=tmp;

  if not FUserOwned then
  begin
    FIndex.Free;
    FData.Free;
  end;

  inherited;
end;

procedure TVariableStream.Clear;
begin
  FData.Size:=0;
  FIndex.Size:=0;

  FCount:=0;
  FLast:=0;
end;

procedure TVariableStream.RaiseBadIndex(const Index:TIndex);
begin
  raise EVariableStreamException.CreateFmt('Bad Index: ',[Index]);
end;

procedure TVariableStream.Trim;
begin
  FIndex.Size:=Count*SizeOf(TIndexRec);

  // Data:
  // ???
end;

procedure TVariableStream.CheckIndex(const Index: TIndex);
begin
  if (Index<0) or (Count<=Index) then
     RaiseBadIndex(Index);
end;

function TVariableStream.IndexAt(const Index: TIndex):TIndexRec;
var P : ^TIndexRec;
begin
  FIndex.Position:=Index*SizeOf(TIndexRec);

  P:=@result;
  FIndex.Read(P^,SizeOf(TIndexRec));
end;

function TVariableStream.BytesAt(const Index: TIndex):TBytes;
var tmp : TIndexRec;
begin
  CheckIndex(Index);

  tmp:=IndexAt(Index);

  if tmp.Size=0 then
     result:=nil
  else
  begin
    SetLength(result,tmp.Size);

    FData.Position:=tmp.Position;
    FData.Read(result,tmp.Size);
  end;
end;

procedure TVariableStream.WriteIndexAt(const Index: TIndex; const ARec:TIndexRec);
begin
  FIndex.Position:=Index*SizeOf(TIndexRec);
  FIndex.Write(ARec,SizeOf(TIndexRec));
end;

{ TVariableStream<T> }

function TVariableStream<T>.Append(const Value: T): TIndex;
var tmp : TIndexRec;
begin
  tmp.Position:=FLast;
  tmp.Size:=DataSize(Value);

  WriteIndexAt(Count,tmp);

  Inc(FCount);

  WriteData(tmp,Value);

  Inc(FLast,tmp.Size);
end;

procedure TVariableStream<T>.WriteData(const ARec: TIndexRec; const Value:T);
begin
  FData.Position:=ARec.Position;
  FData.WriteData(DataBytesOf(Value),ARec.Size);
end;

procedure TVariableStream<T>.Delete(const Index: TIndex; const ACount:TOneOrMore=1);
var tmp : Array of TIndexRec;
    tmpSize : TSize;
begin
  CheckIndex(Index);

  FIndex.Position:=(Index+ACount)*SizeOf(TIndexRec);

  SetLength(tmp,Count-ACount);

  tmpSize:=(Count-ACount)*SizeOf(TIndexRec);
  FIndex.ReadData(tmp,tmpSize);

  FIndex.Position:=Index*SizeOf(TIndexRec);
  FIndex.WriteData(tmp,tmpSize);

  Dec(FCount,ACount);
end;

procedure TVariableStream<T>.Put(const Index: TIndex; const Value: T);
var tmp : TIndexRec;
    tmpSize : TSize;
    tmpBigger : Boolean;
begin
  CheckIndex(Index);

  tmp:=IndexAt(Index);

  tmpSize:=DataSize(Value);

  tmpBigger:=tmpSize>tmp.Size;

  if tmpBigger then
     tmp.Position:=FLast;

  tmp.Size:=tmpSize;

  WriteIndexAt(Index,tmp);

  WriteData(tmp,Value);

  if tmpBigger then
     Inc(FLast,tmp.Size);
end;

{ TStringsStream }

Constructor TStringsStream.Create(const AIndex,AData:TStream);
begin
  inherited;
  Encoding:=TEncoding.Default;
end;

function TStringsStream.DataBytesOf(const Value: String): TBytes;
begin
  result:=Encoding.GetBytes(Value);
end;

function TStringsStream.DataSize(const Value: String): TSize;
begin
  result:=Encoding.GetByteCount(Value);
end;

function TStringsStream.Get(const Index: TIndex): String;
begin
  result:=Encoding.GetString(BytesAt(Index));
end;

end.
