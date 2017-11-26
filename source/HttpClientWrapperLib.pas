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

  IHttpClientWrapper = interface
    function getOnResponse: TOnHTTPClientResponse;
    procedure SetOnResponse(const value: TOnHTTPClientResponse);

    function Get(url: String): IHTTPClientResponse;overload;
    function Get(url: String; out response: String): IHTTPClientResponse;overload;

    function Post(url: String; ContentType: String; postData: TStream): IHTTPClientResponse;

    property OnResponse: TOnHTTPClientResponse read getOnResponse write SetOnResponse;
  end;

  THTTPClientResponse = class(TInterfacedObject, IHTTPClientResponse)
  private
    FStatusCode: Integer;
    FContent: String;
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
    property Content: String read getContent write FContent;
    property ContentStream: TStream read getContentStream;
  end;

  TCreateHttpClient = reference to function:IHttpClientWrapper;

  THttpClientWrapper = class(TObject)
  private
    class var FCreateFunction: TCreateHttpClient;
  public
    class procedure RegisterClient(clientCreator: TCreateHttpClient);
  private
    FOnResponse: TOnHTTPClientResponse;
  public
    function Get(url: String): IHTTPClientResponse;overload;
    function Get(url: String; out response: String): IHTTPClientResponse;overload;

    function Post(url: String; ContentType: String; postData: TStream): IHTTPClientResponse;

    procedure AsyncGet(url: String);
    procedure AsyncPost(url: String; ContentType: String; postData: TStream);

    property OnResponse: TOnHTTPClientResponse read FOnResponse write FOnResponse;
  end;

implementation

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
begin
  Result := FContent;
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
var
  client: IHttpClientWrapper;
begin
  Assert(Assigned(FCreateFunction), 'Es wurde kein Wrapper zugewiesen');
  client := FCreateFunction;
  Result := client.Get(url);
end;

procedure THttpClientWrapper.AsyncGet(url: String);
begin
  Assert(Assigned(FCreateFunction), 'Es wurde kein Wrapper zugewiesen');
  TThread.CreateAnonymousThread(
    procedure
    var
      client: IHttpClientWrapper;
      resp: IHTTPClientResponse;
    begin
      client := FCreateFunction;
      resp := client.Get(url);
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
  Assert(Assigned(FCreateFunction), 'Es wurde kein Wrapper zugewiesen');
  TThread.CreateAnonymousThread(
    procedure
    var
      client: IHttpClientWrapper;
      resp: IHTTPClientResponse;
    begin
      client := FCreateFunction;
      resp := client.Post(url, ContentType, postData);
      TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin
        if Assigned(OnResponse) then OnResponse(resp);
        Self.Free;
      end);
    end).Start;
end;

function THttpClientWrapper.Get(url: String;
  out response: String): IHTTPClientResponse;
var
  client: IHttpClientWrapper;
begin
  Assert(Assigned(FCreateFunction), 'Es wurde kein Wrapper zugewiesen');
  client := FCreateFunction;
  Result := client.Get(url, response);
end;

function THttpClientWrapper.Post(url: String;
  ContentType: String; postData: TStream): IHTTPClientResponse;
var
  client: IHttpClientWrapper;
begin
  Assert(Assigned(FCreateFunction), 'Es wurde kein Wrapper zugewiesen');
  client := FCreateFunction;
  Result := client.Post(url, ContentType, postData);
end;

class procedure THttpClientWrapper.RegisterClient(clientCreator: TCreateHttpClient);
begin
  FCreateFunction := clientCreator;
end;

initialization
finalization
  THttpClientWrapper.FCreateFunction := nil;

end.
