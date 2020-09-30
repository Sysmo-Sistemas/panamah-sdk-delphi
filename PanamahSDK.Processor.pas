unit PanamahSDK.Processor;

interface

uses
  Classes, Windows, SysUtils, Messages, DateUtils, SyncObjs, PanamahSDK.Enums,
  PanamahSDK.Operation, PanamahSDK.Types, PanamahSDK.Batch, PanamahSDK.Client,
  PanamahSDK.Consts, uLkJSON, ActiveX, PanamahSDK.PendingResources, PanamahSDK.Log;

type

  TPanamahCancelableModelEvent = procedure(AModel: IPanamahModel; AAssinanteId: Variant;
    var AContinue: Boolean) of object;

  TPanamahErrorEvent = procedure(AError: Exception) of object;

  TPanamahBatchEvent = procedure(ABatch: IPanamahBatch) of object;

  TPanamahModelEvent = procedure(AModel: IPanamahModel; AAssinanteId: Variant) of object;

  TPanamahOperationEvent = procedure(AModel: IPanamahOperation) of object;

  TPanamahBatchProcessor = class(TThread)
  private
    FCriticalSection: TCriticalSection;
    FOnBeforeSave: TPanamahCancelableModelEvent;
    FOnBeforeDelete: TPanamahCancelableModelEvent;
    FOnError: TPanamahErrorEvent;
    FOnCurrentBatchExpired: TPanamahBatchEvent;
    FOnBeforeObjectAddedToBatch: TPanamahModelEvent;
    FOnAfterSave: TPanamahModelEvent;
    FOnAfterDelete: TPanamahModelEvent;
    FOnAfterSaveSync: TPanamahModelEvent;
    FOnAfterDeleteSync: TPanamahModelEvent;
    FOnBeforeBatchSent: TPanamahBatchEvent;
    FOnBeforeOperationSent: TPanamahOperationEvent;
    FClient: IPanamahClient;
    FConfig: IPanamahStreamConfig;
    FCurrentBatch: IPanamahBatch;
    FStarted: Boolean;
    function GetBatchAccumulationDirectory: string;
    function GetBatchSentDirectory: string;
    function GetCurrentBatchFilename: string;
    function AccumulatedBatchesExists: Boolean;
    function CurrentBatchExpiredByTime(ABatchTTL: Integer): Boolean;
    function BatchExpiredBySize(AMaxSize: Integer): Boolean;
    function BatchExpiredByCount(AMaxCount: Integer): Boolean;
    procedure DoOnBeforeSave(AModel: IPanamahModel; AAssinanteId: Variant; var AContinue: Boolean);
    procedure DoOnAfterSave(AModel: IPanamahModel; AAssinanteId: Variant);
    procedure DoOnBeforeDelete(AModel: IPanamahModel; AAssinanteId: Variant; var AContinue: Boolean);
    procedure DoOnAfterDelete(AModel: IPanamahModel; AAssinanteId: Variant);
    procedure DoOnError(AError: Exception);
    procedure AccumulateCurrentBatch;
    procedure DoOnCurrentBatchExpired;
    procedure DoOnBeforeObjectAddedToBatch(AModel: IPanamahModel; AAssinanteId: Variant);
    procedure DoAfterSaveSync(AModel: IPanamahModel; AAssinanteId: Variant);
    procedure DoAfterDeleteSync(AModel: IPanamahModel; AAssinanteId: Variant);
    procedure DoOnBeforeBatchSent(ABatch: IPanamahBatch);
    procedure DoOnBeforeOperationSent(AOperation: IPanamahOperation);
    procedure SendAccumulatedBatches;
    procedure LoadCurrentBatch;
    procedure SaveCurrentBatch;
    procedure ExpireCurrentBatch;
    procedure RemoveOldSentBatches;
    procedure TriggerAfterSync(ASourceBatch: IPanamahBatch);
    procedure CreateBatchWithFailedOperations(ASourceBatch: IPanamahBatch; AFailedOperations: IPanamahOperationList);
    procedure Process;
    procedure AddOperationToCurrentBatch(AOperationType: TPanamahOperationType; AModel: IPanamahModel; AAssinanteId: Variant);
  public
    destructor Destroy; override;
    constructor Create; reintroduce;
    procedure Start(AConfig: IPanamahStreamConfig); reintroduce;
    procedure Execute; override;
    procedure Stop;
    property OnCurrentBatchExpired: TPanamahBatchEvent read FOnCurrentBatchExpired write FOnCurrentBatchExpired;
    property OnBeforeObjectAddedToBatch: TPanamahModelEvent read FOnBeforeObjectAddedToBatch write FOnBeforeObjectAddedToBatch;
    property OnBeforeBatchSent: TPanamahBatchEvent read FOnBeforeBatchSent write FOnBeforeBatchSent;
    property OnBeforeOperationSent: TPanamahOperationEvent read FOnBeforeOperationSent write FOnBeforeOperationSent;
    property OnBeforeSave: TPanamahCancelableModelEvent read FOnBeforeSave write FOnBeforeSave;
    property OnBeforeDelete: TPanamahCancelableModelEvent read FOnBeforeDelete write FOnBeforeDelete;
    property OnError: TPanamahErrorEvent read FOnError write FOnError;
    property OnAfterDelete: TPanamahModelEvent read FOnAfterDelete write FOnAfterDelete;
    property OnAfterSave: TPanamahModelEvent read FOnAfterSave write FOnAfterSave;
    property OnAfterDeleteSync: TPanamahModelEvent read FOnAfterDeleteSync write FOnAfterDeleteSync;
    property OnAfterSaveSync: TPanamahModelEvent read FOnAfterSaveSync write FOnAfterSaveSync;
    procedure Save(AModel: IPanamahModel; AAssinanteId: Variant); overload;
    procedure Delete(AModel: IPanamahModel; AAssinanteId: Variant); overload;
    procedure Save(AModel: IPanamahModel); overload;
    procedure Delete(AModel: IPanamahModel); overload;
    procedure Flush;
    function GetPendingResources: IPanamahPendingResourcesList;
  end;

  IPanamahCountedOperations = interface(IJSONSerializable)
    ['{6410783B-0596-422A-ABF4-827696C6BDDD}']
    function GetTotal: Integer;
    function GetItens: IPanamahOperationList;
    procedure SetTotal(ATotal: Integer);
    procedure SetItens(AItens: IPanamahOperationList);
    property Total: Integer read GetTotal write SetTotal;
    property Itens: IPanamahOperationList read GetItens write SetItens;
  end;

  IPanamahBatchResponse = interface(IJSONSerializable)
    ['{12404D7B-9274-4F3D-BF35-2C17EAFB2C03}']
    function GetSucessos: IPanamahCountedOperations;
    function GetFalhas: IPanamahCountedOperations;
    procedure SetSucessos(ASucessos: IPanamahCountedOperations);
    procedure SetFalhas(AFalhas: IPanamahCountedOperations);
    property Sucessos: IPanamahCountedOperations read GetSucessos write SetSucessos;
    property Falhas: IPanamahCountedOperations read GetFalhas write SetFalhas;
  end;

  TPanamahCountedOperations = class(TInterfacedObject, IPanamahCountedOperations)
  private
    FTotal: Integer;
    FItens: IPanamahOperationList;
    function GetTotal: Integer;
    function GetItens: IPanamahOperationList;
    procedure SetTotal(ATotal: Integer);
    procedure SetItens(AItens: IPanamahOperationList);
  public
    procedure DeserializeFromJSON(const AJSON: string);
    function SerializeToJSON: string;
    class function FromJSON(const AJSON: string): IPanamahCountedOperations;
    property Total: Integer read GetTotal write SetTotal;
    property Itens: IPanamahOperationList read GetItens write SetItens;
  end;

  TPanamahBatchResponse = class(TInterfacedObject, IPanamahBatchResponse)
  private
    FSucessos: IPanamahCountedOperations;
    FFalhas: IPanamahCountedOperations;
    function GetSucessos: IPanamahCountedOperations;
    function GetFalhas: IPanamahCountedOperations;
    procedure SetSucessos(ASucessos: IPanamahCountedOperations);
    procedure SetFalhas(AFalhas: IPanamahCountedOperations);
  public
    procedure DeserializeFromJSON(const AJSON: string);
    function SerializeToJSON: string;
    class function FromJSON(const AJSON: string): IPanamahBatchResponse;
    property Sucessos: IPanamahCountedOperations read GetSucessos write SetSucessos;
    property Falhas: IPanamahCountedOperations read GetFalhas write SetFalhas;
  end;

implementation

uses
  PanamahSDK.ValidationUtils, PanamahSDK.JsonUtils;

{ TPanamahBatchProcessor }

procedure TPanamahBatchProcessor.AccumulateCurrentBatch;
begin
  FCriticalSection.Acquire;
  try
    FCurrentBatch.SaveToDirectory(GetBatchAccumulationDirectory);
    FCurrentBatch.Reset;
    DeleteFile(GetCurrentBatchFilename);
  finally
    FCriticalSection.Release;
  end;
end;

procedure TPanamahBatchProcessor.Save(AModel: IPanamahModel; AAssinanteId: Variant);
var
  ValidationResult: IPanamahValidationResult;
  KeepExecuting: Boolean;
begin
  TPanamahLogger.Log('Save ' + AModel.ModelName);
  KeepExecuting := True;
  try
    DoOnBeforeSave(AModel, AAssinanteId, KeepExecuting);
  except
    on EAbort do
      KeepExecuting := False;
    on E: Exception do
      raise E;
  end;
  TPanamahLogger.Log('BeforeSave hook executed');
  if KeepExecuting then
  begin
    ValidationResult := AModel.Validate;
    if ValidationResult.Valid then
    begin
      AddOperationToCurrentBatch(otUPDATE, AModel, AAssinanteId);
      DoOnAfterSave(AModel, AAssinanteId);
      TPanamahLogger.Log('Update operation added to the current batch');
    end
    else
    begin
      TPanamahLogger.Log('Validation failed, raising exception');
      raise EPanamahSDKValidationException.Create(ValidationResult.Reasons.Text);
    end;
  end;
end;

procedure TPanamahBatchProcessor.Delete(AModel: IPanamahModel; AAssinanteId: Variant);
var
  KeepExecuting: Boolean;
begin
  TPanamahLogger.Log('Delete ' + AModel.ModelName);
  KeepExecuting := True;
  try
    DoOnBeforeDelete(AModel, AAssinanteId, KeepExecuting);
  except
    on EAbort do
      KeepExecuting := False;
    on E: Exception do
      raise E;
  end;
  TPanamahLogger.Log('BeforeDelete hook executed');
  if KeepExecuting then
  begin
    if ModelHasId(AModel) then
    begin
      AddOperationToCurrentBatch(otDELETE, AModel, AAssinanteId);
      DoOnAfterDelete(AModel, AAssinanteId);
      TPanamahLogger.Log('Delete operation added to the current batch');
    end
    else
    begin
      TPanamahLogger.Log('Id missing, raising exception');
      raise EPanamahSDKValidationException.Create(Format('Id obrigatorio para exclusao de %s', [AModel.ModelName]));
    end;
  end;
end;

function TPanamahBatchProcessor.GetBatchAccumulationDirectory: string;
begin
  Result := (FConfig.BaseDirectory + '\accumulated');
end;

function TPanamahBatchProcessor.GetBatchSentDirectory: string;
begin
  Result := (FConfig.BaseDirectory + '\sent');
end;

function TPanamahBatchProcessor.GetCurrentBatchFilename: string;
begin
  Result := (FConfig.BaseDirectory + '\current.pbt');
end;

function TPanamahBatchProcessor.GetPendingResources: IPanamahPendingResourcesList;
begin
  TPanamahLogger.Log('Getting pending resources');
  Result := nil;
  if Assigned(FClient) then
    Result := TPanamahPendingResourcesList.Obtain(FClient);
end;

function TPanamahBatchProcessor.AccumulatedBatchesExists: Boolean;
var
  AccumulatedBatchesCount: Integer;
begin
  TPanamahLogger.Log('Checking for accumulated batches');
  AccumulatedBatchesCount := TPanamahBatchList.CountBatchesInDirectory(GetBatchAccumulationDirectory, FConfig.AssinanteId);
  TPanamahLogger.Log(Format('Found %d accumulated batch(es)', [AccumulatedBatchesCount]));
  Result := AccumulatedBatchesCount > 0;
end;

procedure TPanamahBatchProcessor.AddOperationToCurrentBatch(AOperationType: TPanamahOperationType;
  AModel: IPanamahModel; AAssinanteId: Variant);
begin
  DoOnBeforeObjectAddedToBatch(AModel, AAssinanteId);

  FCriticalSection.Acquire;
  try
    FCurrentBatch.Add(TPanamahOperation.Create(AOperationType, AModel.Clone, AAssinanteId));

    if BatchExpiredByCount(FConfig.BatchMaxCount) then
    begin
      ExpireCurrentBatch;
    end;
  finally
    FCriticalSection.Release;
  end;
end;

function TPanamahBatchProcessor.BatchExpiredByCount(AMaxCount: Integer): Boolean;
begin
  Result := FCurrentBatch.Count >= AMaxCount;
end;

function TPanamahBatchProcessor.BatchExpiredBySize(AMaxSize: Integer): Boolean;
begin
  Result := FCurrentBatch.Size > AMaxSize;
end;

function TPanamahBatchProcessor.CurrentBatchExpiredByTime(ABatchTTL: Integer): Boolean;
begin
  Result := MilliSecondsBetween(Now, FCurrentBatch.CreatedAt) >= ABatchTTL;
end;

constructor TPanamahBatchProcessor.Create;
begin
  inherited Create(True);
  FCriticalSection := TCriticalSection.Create;
end;

procedure TPanamahBatchProcessor.CreateBatchWithFailedOperations(
  ASourceBatch: IPanamahBatch; AFailedOperations: IPanamahOperationList);
var
  I, X: Integer;
  BatchOperation, FailedOperation: IPanamahOperation;
  PriorityBatch: IPanamahBatch;
begin
  PriorityBatch := TPanamahBatch.Create;
  PriorityBatch.Priority := True;
  for I := 0 to AFailedOperations.Count - 1 do
  begin
    FailedOperation := AFailedOperations[I];
    for X := 0 to ASourceBatch.Count - 1 do
    begin
      BatchOperation := ASourceBatch.Items[I];
      if BatchOperation.Equals(FailedOperation) then
        PriorityBatch.Add(BatchOperation.Clone);
    end;
  end;
  PriorityBatch.SaveToDirectory(GetBatchAccumulationDirectory);
  ASourceBatch.MoveToDirectory(GetBatchAccumulationDirectory, GetBatchSentDirectory);
end;

procedure TPanamahBatchProcessor.DoOnCurrentBatchExpired;
begin
  if Assigned(FOnCurrentBatchExpired) then
    FOnCurrentBatchExpired(FCurrentBatch);
end;

procedure TPanamahBatchProcessor.DoOnError(AError: Exception);
begin
  TPanamahLogger.Log(Format('Error hook called with %s', [AError.Message]));
  if Assigned(FOnError) then
    FOnError(AError);
end;

procedure TPanamahBatchProcessor.Delete(AModel: IPanamahModel);
begin
  Delete(AModel, varEmpty);
end;

destructor TPanamahBatchProcessor.Destroy;
begin
  FCriticalSection.Free;
  inherited;
end;

procedure TPanamahBatchProcessor.DoAfterSaveSync(AModel: IPanamahModel; AAssinanteId: Variant);
begin
  if Assigned(FOnAfterSaveSync) then
    FOnAfterSaveSync(AModel, AAssinanteId);
end;

procedure TPanamahBatchProcessor.DoAfterDeleteSync(AModel: IPanamahModel; AAssinanteId: Variant);
begin
  if Assigned(FOnAfterDeleteSync) then
    FOnAfterDeleteSync(AModel, AAssinanteId);
end;

procedure TPanamahBatchProcessor.DoOnAfterDelete(AModel: IPanamahModel; AAssinanteId: Variant);
begin
  if Assigned(FOnAfterDelete) then
    FOnAfterDelete(AModel, AAssinanteId);
end;

procedure TPanamahBatchProcessor.DoOnAfterSave(AModel: IPanamahModel; AAssinanteId: Variant);
begin
  if Assigned(FOnAfterSave) then
    FOnAfterSave(AModel, AAssinanteId);
end;

procedure TPanamahBatchProcessor.DoOnBeforeBatchSent(ABatch: IPanamahBatch);
var
  I: Integer;
begin
  if Assigned(FOnBeforeBatchSent) then
    FOnBeforeBatchSent(ABatch);
  if Assigned(FOnBeforeOperationSent) then
    for I := 0 to ABatch.Count - 1 do
      DoOnBeforeOperationSent(ABatch.Items[I]);
end;

procedure TPanamahBatchProcessor.DoOnBeforeDelete(AModel: IPanamahModel; AAssinanteId: Variant; var AContinue: Boolean);
begin
  if Assigned(FOnBeforeDelete) then
    FOnBeforeDelete(AModel, AAssinanteId, AContinue);
end;

procedure TPanamahBatchProcessor.DoOnBeforeObjectAddedToBatch(AModel: IPanamahModel; AAssinanteId: Variant);
begin
  if Assigned(FOnBeforeObjectAddedToBatch) then
    FOnBeforeObjectAddedToBatch(AModel, AAssinanteId);
end;

procedure TPanamahBatchProcessor.DoOnBeforeOperationSent(AOperation: IPanamahOperation);
begin
  if Assigned(FOnBeforeOperationSent) then
    FOnBeforeOperationSent(AOperation);
end;

procedure TPanamahBatchProcessor.DoOnBeforeSave(AModel: IPanamahModel; AAssinanteId: Variant; var AContinue: Boolean);
begin
  if Assigned(FOnBeforeSave) then
    FOnBeforeSave(AModel, AAssinanteId, AContinue);
end;

procedure TPanamahBatchProcessor.Execute;
begin
  inherited;
  CoInitialize(nil);
  try
    LoadCurrentBatch;
    Process;
  finally
    CoUninitialize;
  end;
end;

procedure TPanamahBatchProcessor.ExpireCurrentBatch;
begin
  DoOnCurrentBatchExpired;
  AccumulateCurrentBatch;
end;

procedure TPanamahBatchProcessor.Flush;
begin
  TPanamahLogger.Log('Flushing stream');
  if FCurrentBatch.Count > 0 then
  begin
    TPanamahLogger.Log(Format('Current open batch has %d entities, accumulating...', [FCurrentBatch.Count]));
    AccumulateCurrentBatch;
  end;
  SendAccumulatedBatches;
end;

procedure TPanamahBatchProcessor.LoadCurrentBatch;
var
  CurrentBatchFromFile: IPanamahBatch;
begin
  FCriticalSection.Acquire;
  try
    TPanamahLogger.Log('Loading current batch');
    if FileExists(GetCurrentBatchFilename) then
    begin
      CurrentBatchFromFile := TPanamahBatch.FromFile(GetCurrentBatchFilename);
      TPanamahLogger.Log('Current batch loaded');
      if CurrentBatchFromFile.Count > 0 then
      begin
        FCurrentBatch := CurrentBatchFromFile.Clone;
        TPanamahLogger.Log('Current batch cloned');
      end;
    end
    else
      TPanamahLogger.Log('No current batch found');
  finally
    FCriticalSection.Release;
  end;
end;

procedure TPanamahBatchProcessor.Process;
var
  CurrentBatchLastHash: string;
begin
  while not Terminated do
  begin
    try
      if AccumulatedBatchesExists then
      begin
        SendAccumulatedBatches;
      end
      else if FCurrentBatch.Count > 0 then
      begin
        if CurrentBatchExpiredByTime(FConfig.BatchTTL) then
          ExpireCurrentBatch
        else
        if FCurrentBatch.Hash <> CurrentBatchLastHash then
        begin
          if BatchExpiredBySize(FConfig.BatchMaxSize) then
          begin
            ExpireCurrentBatch
          end
          else
          begin
            TPanamahLogger.Log('Current batch expired');
            SaveCurrentBatch;
            CurrentBatchLastHash := FCurrentBatch.Hash;
          end;
        end;
      end;
      RemoveOldSentBatches;
    except
      on E: Exception do
      begin
        try
          DoOnError(E);
        except
        end;
      end;
    end;
    Sleep(500);
  end;
end;

procedure TPanamahBatchProcessor.RemoveOldSentBatches;
var
  SentBatches: IPanamahBatchList;
  I: Integer;
begin
  TPanamahLogger.Log('Removing old sent batches');
  SentBatches :=  TPanamahBatchList.FromDirectory(GetBatchSentDirectory);
  for I := 0 to SentBatches.Count - 1 do
  begin
    if (Now - SentBatches[I].CreatedAt) > 1 then
      SentBatches[I].RemoveFromDirectory(GetBatchSentDirectory);
  end;
   TPanamahLogger.Log('Done removing old batches');
end;

procedure TPanamahBatchProcessor.Save(AModel: IPanamahModel);
begin
  Save(AModel, varEmpty);
end;

procedure TPanamahBatchProcessor.SaveCurrentBatch;
var
  Filename: string;
begin
  if FCurrentBatch.Count > 0 then
  begin
    FCriticalSection.Acquire;
    try
      Filename := GetCurrentBatchFilename;
      FCurrentBatch.SaveToFile(Filename);
      TPanamahLogger.Log(Format('Current batch saved to %s', [Filename]));
    finally
      FCriticalSection.Release;
    end;
  end;
end;

procedure TPanamahBatchProcessor.SendAccumulatedBatches;
var
  AccumulatedBatches: IPanamahBatchList;
  Response: IPanamahResponse;
  BatchResponse: IPanamahBatchResponse;
  I: Integer;
begin
  TPanamahLogger.Log('Sending accumulated batches');
  FCriticalSection.Acquire;
  try
    AccumulatedBatches := TPanamahBatchList.FromDirectory(GetBatchAccumulationDirectory);
    TPanamahLogger.Log(Format('Loaded %d batches from accumulating directory', [AccumulatedBatches.Count]));
    for I := 0 to AccumulatedBatches.Count - 1 do
    begin
      if AccumulatedBatches[I].Count > 0 then
      begin
        if FConfig.AssinanteId <> '*' then
        begin
          TPanamahLogger.Log(Format('Found %d entities in batch number %d', [AccumulatedBatches[I].Count, I]));
          if AccumulatedBatches[I].Assinantes.Count > 1 then
          begin
            TPanamahLogger.Log(Format('Multiple assinantes found inside batch number %d, ignoring...', [AccumulatedBatches[I].Count, I]));
            Continue;
          end
          else
          if AccumulatedBatches[I].Assinantes.Count = 1 then
          begin
            TPanamahLogger.Log(Format('Single assinante %s found inside batch number %d', [AccumulatedBatches[I].Assinantes[0], I]));
            if AccumulatedBatches[I].Assinantes[0] <> FConfig.AssinanteId then
            begin
              TPanamahLogger.Log('Assinante not logged in, ignoring...');
              Continue;
            end;
          end
          else
          begin
            TPanamahLogger.Log(Format('No assinantes found inside batch number %d, using %s', [I, FConfig.AssinanteId]));
          end;
        end;
        DoOnBeforeBatchSent(AccumulatedBatches[I].Clone);
        TPanamahLogger.Log('Before sent hook executed, requesting /stream/data');
        Response := FClient.Post('/stream/data', AccumulatedBatches[I].SerializeToJSON, nil);
        TPanamahLogger.Log(Format('Request to /stream/data executed with status %d', [Response.Status]));
        if Response.Status = 200 then
        begin
          BatchResponse := TPanamahBatchResponse.FromJSON(Response.Content);
          TPanamahLogger.Log('Response deserialized');
          if Assigned(BatchResponse.Falhas) and
              (BatchResponse.Falhas.Total > 0) then
          begin
            TPanamahLogger.Log('Some operations failed, creating batch with failures');
            CreateBatchWithFailedOperations(AccumulatedBatches[I], BatchResponse.Falhas.Itens);
            Break;
          end
          else
          begin
            TPanamahLogger.Log('Triggering AfterSync hook');
            TriggerAfterSync(AccumulatedBatches[I]);
            TPanamahLogger.Log('Success, moving batch to sent directory');
            AccumulatedBatches[I].MoveToDirectory(GetBatchAccumulationDirectory, GetBatchSentDirectory);
            TPanamahLogger.Log('Done');
          end;
        end;
      end
      else
      begin
        TPanamahLogger.Log('Batch was empty, discarding');
        AccumulatedBatches[I].MoveToDirectory(GetBatchAccumulationDirectory, GetBatchSentDirectory);
      end;
    end;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TPanamahBatchProcessor.Start(AConfig: IPanamahStreamConfig);
begin
  TPanamahLogger.Log('Processor started');
  FConfig := AConfig;
  FClient := TPanamahStreamClient.Create(API_BASE_URL, FConfig.AuthorizationToken, FConfig.Secret, FConfig.AssinanteId);
  FCurrentBatch := TPanamahBatch.Create;
  FStarted := True;
  inherited {$IFDEF UNICODE}Start{$ELSE}Resume{$ENDIF};
end;

procedure TPanamahBatchProcessor.Stop;
begin
  TPanamahLogger.Log('Processor stop requested');
  Terminate;
  if FStarted then
  begin
    WaitFor;
    TPanamahLogger.Log('Processor successfully stopped');
    FStarted := False;
  end;
end;

procedure TPanamahBatchProcessor.TriggerAfterSync(ASourceBatch: IPanamahBatch);
var
  I: Integer;
  BatchOperation: IPanamahOperation;
begin
  for I := 0 to ASourceBatch.Count - 1 do
  begin
    BatchOperation := ASourceBatch.Items[I];
    case BatchOperation.OperationType of
      otUPDATE: DoAfterSaveSync(BatchOperation.Data, BatchOperation.AssinanteId);
      otDELETE: DoAfterDeleteSync(BatchOperation.Data, BatchOperation.AssinanteId);
    end;
  end;
end;

{ TPanamahBatchResponse }

procedure TPanamahBatchResponse.DeserializeFromJSON(const AJSON: string);
var
  JSONObject: TlkJSONobject;
begin
  JSONObject := TlkJSON.ParseText(AJSON) as TlkJSONobject;
  try
    if JSONObject.Field['falhas'] is TlkJSONobject then
      FFalhas := TPanamahCountedOperations.FromJSON(TlkJSON.GenerateText(JSONObject.Field['falhas']));
    if JSONObject.Field['sucessos'] is TlkJSONobject then
      FSucessos := TPanamahCountedOperations.FromJSON(TlkJSON.GenerateText(JSONObject.Field['sucessos']));
  finally
    JSONObject.Free;
  end;
end;

function TPanamahBatchResponse.SerializeToJSON: string;
var
  JSONObject: TlkJSONobject;
begin
  JSONObject := TlkJSONobject.Create;
  try
    SetFieldValue(JSONObject, 'falhas', FFalhas);
    SetFieldValue(JSONObject, 'sucessos', FSucessos);
    Result := TlkJSON.GenerateText(JSONObject);
  finally
    JSONObject.Free;
  end;
end;

class function TPanamahBatchResponse.FromJSON(const AJSON: string): IPanamahBatchResponse;
begin
  Result := TPanamahBatchResponse.Create;
  Result.DeserializeFromJSON(AJSON);
end;

function TPanamahBatchResponse.GetFalhas: IPanamahCountedOperations;
begin
  Result := FFalhas;
end;

function TPanamahBatchResponse.GetSucessos: IPanamahCountedOperations;
begin
  Result := FSucessos;
end;

procedure TPanamahBatchResponse.SetFalhas(AFalhas: IPanamahCountedOperations);
begin
  FFalhas := AFalhas;
end;

procedure TPanamahBatchResponse.SetSucessos(ASucessos: IPanamahCountedOperations);
begin
  FSucessos := ASucessos;
end;

{ TPanamahCountedOperations }

procedure TPanamahCountedOperations.DeserializeFromJSON(const AJSON: string);
var
  JSONObject: TlkJSONobject;
begin
  JSONObject := TlkJSON.ParseText(AJSON) as TlkJSONobject;
  try
    FTotal := GetFieldValueAsInteger(JSONObject, 'total');
    if JSONObject.Field['itens'] is TlkJSONlist then
      FItens := TPanamahOperationList.FromJSON(TlkJSON.GenerateText(JSONObject.Field['itens']));
  finally
    JSONObject.Free;
  end;
end;

function TPanamahCountedOperations.SerializeToJSON: string;
var
  JSONObject: TlkJSONobject;
begin
  JSONObject := TlkJSONobject.Create;
  try
    SetFieldValue(JSONObject, 'total', FTotal);
    SetFieldValue(JSONObject, 'itens', FItens);
    Result := TlkJSON.GenerateText(JSONObject);
  finally
    JSONObject.Free;
  end;
end;

class function TPanamahCountedOperations.FromJSON(const AJSON: string): IPanamahCountedOperations;
begin
  Result := TPanamahCountedOperations.Create;
  Result.DeserializeFromJSON(AJSON);
end;

function TPanamahCountedOperations.GetItens: IPanamahOperationList;
begin
  Result := FItens;
end;

function TPanamahCountedOperations.GetTotal: Integer;
begin
  Result := FTotal;
end;

procedure TPanamahCountedOperations.SetItens(AItens: IPanamahOperationList);
begin
  FItens := AItens;
end;

procedure TPanamahCountedOperations.SetTotal(ATotal: Integer);
begin
  FTotal := ATotal;
end;

end.
