{$M+}
unit PanamahSDK.Models.Cliente;

interface

uses
  Classes, SysUtils, PanamahSDK.Types, PanamahSDK.Enums, Variants, uLkJSON;

type
  
  IPanamahCliente = interface(IPanamahModel)
    ['{081BF4E0-7736-11E9-A131-EBAF8D88186A}']
    function GetId: string;
    function GetNome: string;
    function GetNumeroDocumento: string;
    function GetRamo: string;
    function GetUf: string;
    function GetCidade: string;
    function GetBairro: string;
    procedure SetId(const AId: string);
    procedure SetNome(const ANome: string);
    procedure SetNumeroDocumento(const ANumeroDocumento: string);
    procedure SetRamo(const ARamo: string);
    procedure SetUf(const AUf: string);
    procedure SetCidade(const ACidade: string);
    procedure SetBairro(const ABairro: string);
    property Id: string read GetId write SetId;
    property Nome: string read GetNome write SetNome;
    property NumeroDocumento: string read GetNumeroDocumento write SetNumeroDocumento;
    property Ramo: string read GetRamo write SetRamo;
    property Uf: string read GetUf write SetUf;
    property Cidade: string read GetCidade write SetCidade;
    property Bairro: string read GetBairro write SetBairro;
  end;
  
  IPanamahClienteList = interface(IPanamahModelList)
    ['{081BF4E1-7736-11E9-A131-EBAF8D88186A}']
    function GetItem(AIndex: Integer): IPanamahCliente;
    procedure SetItem(AIndex: Integer; const Value: IPanamahCliente);
    procedure Add(const AItem: IPanamahCliente);
    property Items[AIndex: Integer]: IPanamahCliente read GetItem write SetItem; default;
  end;
  
  TPanamahCliente = class(TInterfacedObject, IPanamahCliente)
  private
    FId: string;
    FNome: string;
    FNumeroDocumento: string;
    FRamo: string;
    FUf: string;
    FCidade: string;
    FBairro: string;
    function GetId: string;
    function GetNome: string;
    function GetNumeroDocumento: string;
    function GetRamo: string;
    function GetUf: string;
    function GetCidade: string;
    function GetBairro: string;
    procedure SetId(const AId: string);
    procedure SetNome(const ANome: string);
    procedure SetNumeroDocumento(const ANumeroDocumento: string);
    procedure SetRamo(const ARamo: string);
    procedure SetUf(const AUf: string);
    procedure SetCidade(const ACidade: string);
    procedure SetBairro(const ABairro: string);
    function GetModelName: string;    
  public
    function SerializeToJSON: string;
    procedure DeserializeFromJSON(const AJSON: string);
    function Clone: IPanamahModel;
    class function FromJSON(const AJSON: string): IPanamahCliente;
    function Validate: IPanamahValidationResult;
  published
    property Id: string read GetId write SetId;
    property Nome: string read GetNome write SetNome;
    property NumeroDocumento: string read GetNumeroDocumento write SetNumeroDocumento;
    property Ramo: string read GetRamo write SetRamo;
    property Uf: string read GetUf write SetUf;
    property Cidade: string read GetCidade write SetCidade;
    property Bairro: string read GetBairro write SetBairro;
  end;

  TPanamahClienteList = class(TInterfacedObject, IPanamahClienteList)
  private
    FList: TInterfaceList;
    function GetItem(AIndex: Integer): IPanamahCliente;
    procedure SetItem(AIndex: Integer; const Value: IPanamahCliente);
    function GetModel(AIndex: Integer): IPanamahModel;
    procedure SetModel(AIndex: Integer; const Value: IPanamahModel);
    procedure AddJSONObjectToList(ElName: string; Elem: TlkJSONbase; Data: pointer; var Continue: Boolean);
  public
    function Validate: IPanamahValidationResult;
    function SerializeToJSON: string;
    procedure DeserializeFromJSON(const AJSON: string);
    class function FromJSON(const AJSON: string): IPanamahClienteList;
    constructor Create;
    procedure Add(const AItem: IPanamahCliente);
    procedure Clear;
    function Count: Integer;
    destructor Destroy; override;
    property Items[AIndex: Integer]: IPanamahCliente read GetItem write SetItem; default;
    property Models[AIndex: Integer]: IPanamahModel read GetModel write SetModel;
  end;
  
  
  TPanamahClienteValidator = class(TInterfacedObject, IPanamahModelValidator)
  public
    function Validate(AModel: IPanamahModel): IPanamahValidationResult;
  end;
  
implementation

uses
  PanamahSDK.JsonUtils, PanamahSDK.ValidationUtils;

{ TPanamahCliente }

function TPanamahCliente.GetId: string;
begin
  Result := FId;
end;

procedure TPanamahCliente.SetId(const AId: string);
begin
  FId := AId;
end;

function TPanamahCliente.GetNome: string;
begin
  Result := FNome;
end;

procedure TPanamahCliente.SetNome(const ANome: string);
begin
  FNome := ANome;
end;

function TPanamahCliente.GetNumeroDocumento: string;
begin
  Result := FNumeroDocumento;
end;

procedure TPanamahCliente.SetNumeroDocumento(const ANumeroDocumento: string);
begin
  FNumeroDocumento := ANumeroDocumento;
end;

function TPanamahCliente.GetRamo: string;
begin
  Result := FRamo;
end;

procedure TPanamahCliente.SetRamo(const ARamo: string);
begin
  FRamo := ARamo;
end;

function TPanamahCliente.GetUf: string;
begin
  Result := FUf;
end;

procedure TPanamahCliente.SetUf(const AUf: string);
begin
  FUf := AUf;
end;

function TPanamahCliente.GetCidade: string;
begin
  Result := FCidade;
end;

procedure TPanamahCliente.SetCidade(const ACidade: string);
begin
  FCidade := ACidade;
end;

function TPanamahCliente.GetBairro: string;
begin
  Result := FBairro;
end;

procedure TPanamahCliente.SetBairro(const ABairro: string);
begin
  FBairro := ABairro;
end;

procedure TPanamahCliente.DeserializeFromJSON(const AJSON: string);
var
  JSONObject: TlkJSONobject;
begin
  JSONObject := TlkJSON.ParseText(AJSON) as TlkJSONobject;
  try
    FId := GetFieldValueAsString(JSONObject, 'id');
    FNome := GetFieldValueAsString(JSONObject, 'nome');
    FNumeroDocumento := GetFieldValueAsString(JSONObject, 'numeroDocumento');
    FRamo := GetFieldValueAsString(JSONObject, 'ramo');
    FUf := GetFieldValueAsString(JSONObject, 'uf');
    FCidade := GetFieldValueAsString(JSONObject, 'cidade');
    FBairro := GetFieldValueAsString(JSONObject, 'bairro');
  finally
    JSONObject.Free;
  end;
end;

function TPanamahCliente.SerializeToJSON: string;
var
  JSONObject: TlkJSONobject;
begin
  JSONObject := TlkJSONobject.Create;
  try    
    SetFieldValue(JSONObject, 'id', FId);    
    SetFieldValue(JSONObject, 'nome', FNome);    
    SetFieldValue(JSONObject, 'numeroDocumento', FNumeroDocumento);    
    SetFieldValue(JSONObject, 'ramo', FRamo);    
    SetFieldValue(JSONObject, 'uf', FUf);    
    SetFieldValue(JSONObject, 'cidade', FCidade);    
    SetFieldValue(JSONObject, 'bairro', FBairro);
    Result := TlkJSON.GenerateText(JSONObject);
  finally
    JSONObject.Free;
  end;
end;

class function TPanamahCliente.FromJSON(const AJSON: string): IPanamahCliente;
begin
  Result := TPanamahCliente.Create;
  Result.DeserializeFromJSON(AJSON);
end;

function TPanamahCliente.GetModelName: string;
begin
  Result := 'CLIENTE';
end;

function TPanamahCliente.Clone: IPanamahModel;
begin
  Result := TPanamahCliente.FromJSON(SerializeToJSON);
end;

function TPanamahCliente.Validate: IPanamahValidationResult;
var
  Validator: IPanamahModelValidator;
begin
  Validator := TPanamahClienteValidator.Create;
  Result := Validator.Validate(Self as IPanamahCliente);
end;

{ TPanamahClienteList }

constructor TPanamahClienteList.Create;
begin
  FList := TInterfaceList.Create;
end;

destructor TPanamahClienteList.Destroy;
begin
  FreeAndNil(FList);
  inherited;
end;

function TPanamahClienteList.Validate: IPanamahValidationResult;
var
  I: Integer;
begin
  Result := TPanamahValidationResult.CreateSuccess;
  FList.Lock;
  try
    for I := 0 to FList.Count - 1 do
      Result.Concat(Format('[%d]', [I]), (FList[I] as IPanamahCliente).Validate);
  finally
    FList.Unlock;
  end;
end;

class function TPanamahClienteList.FromJSON(const AJSON: string): IPanamahClienteList;
begin
  Result := TPanamahClienteList.Create;
  Result.DeserializeFromJSON(AJSON);
end;

function TPanamahClienteList.GetModel(AIndex: Integer): IPanamahModel;
begin
  Result := FList[AIndex] as IPanamahCliente;
end;

procedure TPanamahClienteList.SetModel(AIndex: Integer; const Value: IPanamahModel);
begin
  FList[AIndex] := Value;
end;

procedure TPanamahClienteList.Add(const AItem: IPanamahCliente);
begin
  FList.Add(AItem);
end;

procedure TPanamahClienteList.AddJSONObjectToList(ElName: string; Elem: TlkJSONbase; Data: pointer;
  var Continue: Boolean);
var
  Item: IPanamahCliente;
begin
  Item := TPanamahCliente.Create;
  Item.DeserializeFromJSON(TlkJSON.GenerateText(Elem));
  FList.Add(Item);
end;

procedure TPanamahClienteList.Clear;
begin
  FList.Clear;
end;

function TPanamahClienteList.Count: Integer;
begin
  Result := FList.Count;
end;

function TPanamahClienteList.GetItem(AIndex: Integer): IPanamahCliente;
begin
  Result := FList.Items[AIndex] as IPanamahCliente;
end;

procedure TPanamahClienteList.SetItem(AIndex: Integer;
  const Value: IPanamahCliente);
begin
  FList[AIndex] := Value;
end;

procedure TPanamahClienteList.DeserializeFromJSON(const AJSON: string);
begin
  with TlkJSON.ParseText(AJSON) as TlkJSONlist do
  begin
    ForEach(AddJSONObjectToList, nil);
    Free;
  end;
end;

function TPanamahClienteList.SerializeToJSON: string;
var
  JSONObject: TlkJSONlist;
  I: Integer;
begin
  FList.Lock;
  try
    JSONObject := TlkJSONlist.Create;
    try
      for I := 0 to FList.Count - 1 do
        JSONObject.Add(TlkJSON.ParseText((FList[I] as IPanamahCliente).SerializeToJSON));
      Result := TlkJSON.GenerateText(JSONObject);
    finally
      JSONObject.Free;
    end;
  finally
    FList.Unlock;
  end;
end;

{ TPanamahClienteValidator }

function TPanamahClienteValidator.Validate(AModel: IPanamahModel): IPanamahValidationResult;
var
  Cliente: IPanamahCliente;
  Validations: IPanamahValidationResultList;
begin
  Cliente := AModel as IPanamahCliente;
  Validations := TPanamahValidationResultList.Create;
  
  if ModelValueIsEmpty(Cliente.Id) then
    Validations.AddFailure('Cliente.Id obrigatorio(a)');
  
  if ModelValueIsEmpty(Cliente.Nome) then
    Validations.AddFailure('Cliente.Nome obrigatorio(a)');
  
  if ModelValueIsEmpty(Cliente.NumeroDocumento) then
    Validations.AddFailure('Cliente.NumeroDocumento obrigatorio(a)');
  
  if ModelValueIsEmpty(Cliente.Ramo) then
    Validations.AddFailure('Cliente.Ramo obrigatorio(a)');
  
  if ModelValueIsEmpty(Cliente.Uf) then
    Validations.AddFailure('Cliente.Uf obrigatorio(a)');
  
  if ModelValueIsEmpty(Cliente.Cidade) then
    Validations.AddFailure('Cliente.Cidade obrigatorio(a)');
  
  if ModelValueIsEmpty(Cliente.Bairro) then
    Validations.AddFailure('Cliente.Bairro obrigatorio(a)');
  
  Result := Validations.GetAggregate;
end;

end.