program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  SafeComponentReference in 'SafeComponentReference.pas';

type
  TTestComponentReference = TSafeComponentReference<TComponent>;

var
  C1: TComponent;
  R: TTestComponentReference;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    C1 := TComponent.Create(nil);
    R := C1;
    if not Assigned(R.Target) then
      Exception.Create('Test failed');
    C1.Free;
    if Assigned(R.Target) then
      Exception.Create('Test failed');


    C1 := TComponent.Create(nil);
    R := nil;
    R.Target := C1;
    if not Assigned(R.Target) then
      Exception.Create('Test failed');
    C1.Free;
    if Assigned(R.Target) then
      Exception.Create('Test failed');


    C1 := TComponent.Create(nil);
    R := TTestComponentReference(C1);
    if not Assigned(R.Target) then
      Exception.Create('Test failed');
    C1.Free;
    if Assigned(R.Target) then
      Exception.Create('Test failed');

    WriteLn('Voila!');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;
  ReadLn;
end.
