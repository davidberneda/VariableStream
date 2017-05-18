program Variable_Stream_Example;

uses
  Vcl.Forms,
  Unit_Test_Variable_Stream in 'Unit_Test_Variable_Stream.pas' {TestForm},
  VariableStream in '..\..\src\VariableStream.pas';

{$R *.res}

begin
  {$IFOPT D+}
  ReportMemoryLeaksOnShutdown:=True;
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTestForm, TestForm);
  Application.Run;
end.
