program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  SafeComponentReference in 'SafeComponentReference.pas';

type
  TSafeTestReference = TSafeComponentReference<TComponent>;

var
  LC: Integer;
  Components: TArray<TComponent>;
  Reference1, Reference2: TSafeTestReference;

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
  LocalReference1, LocalReference2: TSafeTestReference;
begin
  LocalComponent := TComponent.Create(nil);
  try
    LocalReference1 := nil;
    LocalReference2 := nil;
    CheckUnassigned(LocalReference1);
    CheckUnassigned(LocalReference2);
    LocalReference1.Target := LocalComponent;
    LocalReference2 := LocalReference1;
    CheckAssigned(LocalReference1);
    CheckAssigned(LocalReference2);
    FreeAndNil(LocalComponent);
    CheckUnassigned(LocalReference1);
    CheckUnassigned(LocalReference2);
  finally
    if Assigned(LocalComponent) then
      LocalComponent.Free;
  end;
end;

procedure LocalTest2;
var
  LocalComponent: TComponent;
  LocalReference1, LocalReference2: TSafeTestReference;
begin
  LocalComponent := TComponent.Create(nil);
  try
    LocalReference1 := LocalComponent;
    LocalReference2 := LocalReference1;
    CheckAssigned(LocalReference1);
    CheckAssigned(LocalReference2);
    FreeAndNil(LocalComponent);
    CheckUnassigned(LocalReference1);
    CheckUnassigned(LocalReference2);
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
      Reference1 := Components[LC];
      Reference2 := Reference1;
      CheckAssigned(Reference2);
      CheckAssigned(Reference1);
      FreeAndNil(Components[LC]);
      CheckUnassigned(Reference1);
      CheckUnassigned(Reference2);

      Inc(LC);

      Reference1 := nil;
      Reference2 := nil;
      CheckUnassigned(Reference1);
      CheckUnassigned(Reference2);
      Reference1.Target := Components[LC];
      Reference2 := Reference1;
      CheckAssigned(Reference1);
      CheckAssigned(Reference2);
      FreeAndNil(Components[LC]);
      CheckUnassigned(Reference1);
      CheckUnassigned(Reference2);

      Inc(LC);

      Reference1 := TSafeTestReference(Components[LC]);
      Reference2 := Reference1;
      CheckAssigned(Reference1);
      CheckAssigned(Reference2);
      FreeAndNil(Components[LC]);
      CheckUnassigned(Reference1);
      CheckUnassigned(Reference2);

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
