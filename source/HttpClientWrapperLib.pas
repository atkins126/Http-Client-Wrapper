unit HttpClientWrapperLib;

interface

uses
  System.Classes;

type
  IHTTPClientResponse = interface
    function getStatusCode: Integer;
    function getContent: String;
    function getContentStream: TStream;

    procedure SaveContentStream(filename: String);

    property StatusCode: Integer read getStatusCode;
    property Content: String read getContent;
    property ContentStream: TStream read getContentStream;
  end;

  TOnHTTPClientResponse = reference to procedure(response: IHTTPClientResponse);


  THttpHeader = record
    key: String;
    value: String;
    class function EmptyArray: TArray<THttpHeader>;static;
    class function SingleItem(key, value: String): TArray<THttpHeader>;static;
  end;


  IHttpClientWrapper = interface
    procedure SetBasicAuth(username, password: String);
    function Get(url: String): IHTTPClientResponse;overload;
    function Get(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;overload;
    function Get(url: String; out response: String): IHTTPClientResponse;overload;

    function Post(url: String; ContentType: String; postData: TStream): IHTTPClientResponse;overload;
    function Post(url: String; ContentType: String; postData: TStream; header: TArray<THttpHeader>): IHTTPClientResponse;overload;
    function Post(url: String; ContentType: String; postData: TStrings; header: TArray<THttpHeader>): IHTTPClientResponse;overload;

    function Put(url: String; ContentType: String; postData: TStream; header: TArray<THttpHeader>): IHTTPClientResponse;

    function Delete(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;
  end;

  IHttpClientFileDownload = interface
  ['{F83EEB18-7ECA-4D5F-855B-64DF633AD59B}']
    function DownloadFile(url: string; filename: String): Boolean;
  end;

  THTTPClientResponse = class(TInterfacedObject, IHTTPClientResponse)
  private
    FStatusCode: Integer;
    FContentStream: TMemoryStream;
    function getStatusCode: Integer;
    function getContent: String;
    function getContentStream: TStream;
  public
    constructor Create;
    destructor Destroy;override;
    procedure LoadContentStream(stream: TStream);
    procedure SaveContentStream(filename: String);

    property StatusCode: Integer read getStatusCode write FStatusCode;
    property Content: String read getContent;
    property ContentStream: TStream read getContentStream;
  end;

  THttpClientWrapper = class(TObject)
  private
    FClient: IHttpClientWrapper;
    FOnResponse: TOnHTTPClientResponse;
  public
    constructor Create(client: IHttpClientWrapper);
    procedure SetBasicAuth(username, password: String);

    function Get(url: String): IHTTPClientResponse;overload;
    function Get(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;overload;
    function Get(url: String; out response: String): IHTTPClientResponse;overload;

    function DownloadFile(url: string; filename: String): Boolean;

    function Post(url: String; ContentType: String; postData: TStream): IHTTPClientResponse;overload;
    function Post(url: String; ContentType: String; postData: TStream; header: TArray<THttpHeader>): IHTTPClientResponse;overload;
    function Post(url: String; ContentType: String; postData: TStrings; header: TArray<THttpHeader>): IHTTPClientResponse;overload;

    function Put(url: String; ContentType: String; postData: TStream; header: TArray<THttpHeader>): IHTTPClientResponse;

    function Delete(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;

    procedure AsyncGet(url: String);overload;
    procedure AsyncGet(url: String; header: TArray<THttpHeader>);overload;
    procedure AsyncPost(url: String; ContentType: String; postData: TStream);overload;
    procedure AsyncPost(url: String; ContentType: String; postData: TStream; header: TArray<THttpHeader>);overload;
    procedure AsyncPost(url: String; ContentType: String; postData: TStrings);overload;

    property OnResponse: TOnHTTPClientResponse read FOnResponse write FOnResponse;
  end;

implementation

uses
  System.SysUtils;

{ THTTPClientResponse }

constructor THTTPClientResponse.Create;
begin
  FContentStream := TMemoryStream.Create;
end;

destructor THTTPClientResponse.Destroy;
begin
  FContentStream.Free;
  inherited;
end;

function THTTPClientResponse.getContent: String;
var
  sStream: TStringStream;
begin
  sStream := TStringStream.Create('', TEncoding.UTF8);
  try
    sStream.LoadFromStream(ContentStream);
    Result := sStream.DataString;
  finally
    sStream.Free;
  end;
end;

function THTTPClientResponse.getContentStream: TStream;
begin
  Result := FContentStream;
end;

function THTTPClientResponse.getStatusCode: Integer;
begin
  Result := FStatusCode;
end;

procedure THTTPClientResponse.LoadContentStream(stream: TStream);
begin
  stream.Position := 0;
  FContentStream.LoadFromStream(stream);
end;

procedure THTTPClientResponse.SaveContentStream(filename: String);
begin
  FContentStream.Position := 0;
  FContentStream.SaveToFile(filename);
end;

{ THttpClientWrapper }

function THttpClientWrapper.Get(url: String): IHTTPClientResponse;
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  Result := FClient.Get(url);
end;

procedure THttpClientWrapper.AsyncGet(url: String);
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  TThread.CreateAnonymousThread(
    procedure
    var
      resp: IHTTPClientResponse;
    begin
      resp := FClient.Get(url);
      TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin
        if Assigned(OnResponse) then OnResponse(resp);
        Self.Free;
      end);
    end).Start;
end;

procedure THttpClientWrapper.AsyncPost(url, ContentType: String;
  postData: TStream);
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  TThread.CreateAnonymousThread(
    procedure
    var
      resp: IHTTPClientResponse;
    begin
      resp := FClient.Post(url, ContentType, postData);
      TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin
        if Assigned(OnResponse) then OnResponse(resp);
        Self.Free;
      end);
    end).Start;
end;

procedure THttpClientWrapper.AsyncGet(url: String; header: TArray<THttpHeader>);
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  TThread.CreateAnonymousThread(
    procedure
    var
      resp: IHTTPClientResponse;
    begin
      resp := FClient.Get(url, header);
      TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin
        if Assigned(OnResponse) then OnResponse(resp);
        Self.Free;
      end);
    end).Start;
end;

procedure THttpClientWrapper.AsyncPost(url, ContentType: String;
  postData: TStrings);
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  TThread.CreateAnonymousThread(
    procedure
    var
      resp: IHTTPClientResponse;
    begin
      resp := FClient.Post(url, ContentType, postData, THttpHeader.EmptyArray);
      TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin
        if Assigned(OnResponse) then OnResponse(resp);
        Self.Free;
      end);
    end).Start;
end;

procedure THttpClientWrapper.AsyncPost(url, ContentType: String;
  postData: TStream; header: TArray<THttpHeader>);
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  TThread.CreateAnonymousThread(
    procedure
    var
      resp: IHTTPClientResponse;
    begin
      resp := FClient.Post(url, ContentType, postData, header);
      TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin
        if Assigned(OnResponse) then OnResponse(resp);
        Self.Free;
      end);
    end).Start;
end;

constructor THttpClientWrapper.Create(client: IHttpClientWrapper);
begin
  FClient := client;
end;

function THttpClientWrapper.Delete(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  Result := FClient.Delete(url, header);
end;

function THttpClientWrapper.DownloadFile(url, filename: String): Boolean;
var
  downloadClient: IHttpClientFileDownload;
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  if Supports(FClient, IHttpClientFileDownload, downloadClient) then
  begin
    Result := downloadClient.DownloadFile(url, filename);
  end else
  begin
    raise ENotSupportedException.Create('Der Client unterstützt die Funktion "DownloadFile" nicht.');
  end;
end;

function THttpClientWrapper.Get(url: String;
  out response: String): IHTTPClientResponse;
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  Result := FClient.Get(url, response);
end;

function THttpClientWrapper.Post(url, ContentType: String; postData: TStrings;
  header: TArray<THttpHeader>): IHTTPClientResponse;
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  Result := FClient.Post(url, ContentType, postData, header);
end;

function THttpClientWrapper.Put(url, ContentType: String; postData: TStream;
  header: TArray<THttpHeader>): IHTTPClientResponse;
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  Result := FClient.Put(url, ContentType, postData, header);
end;

procedure THttpClientWrapper.SetBasicAuth(username, password: String);
begin
  FClient.SetBasicAuth(username, password);
end;

function THttpClientWrapper.Post(url, ContentType: String; postData: TStream;
  header: TArray<THttpHeader>): IHTTPClientResponse;
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  Result := FClient.Post(url, ContentType, postData, header);
end;

function THttpClientWrapper.Get(url: String;
  header: TArray<THttpHeader>): IHTTPClientResponse;
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  Result := FClient.Get(url, header);
end;

function THttpClientWrapper.Post(url: String;
  ContentType: String; postData: TStream): IHTTPClientResponse;
begin
  Assert(Assigned(FClient), 'Es wurde kein Wrapper zugewiesen');
  Result := FClient.Post(url, ContentType, postData);
end;

{ THttpHeader }

class function THttpHeader.EmptyArray: TArray<THttpHeader>;
begin
  SetLength(Result, 0);
end;

class function THttpHeader.SingleItem(key, value: String): TArray<THttpHeader>;
begin
  SetLength(Result, 1);
  Result[0].key := key;
  Result[0].value := value;
end;

end.
