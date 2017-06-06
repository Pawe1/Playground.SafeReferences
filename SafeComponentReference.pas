unit SafeComponentReference;

interface

uses
  System.Classes,
  Sprinkles.Lifetime,
  Sprinkles.InterfacedComponent;

type
  IComponentReference<T: TComponent> = interface
    function GetTarget: T;
    procedure SetTarget(const AValue: T);
    property Target: T read GetTarget write SetTarget;
  end;

  TSmartComponentReference<T: TComponent> = class(TInterfacedComponent, IComponentReference<T>)
  private
    FTarget: T;
    FDestructionDetector: TDestructionDetector;
    procedure HandleTargetDestruction(ASender: TObject; AComponent: TComponent);
  public
    constructor Create(AOwner: TComponent); override;
    function GetTarget: T;
    procedure SetTarget(const AValue: T);
  end;

  TSafeComponentReference<T: TComponent> = record
  private
    FReference: IComponentReference<T>;   // this little workaround is needed because how record constructor works
    function GetTarget: T;
    procedure SetTarget(const ATarget: T);
    function Equals(const AOther: TSafeComponentReference<T>): Boolean;
  public
    property Target: T read GetTarget write SetTarget;
  public
    constructor Create(const ATarget: T);
    class operator Implicit(const value: TSafeComponentReference<T>): T;
    class operator Implicit(const value: T): TSafeComponentReference<T>;
    class operator Explicit(const value: TSafeComponentReference<T>): T;
    class operator Equal(const a, b: TSafeComponentReference<T>): Boolean;
    class operator NotEqual(const a, b: TSafeComponentReference<T>): Boolean;
  end;

implementation

uses
  System.Generics.Defaults;

constructor TSmartComponentReference<T>.Create(AOwner: TComponent);
begin
  inherited;
  FDestructionDetector := TDestructionDetector.Create(Self);
  FDestructionDetector.OnDestructingDetected := HandleTargetDestruction;
end;

function TSmartComponentReference<T>.GetTarget: T;
begin
  Result := FTarget;
end;

procedure TSmartComponentReference<T>.HandleTargetDestruction(ASender: TObject; AComponent: TComponent);
begin
  if AComponent = (FTarget as TComponent) then
    FTarget := nil;
end;

procedure TSmartComponentReference<T>.SetTarget(const AValue: T);
begin
  if FTarget <> AValue then
  begin
    FDestructionDetector.StopObserving(FTarget);
    FTarget := AValue;
    FDestructionDetector.StartObserving(FTarget);
  end;
end;

constructor TSafeComponentReference<T>.Create(const ATarget: T);
begin
  FReference := TSmartComponentReference<T>.Create(nil);
  FReference.SetTarget(ATarget);
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
  Result := FReference.GetTarget;
end;

class operator TSafeComponentReference<T>.Implicit(const value: TSafeComponentReference<T>): T;
begin
  Result := value.Target;
end;

class operator TSafeComponentReference<T>.Implicit(const value: T): TSafeComponentReference<T>;
begin
  Result := TSafeComponentReference<T>.Create(value);
end;

class operator TSafeComponentReference<T>.NotEqual(const a, b: TSafeComponentReference<T>): Boolean;
begin
  Result := not a.Equals(b);
end;

procedure TSafeComponentReference<T>.SetTarget(const ATarget: T);
begin
  FReference.SetTarget(ATarget);
end;

end.
