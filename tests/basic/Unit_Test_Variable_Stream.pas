unit Unit_Test_Variable_Stream;

interface

{
  Test a variable stream of Strings.

  Do the test using in-memory streams, and file streams.
}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,

  VariableStream,

  Vcl.StdCtrls, System.IOUtils;

type
  TTestForm = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Memo2: TMemo;
    ListBox1: TListBox;
    Button2: TButton;
    ListBox2: TListBox;
    ListBox3: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }

    procedure AddItems(const AStream:TStringsStream; const AItems:TStrings);
    procedure Test(const AStream:TStringsStream);
  public
    { Public declarations }
  end;

var
  TestForm: TTestForm;

implementation

{$R *.dfm}

const
  Max_Examples=5;
  Examples:Array[0..Max_Examples-1] of String=('Hello','This is quite a long text','12 34 56','','A');

  Num_Samples=100000;

function RandomString:String;
begin
  result:=Examples[Random(Max_Examples)];
end;

procedure TTestForm.AddItems(const AStream:TStringsStream; const AItems:TStrings);
var t : Integer;
begin
  AItems.BeginUpdate;
  try
    AItems.Clear;

    for t:=0 to AStream.Count-1 do
        AItems.Add(AStream[t]);
  finally
    AItems.EndUpdate;
  end;
end;

procedure TTestForm.Test(const AStream:TStringsStream);
var t : Integer;
begin
  // Clear
  AStream.Clear;

  // Add many strings

  for t:=0 to Num_Samples-1 do
      AStream.Append(RandomString);

  // Show Count
  Memo2.Clear;
  Memo2.Lines.Add('Count: '+AStream.Count.ToString);

  // Show Items
  AddItems(AStream,ListBox1.Items);

  // Delete one item
  AStream.Delete(0);

  // Show Items
  AddItems(AStream,ListBox2.Items);

  // Modify one item
  AStream[3]:='New Text !';

  // Show Items
  AddItems(AStream,ListBox3.Items);

  // Remove empty unused space
  AStream.Trim;
end;

procedure TTestForm.Button1Click(Sender: TObject);
var Data : TStringsStream;
begin
  Data:=TStringsStream.Create(TMemoryStream);
  try
    Test(Data);
  finally
    Data.Free;
  end;
end;

const
  TestIndex='test.index';

procedure TTestForm.Button2Click(Sender: TObject);
var Data : TStringsStream;
begin
  Data:=TStringsStream.Create(TFileStream.Create(TestIndex,fmCreate),
                              TFileStream.Create('test.data',fmCreate));
  try
    Test(Data);
  finally
    Data.Free;
  end;
end;

procedure TTestForm.FormCreate(Sender: TObject);
var Data : TStringsStream;
begin
  Memo2.Clear;

  if TFile.Exists(TestIndex) then
  begin
    Data:=TStringsStream.Create(TFileStream.Create('test.index',fmOpenRead),
                                TFileStream.Create('test.data',fmOpenRead));
    try
      AddItems(Data,ListBox1.Items);
    finally
      Data.Free;
    end;
  end;
end;

end.
