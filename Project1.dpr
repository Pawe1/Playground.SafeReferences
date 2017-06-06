program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  SafeComponentReference in 'SafeComponentReference.pas';

type
  TTestComponentReference = TSafeComponentReference<TComponent>;

var
  LC: Integer;
  Components: TArray<TComponent>;
  R: TTestComponentReference;

begin
  ReportMemoryLeaksOnShutdown := True;

  for LC := 0 to 2 do
    Components := Components + [TComponent.Create(nil)];

  try
    LC := 0;
    try
      R := Components[LC];
      Assert(Assigned(R.Target));
      FreeAndNil(Components[LC]);
      Assert(not Assigned(R.Target));

      Inc(LC);

      R := nil;
      R.Target := Components[LC];
      Assert(Assigned(R.Target));
      FreeAndNil(Components[LC]);
      Assert(not Assigned(R.Target));

      Inc(LC);

      R := TTestComponentReference(Components[LC]);
      Assert(Assigned(R.Target));
      FreeAndNil(Components[LC]);
      Assert(not Assigned(R.Target));

      WriteLn('Voila!');
    finally
      for LC := Low(Components) to High(Components) do
        if Assigned(Components[LC]) then
          Components[LC].Free;
    end;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;
  ReadLn;
end.
