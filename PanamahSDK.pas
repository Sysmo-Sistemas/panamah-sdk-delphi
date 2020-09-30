{$M+}
unit PanamahSDK;

interface

uses
  Classes, Windows, SysUtils, Messages, DateUtils, SyncObjs, PanamahSDK.Enums, PanamahSDK.Operation, PanamahSDK.Types,
  PanamahSDK.Client, PanamahSDK.Batch, PanamahSDK.Models.Acesso, PanamahSDK.Models.Assinante, PanamahSDK.Models.Cliente,
  PanamahSDK.Models.Compra, PanamahSDK.Models.Ean, PanamahSDK.Models.EstoqueMovimentacao, PanamahSDK.Models.EventoCaixa,
  PanamahSDK.Models.FormaPagamento, PanamahSDK.Models.Fornecedor, PanamahSDK.Models.Funcionario,
  PanamahSDK.Models.Grupo, PanamahSDK.Models.Holding, PanamahSDK.Models.LocalEstoque, PanamahSDK.Models.Loja,
  PanamahSDK.Models.Meta, PanamahSDK.Models.Produto, PanamahSDK.Models.Revenda, PanamahSDK.Models.Secao,
  PanamahSDK.Models.Subgrupo, PanamahSDK.Models.TituloPagar, PanamahSDK.Models.TituloReceber,
  PanamahSDK.Models.TrocaDevolucao, PanamahSDK.Models.TrocaFormaPagamento, PanamahSDK.Models.Venda, PanamahSDK.Processor,
  PanamahSDK.NFe, PanamahSDK.Consts, PanamahSDK.PendingResources, PanamahSDK.MiscTypes;

type

  TPanamahStreamConfig = class(TInterfacedObject, IPanamahStreamConfig)
  private
    FAssinanteId: string;
    FSecret: string;
    FAuthorizationToken: string;
    FBaseDirectory: string;
    FBatchTTL: Integer;
    FBatchMaxSize: Integer;
    FBatchMaxCount: Integer;
    function GetBaseDirectory: string;
    function GetBatchTTL: Integer;
    function GetBatchMaxSize: Integer;
    function GetBatchMaxCount: Integer;
    function GetAssinanteId: string;
    function GetSecret: string;
    function GetAuthorizationToken: string;
    procedure SetAuthorizationToken(const AAuthorizationToken: string);
    procedure SetBaseDirectory(const ABaseDirectory: string);
    procedure SetAssinanteId(const AAssinanteId: string);
    procedure SetSecret(const ASecret: string);
  published
    constructor Create; reintroduce;
    property BaseDirectory: string read GetBaseDirectory write SetBaseDirectory;
    property BatchTTL: Integer read GetBatchTTL;
    property BatchMaxSize: Integer read GetBatchMaxSize;
    property BatchMaxCount: Integer read GetBatchMaxCount;
    property AssinanteId: string read GetAssinanteId write SetAssinanteId;
    property Secret: string read GetSecret write SetSecret;
    property AuthorizationToken: string read GetAuthorizationToken write SetAuthorizationToken;
  end;

  TPanamahAdminConfig = class(TInterfacedObject, IPanamahAdminConfig)
  private
    FAuthorizationToken: string;
    function GetAuthorizationToken: string;
    procedure SetAuthorizationToken(const AAuthorizationToken: string);
  published
    constructor Create; reintroduce;
    property AuthorizationToken: string read GetAuthorizationToken write SetAuthorizationToken;
  end;

  TPanamahAdmin = class
  private
    FConfig: IPanamahAdminConfig;
    FClient: IPanamahClient;
  public
    procedure Init(AConfig: IPanamahAdminConfig); overload;
    procedure Init(const AAuthorizationToken: string); overload;
    function GetAssinante(const AAssinanteId: string): IPanamahAssinante;
    function GenerateKey(const AAssinanteId: string): string;
    function ResetKey(const AAssinanteId, AOldKey: string): string;
    function SaveAssinante(AAssinante: IPanamahAssinante): Boolean;
    constructor Create; reintroduce;
    class function GetInstance: TPanamahAdmin;
    class procedure Free;
  end;

  TPanamahStream = class
  private
    FConfig: IPanamahStreamConfig;
    FProcessor: TPanamahBatchProcessor;
    function GetOnCurrentBatchExpired: TPanamahBatchEvent;
    function GetOnBeforeObjectAddedToBatch: TPanamahModelEvent;
    function GetOnBeforeOperationtSent: TPanamahOperationEvent;
    function GetOnBeforeBatchSent: TPanamahBatchEvent;
    function GetOnBeforeSave: TPanamahCancelableModelEvent;
    function GetOnBeforeDelete: TPanamahCancelableModelEvent;
    function GetOnError: TPanamahErrorEvent;
    function GetOnAfterSave: TPanamahModelEvent;
    function GetOnAfterDelete: TPanamahModelEvent;
    function GetOnAfterSaveSync: TPanamahModelEvent;
    function GetOnAfterDeleteSync: TPanamahModelEvent;

    procedure SetOnBeforeSave(AEvent: TPanamahCancelableModelEvent);
    procedure SetOnBeforeDelete(AEvent: TPanamahCancelableModelEvent);
    procedure SetOnError(AEvent: TPanamahErrorEvent);
    procedure SetOnCurrentBatchExpired(AEvent: TPanamahBatchEvent);
    procedure SetOnBeforeObjectAddedToBatch(AEvent: TPanamahModelEvent);
    procedure SetOnBeforeBatchSent(AEvent: TPanamahBatchEvent);
    procedure SetOnBeforeOperationSent(AEvent: TPanamahOperationEvent);
    procedure SetOnAfterSave(AEvent: TPanamahModelEvent);
    procedure SetOnAfterDelete(AEvent: TPanamahModelEvent);
    procedure SetOnAfterSaveSync(AEvent: TPanamahModelEvent);
    procedure SetOnAfterDeleteSync(AEvent: TPanamahModelEvent);
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    class procedure Free;
    class function GetInstance: TPanamahStream;
    function ReadNFeDirectory(const ADirectory: string): IPanamahNFeDocumentList; overload;
    function ReadNFe(const AFilename: string): IPanamahNFeDocument; overload;
    function ReadNFe(ADocumentType: TPanamahNFeDocumentType; const AFilename: string): IPanamahNFeDocument; overload;
    function GetPendingResources: IPanamahPendingResourcesList;
    procedure Init; overload;
    procedure Init(AConfig: IPanamahStreamConfig); overload;
    procedure Init(const AAuthorizationToken, ASecret: string); overload;
    procedure Init(const AAuthorizationToken, ASecret, AAssinanteId: string); overload;
    procedure Flush;

    procedure Save(ANFeDocumentList: IPanamahNFeDocumentList; AAssinanteId: Variant); overload;
    procedure Save(ANFeDocument: IPanamahNFeDocument; AAssinanteId: Variant); overload;
    procedure Save(AAcesso: IPanamahAcesso; AAssinanteId: Variant); overload;
    procedure Save(ACliente: IPanamahCliente; AAssinanteId: Variant); overload;
    procedure Save(ACompra: IPanamahCompra; AAssinanteId: Variant); overload;
    procedure Save(AEan: IPanamahEan; AAssinanteId: Variant); overload;
    procedure Save(AEstoqueMovimentacao: IPanamahEstoqueMovimentacao; AAssinanteId: Variant); overload;
    procedure Save(AEventoCaixa: IPanamahEventoCaixa; AAssinanteId: Variant); overload;
    procedure Save(AFormaPagamento: IPanamahFormaPagamento; AAssinanteId: Variant); overload;
    procedure Save(AFornecedor: IPanamahFornecedor; AAssinanteId: Variant); overload;
    procedure Save(AFuncionario: IPanamahFuncionario; AAssinanteId: Variant); overload;
    procedure Save(AGrupo: IPanamahGrupo; AAssinanteId: Variant); overload;
    procedure Save(AHolding: IPanamahHolding; AAssinanteId: Variant); overload;
    procedure Save(ALocalEstoque: IPanamahLocalEstoque; AAssinanteId: Variant); overload;
    procedure Save(ALoja: IPanamahLoja; AAssinanteId: Variant); overload;
    procedure Save(AMeta: IPanamahMeta; AAssinanteId: Variant); overload;
    procedure Save(AProduto: IPanamahProduto; AAssinanteId: Variant); overload;
    procedure Save(ARevenda: IPanamahRevenda; AAssinanteId: Variant); overload;
    procedure Save(ASecao: IPanamahSecao; AAssinanteId: Variant); overload;
    procedure Save(ASubgrupo: IPanamahSubgrupo; AAssinanteId: Variant); overload;
    procedure Save(ATituloPagar: IPanamahTituloPagar; AAssinanteId: Variant); overload;
    procedure Save(ATituloReceber: IPanamahTituloReceber; AAssinanteId: Variant); overload;
    procedure Save(ATrocaDevolucao: IPanamahTrocaDevolucao; AAssinanteId: Variant); overload;
    procedure Save(ATrocaFormaPagamento: IPanamahTrocaFormaPagamento; AAssinanteId: Variant); overload;
    procedure Save(AVenda: IPanamahVenda; AAssinanteId: Variant); overload;
    procedure Delete(AAcesso: IPanamahAcesso; AAssinanteId: Variant); overload;
    procedure Delete(ACliente: IPanamahCliente; AAssinanteId: Variant); overload;
    procedure Delete(ACompra: IPanamahCompra; AAssinanteId: Variant); overload;
    procedure Delete(AEan: IPanamahEan; AAssinanteId: Variant); overload;
    procedure Delete(AEstoqueMovimentacao: IPanamahEstoqueMovimentacao; AAssinanteId: Variant); overload;
    procedure Delete(AEventoCaixa: IPanamahEventoCaixa; AAssinanteId: Variant); overload;
    procedure Delete(AFormaPagamento: IPanamahFormaPagamento; AAssinanteId: Variant); overload;
    procedure Delete(AFornecedor: IPanamahFornecedor; AAssinanteId: Variant); overload;
    procedure Delete(AFuncionario: IPanamahFuncionario; AAssinanteId: Variant); overload;
    procedure Delete(AGrupo: IPanamahGrupo; AAssinanteId: Variant); overload;
    procedure Delete(AHolding: IPanamahHolding; AAssinanteId: Variant); overload;
    procedure Delete(ALocalEstoque: IPanamahLocalEstoque; AAssinanteId: Variant); overload;
    procedure Delete(ALoja: IPanamahLoja; AAssinanteId: Variant); overload;
    procedure Delete(AMeta: IPanamahMeta; AAssinanteId: Variant); overload;
    procedure Delete(AProduto: IPanamahProduto; AAssinanteId: Variant); overload;
    procedure Delete(ARevenda: IPanamahRevenda; AAssinanteId: Variant); overload;
    procedure Delete(ASecao: IPanamahSecao; AAssinanteId: Variant); overload;
    procedure Delete(ASubgrupo: IPanamahSubgrupo; AAssinanteId: Variant); overload;
    procedure Delete(ATituloPagar: IPanamahTituloPagar; AAssinanteId: Variant); overload;
    procedure Delete(ATituloReceber: IPanamahTituloReceber; AAssinanteId: Variant); overload;
    procedure Delete(ATrocaDevolucao: IPanamahTrocaDevolucao; AAssinanteId: Variant); overload;
    procedure Delete(ATrocaFormaPagamento: IPanamahTrocaFormaPagamento; AAssinanteId: Variant); overload;
    procedure Delete(AVenda: IPanamahVenda; AAssinanteId: Variant); overload;

    procedure Save(ANFeDocumentList: IPanamahNFeDocumentList); overload;
    procedure Save(ANFeDocument: IPanamahNFeDocument); overload;
    procedure Save(AAcesso: IPanamahAcesso); overload;
    procedure Save(ACliente: IPanamahCliente); overload;
    procedure Save(ACompra: IPanamahCompra); overload;
    procedure Save(AEan: IPanamahEan); overload;
    procedure Save(AEstoqueMovimentacao: IPanamahEstoqueMovimentacao); overload;
    procedure Save(AEventoCaixa: IPanamahEventoCaixa); overload;
    procedure Save(AFormaPagamento: IPanamahFormaPagamento); overload;
    procedure Save(AFornecedor: IPanamahFornecedor); overload;
    procedure Save(AFuncionario: IPanamahFuncionario); overload;
    procedure Save(AGrupo: IPanamahGrupo); overload;
    procedure Save(AHolding: IPanamahHolding); overload;
    procedure Save(ALocalEstoque: IPanamahLocalEstoque); overload;
    procedure Save(ALoja: IPanamahLoja); overload;
    procedure Save(AMeta: IPanamahMeta); overload;
    procedure Save(AProduto: IPanamahProduto); overload;
    procedure Save(ARevenda: IPanamahRevenda); overload;
    procedure Save(ASecao: IPanamahSecao); overload;
    procedure Save(ASubgrupo: IPanamahSubgrupo); overload;
    procedure Save(ATituloPagar: IPanamahTituloPagar); overload;
    procedure Save(ATituloReceber: IPanamahTituloReceber); overload;
    procedure Save(ATrocaDevolucao: IPanamahTrocaDevolucao); overload;
    procedure Save(ATrocaFormaPagamento: IPanamahTrocaFormaPagamento); overload;
    procedure Save(AVenda: IPanamahVenda); overload;
    procedure Delete(AAcesso: IPanamahAcesso); overload;
    procedure Delete(ACliente: IPanamahCliente); overload;
    procedure Delete(ACompra: IPanamahCompra); overload;
    procedure Delete(AEan: IPanamahEan); overload;
    procedure Delete(AEstoqueMovimentacao: IPanamahEstoqueMovimentacao); overload;
    procedure Delete(AEventoCaixa: IPanamahEventoCaixa); overload;
    procedure Delete(AFormaPagamento: IPanamahFormaPagamento); overload;
    procedure Delete(AFornecedor: IPanamahFornecedor); overload;
    procedure Delete(AFuncionario: IPanamahFuncionario); overload;
    procedure Delete(AGrupo: IPanamahGrupo); overload;
    procedure Delete(AHolding: IPanamahHolding); overload;
    procedure Delete(ALocalEstoque: IPanamahLocalEstoque); overload;
    procedure Delete(ALoja: IPanamahLoja); overload;
    procedure Delete(AMeta: IPanamahMeta); overload;
    procedure Delete(AProduto: IPanamahProduto); overload;
    procedure Delete(ARevenda: IPanamahRevenda); overload;
    procedure Delete(ASecao: IPanamahSecao); overload;
    procedure Delete(ASubgrupo: IPanamahSubgrupo); overload;
    procedure Delete(ATituloPagar: IPanamahTituloPagar); overload;
    procedure Delete(ATituloReceber: IPanamahTituloReceber); overload;
    procedure Delete(ATrocaDevolucao: IPanamahTrocaDevolucao); overload;
    procedure Delete(ATrocaFormaPagamento: IPanamahTrocaFormaPagamento); overload;
    procedure Delete(AVenda: IPanamahVenda); overload;

    procedure SaveModel(APanamahModel: IPanamahModel); overload;
    procedure SaveModel(APanamahModel: IPanamahModel; AAssinanteId: Variant); overload;
    procedure DeleteModel(APanamahModel: IPanamahModel); overload;
    procedure DeleteModel(APanamahModel: IPanamahModel; AAssinanteId: Variant); overload;

    property OnCurrentBatchExpired: TPanamahBatchEvent read GetOnCurrentBatchExpired write SetOnCurrentBatchExpired;
    property OnBeforeObjectAddedToBatch: TPanamahModelEvent read GetOnBeforeObjectAddedToBatch write SetOnBeforeObjectAddedToBatch;
    property OnBeforeBatchSent: TPanamahBatchEvent read GetOnBeforeBatchSent write SetOnBeforeBatchSent;
    property OnBeforeOperationSent: TPanamahOperationEvent read GetOnBeforeOperationtSent write SetOnBeforeOperationSent;
    property OnBeforeSave: TPanamahCancelableModelEvent read GetOnBeforeSave write SetOnBeforeSave;
    property OnBeforeDelete: TPanamahCancelableModelEvent read GetOnBeforeDelete write SetOnBeforeDelete;
    property OnError: TPanamahErrorEvent read GetOnError write SetOnError;
    property OnAfterSave: TPanamahModelEvent read GetOnAfterSave write SetOnAfterSave;
    property OnAfterDelete: TPanamahModelEvent read GetOnAfterDelete write SetOnAfterDelete;
    property OnAfterSaveSync: TPanamahModelEvent read GetOnAfterSaveSync write SetOnAfterSaveSync;
    property OnAfterDeleteSync: TPanamahModelEvent read GetOnAfterDeleteSync write SetOnAfterDeleteSync;
  end;

var
  _PanamahStreamInstance: TPanamahStream;
  _PanamahAdminInstance: TPanamahAdmin;

implementation

uses
  PanamahSDK.ValidationUtils, PanamahSDK.Log;

{ TPanamahStream }

procedure TPanamahStream.Init(AConfig: IPanamahStreamConfig);
begin
  FConfig := AConfig;
  if {$IFDEF UNICODE}not FProcessor.Started{$ELSE}FProcessor.Suspended{$ENDIF} then
    FProcessor.Start(FConfig);
end;

procedure TPanamahStream.Init(const AAuthorizationToken, ASecret, AAssinanteId: string);
var
  Config: IPanamahStreamConfig;
begin
  TPanamahLogger.Log('PanamahStream init');
  Config := TPanamahStreamConfig.Create;
  Config.AssinanteId := AAssinanteId;
  Config.Secret := ASecret;
  Config.AuthorizationToken := AAuthorizationToken;
  Init(Config);
end;

procedure TPanamahStream.Init(const AAuthorizationToken, ASecret: string);
begin
  Init(AAuthorizationToken, ASecret, '*');
end;

function TPanamahStream.ReadNFe(ADocumentType: TPanamahNFeDocumentType; const AFilename: string): IPanamahNFeDocument;
begin
  Result := TPanamahNFeDocument.FromFile(ADocumentType, AFilename);
end;

function TPanamahStream.ReadNFeDirectory(const ADirectory: string): IPanamahNFeDocumentList;
begin
  Result := TPanamahNFeDocumentList.Create;
  Result.LoadFromDirectory(ADirectory);
end;

function TPanamahStream.ReadNFe(const AFilename: string): IPanamahNFeDocument;
begin
  Result := ReadNFe(ndtDESCONHECIDO, AFilename);
end;

procedure TPanamahStream.Init;
begin
  Init(GetEnvironmentVariable('PANAMAH_AUTHORIZATION_TOKEN'), GetEnvironmentVariable('PANAMAH_SECRET'), GetEnvironmentVariable('PANAMAH_ASSINANTE_ID'));
end;

procedure TPanamahStream.SetOnAfterDelete(AEvent: TPanamahModelEvent);
begin
  FProcessor.OnAfterDelete := AEvent;
end;

procedure TPanamahStream.SetOnAfterDeleteSync(AEvent: TPanamahModelEvent);
begin
  FProcessor.OnAfterDeleteSync := AEvent;
end;

procedure TPanamahStream.SetOnAfterSave(AEvent: TPanamahModelEvent);
begin
  FProcessor.OnAfterSave := AEvent;
end;

procedure TPanamahStream.SetOnAfterSaveSync(AEvent: TPanamahModelEvent);
begin
  FProcessor.OnAfterSaveSync := AEvent;
end;

procedure TPanamahStream.SetOnBeforeBatchSent(AEvent: TPanamahBatchEvent);
begin
  FProcessor.OnBeforeBatchSent := AEvent;
end;

procedure TPanamahStream.SetOnBeforeDelete(
  AEvent: TPanamahCancelableModelEvent);
begin
  FProcessor.OnBeforeDelete := AEvent;
end;

procedure TPanamahStream.SetOnBeforeObjectAddedToBatch(AEvent: TPanamahModelEvent);
begin
  FProcessor.OnBeforeObjectAddedToBatch := AEvent;
end;

procedure TPanamahStream.SetOnBeforeOperationSent(AEvent: TPanamahOperationEvent);
begin
  FProcessor.OnBeforeOperationSent := AEvent;
end;

procedure TPanamahStream.SetOnBeforeSave(AEvent: TPanamahCancelableModelEvent);
begin
  FProcessor.OnBeforeSave := AEvent;
end;

procedure TPanamahStream.SetOnCurrentBatchExpired(AEvent: TPanamahBatchEvent);
begin
  FProcessor.OnCurrentBatchExpired := AEvent;
end;

procedure TPanamahStream.SetOnError(AEvent: TPanamahErrorEvent);
begin
  FProcessor.OnError := AEvent;
end;

procedure TPanamahStream.Save(AFormaPagamento: IPanamahFormaPagamento; AAssinanteId: Variant);
begin
  FProcessor.Save(AFormaPagamento, AAssinanteId);
end;

procedure TPanamahStream.Save(AEventoCaixa: IPanamahEventoCaixa; AAssinanteId: Variant);
begin
  FProcessor.Save(AEventoCaixa, AAssinanteId);
end;

procedure TPanamahStream.Save(AEstoqueMovimentacao: IPanamahEstoqueMovimentacao; AAssinanteId: Variant);
begin
  FProcessor.Save(AEstoqueMovimentacao, AAssinanteId);
end;

procedure TPanamahStream.Save(AGrupo: IPanamahGrupo; AAssinanteId: Variant);
begin
  FProcessor.Save(AGrupo, AAssinanteId);
end;

procedure TPanamahStream.Save(AFuncionario: IPanamahFuncionario; AAssinanteId: Variant);
begin
  FProcessor.Save(AFuncionario, AAssinanteId);
end;

procedure TPanamahStream.Save(AFornecedor: IPanamahFornecedor; AAssinanteId: Variant);
begin
  FProcessor.Save(AFornecedor, AAssinanteId);
end;

procedure TPanamahStream.Save(AAcesso: IPanamahAcesso; AAssinanteId: Variant);
begin
  FProcessor.Save(AAcesso, AAssinanteId);
end;

procedure TPanamahStream.Save(AEan: IPanamahEan; AAssinanteId: Variant);
begin
  FProcessor.Save(AEan, AAssinanteId);
end;

procedure TPanamahStream.Save(ACompra: IPanamahCompra; AAssinanteId: Variant);
begin
  FProcessor.Save(ACompra, AAssinanteId);
end;

procedure TPanamahStream.Save(ACliente: IPanamahCliente; AAssinanteId: Variant);
begin
  FProcessor.Save(ACliente, AAssinanteId);
end;

procedure TPanamahStream.Save(AHolding: IPanamahHolding; AAssinanteId: Variant);
begin
  FProcessor.Save(AHolding, AAssinanteId);
end;

procedure TPanamahStream.Save(ATituloReceber: IPanamahTituloReceber; AAssinanteId: Variant);
begin
  FProcessor.Save(ATituloReceber, AAssinanteId);
end;

procedure TPanamahStream.Save(ATituloPagar: IPanamahTituloPagar; AAssinanteId: Variant);
begin
  FProcessor.Save(ATituloPagar, AAssinanteId);
end;

procedure TPanamahStream.Save(ASubgrupo: IPanamahSubgrupo; AAssinanteId: Variant);
begin
  FProcessor.Save(ASubgrupo, AAssinanteId);
end;

procedure TPanamahStream.Save(AVenda: IPanamahVenda; AAssinanteId: Variant);
begin
  FProcessor.Save(AVenda, AAssinanteId);
end;

procedure TPanamahStream.Save(ANFeDocumentList: IPanamahNFeDocumentList; AAssinanteId: Variant);
var
  I: Integer;
begin
  for I := 0 to ANFeDocumentList.Count - 1 do
    Save(ANFeDocumentList[I], AAssinanteId);
end;

procedure TPanamahStream.Save(ANFeDocument: IPanamahNFeDocument; AAssinanteId: Variant);
var
  I: Integer;
begin
  for I := 0 to ANFeDocument.Count - 1 do
    FProcessor.Save(ANFeDocument[I], AAssinanteId);
end;

procedure TPanamahStream.Save(ATrocaFormaPagamento: IPanamahTrocaFormaPagamento; AAssinanteId: Variant);
begin
  FProcessor.Save(ATrocaFormaPagamento, AAssinanteId);
end;

procedure TPanamahStream.Save(ATrocaDevolucao: IPanamahTrocaDevolucao; AAssinanteId: Variant);
begin
  FProcessor.Save(ATrocaDevolucao, AAssinanteId);
end;

procedure TPanamahStream.Save(AMeta: IPanamahMeta; AAssinanteId: Variant);
begin
  FProcessor.Save(AMeta, AAssinanteId);
end;

procedure TPanamahStream.Save(ALoja: IPanamahLoja; AAssinanteId: Variant);
begin
  FProcessor.Save(ALoja, AAssinanteId);
end;

procedure TPanamahStream.Save(ALocalEstoque: IPanamahLocalEstoque; AAssinanteId: Variant);
begin
  FProcessor.Save(ALocalEstoque, AAssinanteId);
end;

procedure TPanamahStream.Save(ASecao: IPanamahSecao; AAssinanteId: Variant);
begin
  FProcessor.Save(ASecao, AAssinanteId);
end;

procedure TPanamahStream.Save(ARevenda: IPanamahRevenda; AAssinanteId: Variant);
begin
  FProcessor.Save(ARevenda, AAssinanteId);
end;

procedure TPanamahStream.Save(AProduto: IPanamahProduto; AAssinanteId: Variant);
begin
  FProcessor.Save(AProduto, AAssinanteId);
end;

procedure TPanamahStream.Delete(AFormaPagamento: IPanamahFormaPagamento; AAssinanteId: Variant);
begin
  FProcessor.Delete(AFormaPagamento, AAssinanteId);
end;

procedure TPanamahStream.Delete(AEventoCaixa: IPanamahEventoCaixa; AAssinanteId: Variant);
begin
  FProcessor.Delete(AEventoCaixa, AAssinanteId);
end;

procedure TPanamahStream.Delete(AEstoqueMovimentacao: IPanamahEstoqueMovimentacao; AAssinanteId: Variant);
begin
  FProcessor.Delete(AEstoqueMovimentacao, AAssinanteId);
end;

procedure TPanamahStream.Delete(AGrupo: IPanamahGrupo; AAssinanteId: Variant);
begin
  FProcessor.Delete(AGrupo, AAssinanteId);
end;

procedure TPanamahStream.Delete(AFuncionario: IPanamahFuncionario; AAssinanteId: Variant);
begin
  FProcessor.Delete(AFuncionario, AAssinanteId);
end;

procedure TPanamahStream.Delete(AFornecedor: IPanamahFornecedor; AAssinanteId: Variant);
begin
  FProcessor.Delete(AFornecedor, AAssinanteId);
end;

procedure TPanamahStream.Delete(AAcesso: IPanamahAcesso; AAssinanteId: Variant);
begin
  FProcessor.Delete(AAcesso, AAssinanteId);
end;

procedure TPanamahStream.Delete(AEan: IPanamahEan; AAssinanteId: Variant);
begin
  FProcessor.Delete(AEan, AAssinanteId);
end;

procedure TPanamahStream.Delete(ACompra: IPanamahCompra; AAssinanteId: Variant);
begin
  FProcessor.Delete(ACompra, AAssinanteId);
end;

procedure TPanamahStream.Delete(ACliente: IPanamahCliente; AAssinanteId: Variant);
begin
  FProcessor.Delete(ACliente, AAssinanteId);
end;

procedure TPanamahStream.Delete(AHolding: IPanamahHolding; AAssinanteId: Variant);
begin
  FProcessor.Delete(AHolding, AAssinanteId);
end;

procedure TPanamahStream.Delete(ATituloReceber: IPanamahTituloReceber; AAssinanteId: Variant);
begin
  FProcessor.Delete(ATituloReceber, AAssinanteId);
end;

procedure TPanamahStream.Delete(ATituloPagar: IPanamahTituloPagar; AAssinanteId: Variant);
begin
  FProcessor.Delete(ATituloPagar, AAssinanteId);
end;

procedure TPanamahStream.Delete(ASubgrupo: IPanamahSubgrupo; AAssinanteId: Variant);
begin
  FProcessor.Delete(ASubgrupo, AAssinanteId);
end;

procedure TPanamahStream.Delete(AVenda: IPanamahVenda; AAssinanteId: Variant);
begin
  FProcessor.Delete(AVenda, AAssinanteId);
end;

procedure TPanamahStream.Delete(ATrocaFormaPagamento: IPanamahTrocaFormaPagamento; AAssinanteId: Variant);
begin
  FProcessor.Delete(ATrocaFormaPagamento, AAssinanteId);
end;

procedure TPanamahStream.Delete(ATrocaDevolucao: IPanamahTrocaDevolucao; AAssinanteId: Variant);
begin
  FProcessor.Delete(ATrocaDevolucao, AAssinanteId);
end;

procedure TPanamahStream.Delete(AMeta: IPanamahMeta; AAssinanteId: Variant);
begin
  FProcessor.Delete(AMeta, AAssinanteId);
end;

procedure TPanamahStream.Delete(ALoja: IPanamahLoja; AAssinanteId: Variant);
begin
  FProcessor.Delete(ALoja, AAssinanteId);
end;

procedure TPanamahStream.Delete(ALocalEstoque: IPanamahLocalEstoque; AAssinanteId: Variant);
begin
  FProcessor.Delete(ALocalEstoque, AAssinanteId);
end;

procedure TPanamahStream.Delete(ASecao: IPanamahSecao; AAssinanteId: Variant);
begin
  FProcessor.Delete(ASecao, AAssinanteId);
end;

procedure TPanamahStream.Delete(ARevenda: IPanamahRevenda; AAssinanteId: Variant);
begin
  FProcessor.Delete(ARevenda, AAssinanteId);
end;

procedure TPanamahStream.Delete(AProduto: IPanamahProduto; AAssinanteId: Variant);
begin
  FProcessor.Delete(AProduto, AAssinanteId);
end;

procedure TPanamahStream.Save(ANFeDocumentList: IPanamahNFeDocumentList);
begin
  Save(ANFeDocumentList, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ANFeDocument: IPanamahNFeDocument);
begin
  Save(ANFeDocument, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AAcesso: IPanamahAcesso);
begin
  Save(AAcesso, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ACliente: IPanamahCliente);
begin
  Save(ACliente, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ACompra: IPanamahCompra);
begin
  Save(ACompra, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AEan: IPanamahEan);
begin
  Save(AEan, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AEstoqueMovimentacao: IPanamahEstoqueMovimentacao);
begin
  Save(AEstoqueMovimentacao, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AEventoCaixa: IPanamahEventoCaixa);
begin
  Save(AEventoCaixa, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AFormaPagamento: IPanamahFormaPagamento);
begin
  Save(AFormaPagamento, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AFornecedor: IPanamahFornecedor);
begin
  Save(AFornecedor, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AFuncionario: IPanamahFuncionario);
begin
  Save(AFuncionario, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AGrupo: IPanamahGrupo);
begin
  Save(AGrupo, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AHolding: IPanamahHolding);
begin
  Save(AHolding, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ALocalEstoque: IPanamahLocalEstoque);
begin
  Save(ALocalEstoque, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ALoja: IPanamahLoja);
begin
  Save(ALoja, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AMeta: IPanamahMeta);
begin
  Save(AMeta, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AProduto: IPanamahProduto);
begin
  Save(AProduto, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ARevenda: IPanamahRevenda);
begin
  Save(ARevenda, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ASecao: IPanamahSecao);
begin
  Save(ASecao, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ASubgrupo: IPanamahSubgrupo);
begin
  Save(ASubgrupo, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ATituloPagar: IPanamahTituloPagar);
begin
  Save(ATituloPagar, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ATituloReceber: IPanamahTituloReceber);
begin
  Save(ATituloReceber, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ATrocaDevolucao: IPanamahTrocaDevolucao);
begin
  Save(ATrocaDevolucao, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(ATrocaFormaPagamento: IPanamahTrocaFormaPagamento);
begin
  Save(ATrocaFormaPagamento, FConfig.AssinanteId);
end;

procedure TPanamahStream.Save(AVenda: IPanamahVenda);
begin
  Save(AVenda, FConfig.AssinanteId);
end;

procedure TPanamahStream.SaveModel(APanamahModel: IPanamahModel; AAssinanteId: Variant);
begin
  FProcessor.Save(APanamahModel, AAssinanteId);
end;

procedure TPanamahStream.SaveModel(APanamahModel: IPanamahModel);
begin
  SaveModel(APanamahModel, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AAcesso: IPanamahAcesso);
begin
  Delete(AAcesso, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(ACliente: IPanamahCliente);
begin
  Delete(ACliente, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(ACompra: IPanamahCompra);
begin
  Delete(ACompra, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AEan: IPanamahEan);
begin
  Delete(AEan, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AEstoqueMovimentacao: IPanamahEstoqueMovimentacao);
begin
  Delete(AEstoqueMovimentacao, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AEventoCaixa: IPanamahEventoCaixa);
begin
  Delete(AEventoCaixa, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AFormaPagamento: IPanamahFormaPagamento);
begin
  Delete(AFormaPagamento, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AFornecedor: IPanamahFornecedor);
begin
  Delete(AFornecedor, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AFuncionario: IPanamahFuncionario);
begin
  Delete(AFuncionario, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AGrupo: IPanamahGrupo);
begin
  Delete(AGrupo, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AHolding: IPanamahHolding);
begin
  Delete(AHolding, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(ALocalEstoque: IPanamahLocalEstoque);
begin
  Delete(ALocalEstoque, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(ALoja: IPanamahLoja);
begin
  Delete(ALoja, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AMeta: IPanamahMeta);
begin
  Delete(AMeta, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AProduto: IPanamahProduto);
begin
  Delete(AProduto, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(ARevenda: IPanamahRevenda);
begin
  Delete(ARevenda, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(ASecao: IPanamahSecao);
begin
  Delete(ASecao, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(ASubgrupo: IPanamahSubgrupo);
begin
  Delete(ASubgrupo, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(ATituloPagar: IPanamahTituloPagar);
begin
  Delete(ATituloPagar, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(ATituloReceber: IPanamahTituloReceber);
begin
  Delete(ATituloReceber, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(ATrocaDevolucao: IPanamahTrocaDevolucao);
begin
  Delete(ATrocaDevolucao, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(ATrocaFormaPagamento: IPanamahTrocaFormaPagamento);
begin
  Delete(ATrocaFormaPagamento, FConfig.AssinanteId);
end;

procedure TPanamahStream.Delete(AVenda: IPanamahVenda);
begin
  Delete(AVenda, FConfig.AssinanteId);
end;

procedure TPanamahStream.DeleteModel(APanamahModel: IPanamahModel; AAssinanteId: Variant);
begin
  FProcessor.Delete(APanamahModel, AAssinanteId);
end;

procedure TPanamahStream.DeleteModel(APanamahModel: IPanamahModel);
begin
  DeleteModel(APanamahModel, FConfig.AssinanteId);
end;

constructor TPanamahStream.Create;
begin
  inherited;
  FProcessor := TPanamahBatchProcessor.Create;
end;

destructor TPanamahStream.Destroy;
begin
  FProcessor.Stop;
  FProcessor.Free;
  inherited;
end;

procedure TPanamahStream.Flush;
begin
  FProcessor.Flush;
end;

class procedure TPanamahStream.Free;
begin
  if Assigned(_PanamahStreamInstance) then
    _PanamahStreamInstance.Destroy;
end;

class function TPanamahStream.GetInstance: TPanamahStream;
begin
  if not Assigned(_PanamahStreamInstance) then
    _PanamahStreamInstance := TPanamahStream.Create;
  Result := _PanamahStreamInstance;
end;

function TPanamahStream.GetOnAfterDelete: TPanamahModelEvent;
begin
  Result := FProcessor.OnAfterDelete;
end;

function TPanamahStream.GetOnAfterDeleteSync: TPanamahModelEvent;
begin
  Result := FProcessor.OnAfterDeleteSync;
end;

function TPanamahStream.GetOnAfterSave: TPanamahModelEvent;
begin
  Result := FProcessor.OnAfterSave;
end;

function TPanamahStream.GetOnAfterSaveSync: TPanamahModelEvent;
begin
  Result := FProcessor.OnAfterSaveSync;
end;

function TPanamahStream.GetOnBeforeBatchSent: TPanamahBatchEvent;
begin
  Result := FProcessor.OnBeforeBatchSent;
end;

function TPanamahStream.GetOnBeforeDelete: TPanamahCancelableModelEvent;
begin
  Result := FProcessor.OnBeforeDelete;
end;

function TPanamahStream.GetOnBeforeObjectAddedToBatch: TPanamahModelEvent;
begin
  Result := FProcessor.OnBeforeObjectAddedToBatch;
end;

function TPanamahStream.GetOnBeforeOperationtSent: TPanamahOperationEvent;
begin
  Result := FProcessor.OnBeforeOperationSent;
end;

function TPanamahStream.GetOnBeforeSave: TPanamahCancelableModelEvent;
begin
  Result := FProcessor.OnBeforeSave;
end;

function TPanamahStream.GetOnCurrentBatchExpired: TPanamahBatchEvent;
begin
  Result := FProcessor.OnCurrentBatchExpired;
end;

function TPanamahStream.GetOnError: TPanamahErrorEvent;
begin
  Result := FProcessor.OnError;
end;

function TPanamahStream.GetPendingResources: IPanamahPendingResourcesList;
begin
  Result := FProcessor.GetPendingResources;
end;

{ TPanamahSDKConfig }

constructor TPanamahStreamConfig.Create;
begin
  inherited Create;
  FBatchTTL := 5 * 60 * 1000;
  FBatchMaxSize := 3 * 1024;
  FBatchMaxCount := 300;
  FBaseDirectory := GetCurrentDir + '\.panamah';
end;

function TPanamahStreamConfig.GetAssinanteId: string;
begin
  Result := FAssinanteId;
end;

function TPanamahStreamConfig.GetAuthorizationToken: string;
begin
  Result := FAuthorizationToken;
end;

function TPanamahStreamConfig.GetBaseDirectory: string;
begin
  Result := FBaseDirectory;
end;

function TPanamahStreamConfig.GetBatchMaxCount: Integer;
begin
  Result := FBatchMaxCount;
end;

function TPanamahStreamConfig.GetBatchMaxSize: Integer;
begin
  Result := FBatchMaxSize;
end;

function TPanamahStreamConfig.GetBatchTTL: Integer;
begin
  Result := FBatchTTL;
end;

function TPanamahStreamConfig.GetSecret: string;
begin
  Result := FSecret;
end;

procedure TPanamahStreamConfig.SetBaseDirectory(const ABaseDirectory: string);
begin
  FBaseDirectory := ABaseDirectory;
end;

procedure TPanamahStreamConfig.SetSecret(const ASecret: string);
begin
  FSecret := ASecret;
end;

procedure TPanamahStreamConfig.SetAssinanteId(const AAssinanteId: string);
begin
  FAssinanteId := AAssinanteId;
end;

procedure TPanamahStreamConfig.SetAuthorizationToken(const AAuthorizationToken: string);
begin
  FAuthorizationToken := AAuthorizationToken;
end;

{ TPanamahAdminConfig }

constructor TPanamahAdminConfig.Create;
begin
  inherited Create;
end;

function TPanamahAdminConfig.GetAuthorizationToken: string;
begin
  Result := FAuthorizationToken;
end;

procedure TPanamahAdminConfig.SetAuthorizationToken(const AAuthorizationToken: string);
begin
  FAuthorizationToken := AAuthorizationToken;
end;

{ TPanamahAdmin }

constructor TPanamahAdmin.Create;
begin
  inherited Create;
end;

class procedure TPanamahAdmin.Free;
begin
  if Assigned(_PanamahAdminInstance) then
    FreeAndNil(_PanamahAdminInstance);
end;

function TPanamahAdmin.GenerateKey(const AAssinanteId: string): string;
var
  RawResponse: IPanamahResponse;
  Response: IPanamahKeyResponse;
begin
  TPanamahLogger.Log(Format('Generating assinante %s key', [AAssinanteId]));
  RawResponse := FClient.Post(Format('/admin/assinantes/%s/key/generate', [AAssinanteId]), '', nil);
  TPanamahLogger.Log(Format('Assinante generate key response returned %d', [RawResponse.Status]));
  case RawResponse.Status of
    200:
    begin
      Response := TPanamahKeyResponse.FromJSON(RawResponse.Content);
      Result := Response.Chave;
    end;
    404: raise EPanamahSDKNotFoundException.Create('Assinante não encontrado');
    else
      raise EPanamahSDKUnknownException.Create(RawResponse.Content);
  end;
end;

function TPanamahAdmin.ResetKey(const AAssinanteId, AOldKey: string): string;
var
  RawResponse: IPanamahResponse;
  Response: IPanamahKeyResponse;
begin
  TPanamahLogger.Log(Format('Resetting assinante %s key', [AAssinanteId]));
  RawResponse := FClient.Post(Format('/admin/assinantes/%s/key/reset', [AAssinanteId]), Format('{"chave": "%s"}', [AOldKey]), nil);
  TPanamahLogger.Log(Format('Assinante reset key response returned %d', [RawResponse.Status]));
  case RawResponse.Status of
    200:
    begin
      Response := TPanamahKeyResponse.FromJSON(RawResponse.Content);
      Result := Response.Chave;
    end;
    404: raise EPanamahSDKNotFoundException.Create('Assinante não encontrado');
    else
      raise EPanamahSDKUnknownException.Create(RawResponse.Content);
  end;
end;

function TPanamahAdmin.GetAssinante(const AAssinanteId: string): IPanamahAssinante;
var
  Response: IPanamahResponse;
begin
  TPanamahLogger.Log(Format('Getting assinante %s', [AAssinanteId]));
  Response := FClient.Get(Format('/admin/assinantes/%s', [AAssinanteId]), nil, nil);
  TPanamahLogger.Log(Format('Assinante get response returned %d', [Response.Status]));
  case Response.Status of
    200: Result := TPanamahAssinante.FromJSON(Response.Content);
    404: raise EPanamahSDKNotFoundException.Create('Assinante não encontrado');
    else
      raise EPanamahSDKUnknownException.Create(Response.Content);
  end;
end;

function TPanamahAdmin.SaveAssinante(AAssinante: IPanamahAssinante): Boolean;

  function IsSuccessful(AResponse: IPanamahResponse): Boolean;
  begin
    case AResponse.Status of
      200, 201: Result := True;
      422: raise EPanamahSDKUnprocessableEntityException.Create(AResponse.Content);
      400: raise EPanamahSDKBadRequestException.Create(AResponse.Content);
      409: raise EPanamahSDKConflictException.Create(AResponse.Content);
      else
        Result := False;
    end;
  end;

var
  PostResponse, PutResponse: IPanamahResponse;
begin
  Result := True;
  TPanamahLogger.Log(Format('Updating assinante %s', [AAssinante.Id]));
  PutResponse := FClient.Put(Format('/admin/assinantes/%s', [AAssinante.Id]), AAssinante.SerializeToJSON, nil);
  TPanamahLogger.Log(Format('Assinante update response returned %d', [PutResponse.Status]));
  if not IsSuccessful(PutResponse) then
  begin
    TPanamahLogger.Log('Assinante not found, creating...');
    PostResponse := FClient.Post('/admin/assinantes', AAssinante.SerializeToJSON, nil);
    TPanamahLogger.Log(Format('Assinante create response returned %d', [PostResponse.Status]));
    Result := IsSuccessful(PostResponse);
  end;
end;

class function TPanamahAdmin.GetInstance: TPanamahAdmin;
begin
  if not Assigned(_PanamahAdminInstance) then
    _PanamahAdminInstance := TPanamahAdmin.Create;
  Result := _PanamahAdminInstance;
end;

procedure TPanamahAdmin.Init(const AAuthorizationToken: string);
var
  Config: IPanamahAdminConfig;
begin
  TPanamahLogger.Log('PanamahAdmin init');
  Config := TPanamahAdminConfig.Create;
  Config.AuthorizationToken := AAuthorizationToken;
  Init(Config);
end;

procedure TPanamahAdmin.Init(AConfig: IPanamahAdminConfig);
begin
  TPanamahLogger.Log('PanamahAdmin init');
  FConfig := AConfig;
  FClient := TPanamahAdminClient.Create(API_BASE_URL, FConfig.AuthorizationToken);
end;

initialization
  TPanamahStream.GetInstance;
  TPanamahAdmin.GetInstance;

finalization
  TPanamahStream.Free;
  TPanamahAdmin.Free;

end.

