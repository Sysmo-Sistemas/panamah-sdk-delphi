unit PanamahSDK.JsonUtils;

interface

uses
  Classes, DateUtils, SysUtils, Variants, PanamahSDK.Types, uLkJSON;

type
  TSerializerFunction = function(const AJSON: string): IJSONSerializable of object;

  IPanamahStringValueList = interface(IJSONSerializable)
    ['{6011B746-B54A-447C-924E-FB647D2C5335}']
    function GetItem(AIndex: Integer): string;
    procedure SetItem(AIndex: Integer; const Value: string);
    procedure Add(const AItem: string);
    procedure Clear;
    function Count: Integer;
    property Items[AIndex: Integer]: string read GetItem write SetItem; default;
    function IndexOf(const Value: string): Integer;
  end;

  TPanamahStringValueList = class(TInterfacedObject, IPanamahStringValueList)
  private
    FList: TStrings;
    function GetItem(AIndex: Integer): string;
    procedure SetItem(AIndex: Integer; const Value: string);
    procedure AddJSONObjectToList(ElName: string; Elem: TlkJSONbase; Data: pointer; var Continue: Boolean);
  public
    function SerializeToJSON: string;
    procedure DeserializeFromJSON(const AJSON: string);
    class function FromJSON(const AJSON: string): IPanamahStringValueList;
    constructor Create;
    procedure Add(const AItem: string);
    procedure Clear;
    function Count: Integer;
    destructor Destroy; override;
    property Items[AIndex: Integer]: string read GetItem write SetItem; default;
    function IndexOf(const Value: string): Integer;
  end;

  function DateTimeToISO8601(const AInput: TDateTime): string;
  function ISO8601ToDateTime(const AInput: string): TDateTime;
  function GetFieldValue(AJSONObject: TlkJSONbase; const AName: string; const ADefault: Variant): Variant; overload;
  function GetFieldValue(AJSONObject: TlkJSONbase; const AName: string): Variant; overload;
  function GetFieldValueAsString(AJSONObject: TlkJSONbase; const AName, ADefault: string): string; overload;
  function GetFieldValueAsString(AJSONObject: TlkJSONbase; const AName: string): string; overload;
  function GetFieldValueAsInteger(AJSONObject: TlkJSONbase; const AName: string; ADefault: Integer): Integer; overload;
  function GetFieldValueAsInteger(AJSONObject: TlkJSONbase; const AName: string): Integer; overload;
  function GetFieldValueAsBoolean(AJSONObject: TlkJSONbase; const AName: string; ADefault: Boolean): Boolean; overload;
  function GetFieldValueAsBoolean(AJSONObject: TlkJSONbase; const AName: string): Boolean; overload;
  function GetFieldValueAsDouble(AJSONObject: TlkJSONbase; const AName: string; ADefault: Double): Double; overload;
  function GetFieldValueAsDouble(AJSONObject: TlkJSONbase; const AName: string): Double; overload;
  function GetFieldValueAsDateTime(AJSONObject: TlkJSONbase; const AName: string; ADefault: TDateTime): Double; overload;
  function GetFieldValueAsDateTime(AJSONObject: TlkJSONbase; const AName: string): TDateTime; overload;
  procedure SetFieldValue(AJSONObject: TlkJSONobject; const AName: string; AValue: Variant); overload;
  procedure SetFieldValue(AJSONObject: TlkJSONobject; const AName: string;  AValue: IJSONSerializable); overload;

implementation

function GetFieldValue(AJSONObject: TlkJSONbase; const AName: string; const ADefault: Variant): Variant; overload;
begin
  Result := ADefault;
  if AJSONObject.Field[AName] <> nil then
    Result := AJSONObject.Field[AName].Value;
end;

function GetFieldValue(AJSONObject: TlkJSONbase; const AName: string): Variant; overload;
begin
  Result := GetFieldValue(AJSONObject, AName, Unassigned);
end;

function GetFieldValueAsString(AJSONObject: TlkJSONbase; const AName, ADefault: string): string; overload;
var
  FieldValue: Variant;
begin
  FieldValue := GetFieldValue(AJSONObject, AName);
  if VarIsNull(FieldValue) then
    Result := EmptyStr
  else
  if FieldValue = Unassigned then
    Result := ADefault
  else
    Result := VarToStr(FieldValue);
end;

function GetFieldValueAsString(AJSONObject: TlkJSONbase; const AName: string): string; overload;
begin
  Result := GetFieldValueAsString(AJSONObject, AName, EmptyStr);
end;

function GetFieldValueAsInteger(AJSONObject: TlkJSONbase; const AName: string; ADefault: Integer): Integer; overload;
begin
  Result := GetFieldValue(AJSONObject, AName);
  if Result = Unassigned then
    Result := ADefault
  else
    Result := StrToIntDef(VarToStr(Result), ADefault);
end;

function GetFieldValueAsInteger(AJSONObject: TlkJSONbase; const AName: string): Integer; overload;
begin
  Result := GetFieldValueAsInteger(AJSONObject, AName, 0);
end;

function GetFieldValueAsBoolean(AJSONObject: TlkJSONbase; const AName: string; ADefault: Boolean): Boolean; overload;
begin
  Result := GetFieldValue(AJSONObject, AName);
  if Result = Unassigned then
    Result := ADefault
  else
    Result := StrToBoolDef(VarToStr(Result), ADefault);
end;

function GetFieldValueAsBoolean(AJSONObject: TlkJSONbase; const AName: string): Boolean; overload;
begin
  Result := GetFieldValueAsBoolean(AJSONObject, AName, False);
end;

function GetFieldValueAsDouble(AJSONObject: TlkJSONbase; const AName: string; ADefault: Double): Double; overload;
begin
  Result := GetFieldValue(AJSONObject, AName);
  if Result = Unassigned then
    Result := ADefault
  else
    Result := StrToFloatDef(VarToStr(Result), ADefault);
end;

function GetFieldValueAsDouble(AJSONObject: TlkJSONbase; const AName: string): Double; overload;
begin
  Result := GetFieldValueAsDouble(AJSONObject, AName, 0);
end;

function GetFieldValueAsDateTime(AJSONObject: TlkJSONbase; const AName: string; ADefault: TDateTime): Double; overload;
var
  FieldValue: Variant;
begin
  FieldValue := GetFieldValue(AJSONObject, AName);
  if FieldValue = Unassigned then
    Result := ADefault
  else
  begin
    case VarType(FieldValue) of
      varDate: Result := VarToDateTime(FieldValue);
      varDouble: Result := FieldValue;
      else
        Result := ISO8601ToDateTime(FieldValue);
    end;
  end;
end;

function GetFieldValueAsDateTime(AJSONObject: TlkJSONbase; const AName: string): TDateTime; overload;
begin
  Result := GetFieldValueAsDateTime(AJSONObject, AName, 0);
end;

function DateTimeToISO8601(const AInput: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd', AInput) + 'T' + FormatDateTime('hh:nn:ss', AInput) + '+0000';
end;

function ISO8601ToDateTime(const AInput: string): TDateTime;
var
  Day, Month, Year, Hour, Minute, Second, Millisecond: Word;
begin
  if Trim(AInput) = EmptyStr then
    Result := 0
  else
    try
      Year := StrToInt(Copy(AInput, 1, 4));
      Month := StrToInt(Copy(AInput, 6, 2));
      Day := StrToInt(Copy(AInput, 9, 2));
      Hour := StrToIntDef(Copy(AInput, 12, 2), 0);
      Minute := StrToIntDef(Copy(AInput, 15, 2), 0);
      Second := StrToIntDef(Copy(AInput, 18, 2), 0);
      Millisecond := StrToIntDef(Copy(AInput, 21, 3), 0);
      Result := EncodeDate(Year, Month, Day) + EncodeTime(Hour, Minute, Second, Millisecond);
    except
      on E: Exception do
      begin
        raise e.Create('Falha na convers�o de data');
      end;
    end;
end;

procedure SetFieldValue(AJSONObject: TlkJSONobject; const AName: string; AValue: Variant); overload;
begin
  if AValue <> Unassigned then
  begin
    case varType(AValue) of
      varEmpty:
        AJSONObject.Add(AName, TlkJSONstring.Generate(EmptyStr));
      varSmallint, varInteger, varInt64, varDouble, varCurrency, varShortInt, varWord, varLongWord:
        AJSONObject.Add(AName, TlkJSONnumber.Generate(AValue));
      varDate:
        AJSONObject.Add(AName, TlkJSONstring.Generate(DateTimeToISO8601(VarToDateTime(AValue))));
      varString, {$IFDEF VER130}varUString,{$ENDIF} varOleStr, varStrArg:
        AJSONObject.Add(AName, TlkJSONstring.Generate(VarToStr(AValue)));
      varBoolean:
        AJSONObject.Add(AName, TlkJSONboolean.Generate(AValue <> 0));
      varNull:
        AJSONObject.Add(AName, TlkJSONnull.Create);
      else
        AJSONObject.Add(AName, TlkJSONstring.Generate(VarToStr(AValue)));
    end;
  end;
end;

procedure SetFieldValue(AJSONObject: TlkJSONobject; const AName: string; AValue: IJSONSerializable); overload;
begin
  if AValue <> nil then
    AJSONObject.Add(AName, TlkJSON.ParseText(AValue.SerializeToJSON));
end;

{ TPanamahStringValueList }

procedure TPanamahStringValueList.Add(const AItem: string);
begin
  FList.Add(AItem);
end;

procedure TPanamahStringValueList.Clear;
begin
  FList.Clear;
end;

function TPanamahStringValueList.Count: Integer;
begin
  Result := FList.Count;
end;

constructor TPanamahStringValueList.Create;
begin
  FList := TStringList.Create;
end;

destructor TPanamahStringValueList.Destroy;
begin
  FList.Destroy;
  inherited;
end;

function TPanamahStringValueList.GetItem(AIndex: Integer): string;
begin
  Result := FList[AIndex];
end;

function TPanamahStringValueList.IndexOf(const Value: string): Integer;
begin
  Result := FList.IndexOf(Value);
end;

procedure TPanamahStringValueList.SetItem(AIndex: Integer; const Value: string);
begin
  FList[AIndex] := Value;
end;

procedure TPanamahStringValueList.DeserializeFromJSON(const AJSON: string);
begin
  with TlkJSON.ParseText(AJSON) as TlkJSONlist do
  begin
    ForEach(AddJSONObjectToList, nil);
    Free;
  end;
end;

class function TPanamahStringValueList.FromJSON(const AJSON: string): IPanamahStringValueList;
begin
  Result := TPanamahStringValueList.Create;
  Result.DeserializeFromJSON(AJSON);
end;

function TPanamahStringValueList.SerializeToJSON: string;
var
  JSONObject: TlkJSONlist;
  I: Integer;
begin
  JSONObject := TlkJSONlist.Create;
  try
    for I := 0 to FList.Count - 1 do
      JSONObject.Add(TlkJSONstring.Generate(FList[I]));
    Result := TlkJSON.GenerateText(JSONObject);
  finally
    JSONObject.Free;
  end;
end;

procedure TPanamahStringValueList.AddJSONObjectToList(ElName: string; Elem: TlkJSONbase; Data: pointer;
  var Continue: Boolean);
begin
  FList.Add(Elem.Value);
end;

end.