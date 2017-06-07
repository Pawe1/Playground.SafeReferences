unit SafeComponentReference;

interface

uses
  System.Classes,
  Sprinkles.InterfacedComponent;

type
  IComponentReference<T: TComponent> = interface
    function GetTarget: T;
    procedure SetTarget(const AValue: T);
    property Target: T read GetTarget write SetTarget;
  end;

  TSmartReferenceProxy<T: TComponent> = class(TInterfacedComponent, IComponentReference<T>)
  private
    FTarget: T;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    function GetTarget: T;
    procedure SetTarget(const AValue: T);
  end;

  TSafeComponentReference<T: TComponent> = record   // only records support operator overloading
  private
    FReference: IComponentReference<T>;   // TInterfacedComponent let us use ARC magic
    function GetTarget: T;
    procedure SetTarget(const ATarget: T);
    function Equals(const AOther: TSafeComponentReference<T>): Boolean;
  public
    property Target: T read GetTarget write SetTarget;
  public
    constructor Create(const ATarget: T);
    class operator Implicit(const value: TSafeComponentReference<T>): T;
    class operator Implicit(const value: T): TSafeComponentReference<T>;
    class operator Implicit(value: TSafeComponentReference<T>): Pointer;
    class operator Implicit(value: TSafeComponentReference<T>): TObject;
    class operator Explicit(const value: TSafeComponentReference<T>): T;
    class operator Equal(const a, b: TSafeComponentReference<T>): Boolean;
    class operator NotEqual(const a, b: TSafeComponentReference<T>): Boolean;
  end;

implementation

uses
  System.Generics.Defaults;

function TSmartReferenceProxy<T>.GetTarget: T;
begin
  Result := FTarget;
end;

procedure TSmartReferenceProxy<T>.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = TOperation.opRemove) and (AComponent = (FTarget as TComponent)) then
    FTarget := nil;
  inherited;
end;

procedure TSmartReferenceProxy<T>.SetTarget(const AValue: T);
begin
  if FTarget <> AValue then
  begin
    if Assigned(FTarget) then
      FTarget.RemoveFreeNotification(Self);
    FTarget := AValue;
    if Assigned(FTarget) then
      FTarget.FreeNotification(Self);
  end;
end;

constructor TSafeComponentReference<T>.Create(const ATarget: T);
begin
  FReference := TSmartReferenceProxy<T>.Create(nil);
  FReference.Target := ATarget;
end;

class operator TSafeComponentReference<T>.Equal(const a, b: TSafeComponentReference<T>): Boolean;
begin
  Result := a.Equals(b);
end;

function TSafeComponentReference<T>.Equals(const AOther: TSafeComponentReference<T>): Boolean;
begin
  Result := TEqualityComparer<T>.Default.Equals(Target, AOther.Target);
end;

class operator TSafeComponentReference<T>.Explicit(const value: TSafeComponentReference<T>): T;
begin
  Result := value.Target;
end;

function TSafeComponentReference<T>.GetTarget: T;
begin
  Result := FReference.Target;
end;

class operator TSafeComponentReference<T>.Implicit(const value: TSafeComponentReference<T>): T;
begin
  Result := value.Target;
end;

class operator TSafeComponentReference<T>.Implicit(const value: T): TSafeComponentReference<T>;
begin
  Result := TSafeComponentReference<T>.Create(value);
end;

class operator TSafeComponentReference<T>.Implicit(value: TSafeComponentReference<T>): Pointer;
begin
  Result := Pointer(value.Target);
end;

class operator TSafeComponentReference<T>.Implicit(value: TSafeComponentReference<T>): TObject;
begin
  Result := value.Target;
end;

class operator TSafeComponentReference<T>.NotEqual(const a, b: TSafeComponentReference<T>): Boolean;
begin
  Result := not a.Equals(b);
end;

procedure TSafeComponentReference<T>.SetTarget(const ATarget: T);
begin
  FReference.Target := ATarget;
end;

end.
