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
  TSafeTestReference = TSafeComponentReference<TComponent>;

var
  LC: Integer;
  Components: TArray<TComponent>;
  Reference: TSafeTestReference;

procedure CheckAssigned(const AValue: TComponent);
begin
  Assert(Assigned(AValue));
end;

procedure CheckUnassigned(const AValue: TComponent);
begin
  Assert(not Assigned(AValue));
end;

procedure LocalTest1;
var
  LocalComponent: TComponent;
  LocalReference: TSafeTestReference;
begin
  LocalComponent := TComponent.Create(nil);
  try
    LocalReference := nil;
    CheckUnassigned(LocalReference);
    LocalReference.Target := LocalComponent;
    CheckAssigned(LocalReference);
    FreeAndNil(LocalComponent);
    CheckUnassigned(LocalReference);
  finally
    if Assigned(LocalComponent) then
      LocalComponent.Free;
  end;
end;

procedure LocalTest2;
var
  LocalComponent: TComponent;
  LocalReference: TSafeTestReference;
begin
  LocalComponent := TComponent.Create(nil);
  try
    LocalReference := LocalComponent;
    CheckAssigned(LocalReference);
    FreeAndNil(LocalComponent);
    CheckUnassigned(LocalReference);
  finally
    if Assigned(LocalComponent) then
      LocalComponent.Free;
  end;
end;

begin
  ReportMemoryLeaksOnShutdown := True;

  for LC := 0 to 2 do
    Components := Components + [TComponent.Create(nil)];

  try
    LC := 0;
    try
      Reference := Components[LC];
      CheckAssigned(Reference);
      FreeAndNil(Components[LC]);
      CheckUnassigned(Reference);

      Inc(LC);

      Reference := nil;
      CheckUnassigned(Reference);
      Reference.Target := Components[LC];
      CheckAssigned(Reference);
      FreeAndNil(Components[LC]);
      CheckUnassigned(Reference);

      Inc(LC);

      Reference := TSafeTestReference(Components[LC]);
      CheckAssigned(Reference);
      FreeAndNil(Components[LC]);
      CheckUnassigned(Reference);

      LocalTest1;
      LocalTest2;

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
