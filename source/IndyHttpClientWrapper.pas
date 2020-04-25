unit IndyHttpClientWrapper;

interface

uses
  HttpClientWrapperLib, IdHTTP, System.Classes, IdSSLOpenSSL;

type
  TIndyClientResponse = class(TInterfacedObject, IHTTPClientResponse)
  private
    FStatusCode: Integer;
    FContentStream: TMemoryStream;
    FContent: String;
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

  TIndyHttpClientWrapper = class(TInterfacedObject, IHttpClientWrapper)
  private
    procedure InitSSL(sslIOHandler: TIdSSLIOHandlerSocketOpenSSL);
  public
    function Get(url: String): IHTTPClientResponse;overload;
    function Get(url: String; out response: String): IHTTPClientResponse;overload;
    function Get(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;overload;

    function Post(url: String; ContentType: String; postData: TStream): IHTTPClientResponse;overload;
    function Post(url: String; ContentType: String; postData: TStream; header: TArray<THttpHeader>): IHTTPClientResponse;overload;
    function Post(url: String; ContentType: String; postData: TStrings; header: TArray<THttpHeader>): IHTTPClientResponse;overload;

    function Put(url: String; ContentType: String; postData: TStream; header: TArray<THttpHeader>): IHTTPClientResponse;

    function Delete(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;
  end;

implementation

uses
  IdGlobalProtocols, IdMultipartFormData;

{ TIndyHttpClientWrapper }

function TIndyHttpClientWrapper.Get(url: String): IHTTPClientResponse;
var
  respStream: TMemoryStream;
  respText: string;
  http: TIdHTTP;
  ioHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  http := TIdHTTP.Create;
  Result := TIndyClientResponse.Create;
  ioHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  http.IOHandler := ioHandler;
  InitSSL(ioHandler);
  respStream := TMemoryStream.Create;
  try
    http.Get(url, respStream);
    respStream.Position := 0;
    respText := ReadStringAsCharset(respStream, http.Response.CharSet);
    TIndyClientResponse(Result).FContent := respText;
    TIndyClientResponse(Result).LoadContentStream(respStream);
    TIndyClientResponse(Result).StatusCode := http.ResponseCode;
  except
    on E: EIdHTTPProtocolException do
    begin
      TIndyClientResponse(Result).StatusCode := E.ErrorCode;
    end;
  end;
  http.Free;
  ioHandler.Free;
  respStream.Free;
end;

function TIndyHttpClientWrapper.Get(url: String; out response: String): IHTTPClientResponse;
var
  http: TIdHTTP;
  ioHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  http := TIdHTTP.Create;
  ioHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  http.IOHandler := ioHandler;
  InitSSL(ioHandler);
  Result := TIndyClientResponse.Create;
  try
    response := http.Get(url);
    TIndyClientResponse(Result).FContent := response;
    TIndyClientResponse(Result).StatusCode := http.ResponseCode;
  except
    on E: EIdHTTPProtocolException do
    begin
      TIndyClientResponse(Result).StatusCode := E.ErrorCode;
    end;
  end;
  http.Free;
  ioHandler.Free;
end;

function TIndyHttpClientWrapper.Post(url: String;
  ContentType: String; postData: TStream): IHTTPClientResponse;
var
  http: TIdHTTP;
  resp: string;
  ioHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := TIndyClientResponse.Create;
  http := TIdHTTP.Create;
  ioHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  http.IOHandler := ioHandler;
  InitSSL(ioHandler);
  http.Request.UserAgent := ' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36';
  try
    http.Request.ContentType := ContentType;

    resp := http.Post(url, postData);
    TIndyClientResponse(Result).FContent := resp;
  except
    on E: EIdHTTPProtocolException do
    begin
      TIndyClientResponse(Result).StatusCode := E.ErrorCode;
      TIndyClientResponse(Result).FContent := E.ErrorMessage;
    end;
  end;
  http.Free;
  ioHandler.Free;
end;

function TIndyHttpClientWrapper.Delete(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;
var
  http: TIdHTTP;
  ioHandler: TIdSSLIOHandlerSocketOpenSSL;
  h: THttpHeader;
begin
  Result := TIndyClientResponse.Create;
  http := TIdHTTP.Create;
  ioHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  http.IOHandler := ioHandler;
  InitSSL(ioHandler);

  try
    http.Request.UserAgent := ' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36';
    for h in header do
    begin
      http.Request.CustomHeaders.AddValue(h.key, h.value);
    end;

    try
      http.Delete(url);
      TIndyClientResponse(Result).StatusCode := http.ResponseCode;
    except
      on E: EIdHTTPProtocolException do
      begin
        TIndyClientResponse(Result).StatusCode := E.ErrorCode;
      end;
    end;
  finally
    http.Free;
    ioHandler.Free;
  end;
end;

function TIndyHttpClientWrapper.Get(url: String;
  header: TArray<THttpHeader>): IHTTPClientResponse;
var
  respStream: TMemoryStream;
  respText: string;
  http: TIdHTTP;
  h: THttpHeader;
  ioHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  http := TIdHTTP.Create;
  ioHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  http.IOHandler := ioHandler;
  InitSSL(ioHandler);
  Result := TIndyClientResponse.Create;
  respStream := TMemoryStream.Create;
  try
    for h in header do
    begin
      http.Request.CustomHeaders.AddValue(h.key, h.value);
    end;
    http.Get(url, respStream);
    respStream.Position := 0;
    respText := ReadStringAsCharset(respStream, http.Response.CharSet);
    TIndyClientResponse(Result).FContent := respText;
    TIndyClientResponse(Result).LoadContentStream(respStream);
    TIndyClientResponse(Result).StatusCode := http.ResponseCode;
  except
    on E: EIdHTTPProtocolException do
    begin
      TIndyClientResponse(Result).StatusCode := E.ErrorCode;
    end;
  end;
  http.Free;
  ioHandler.Free;
  respStream.Free;
end;

procedure TIndyHttpClientWrapper.InitSSL(
  sslIOHandler: TIdSSLIOHandlerSocketOpenSSL);
begin
  sslIOHandler.SSLOptions.Method := sslvTLSv1_2;
end;

function TIndyHttpClientWrapper.Post(url, ContentType: String;
  postData: TStrings; header: TArray<THttpHeader>): IHTTPClientResponse;
var
  http: TIdHTTP;
  h: THttpHeader;
  response: TMemoryStream;
  respText: string;
  ioHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  http := TIdHTTP.Create;
  Result := TIndyClientResponse.Create;
  ioHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  http.IOHandler := ioHandler;
  InitSSL(ioHandler);

  http.Request.UserAgent := ' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36';
  response := TMemoryStream.Create;
  try
    http.Request.ContentType := ContentType;
    for h in header do
    begin
      http.Request.CustomHeaders.AddValue(h.key, h.value);
    end;

    http.Post(url, postData, response);

    response.Position := 0;
    respText := ReadStringAsCharset(response, http.Response.CharSet);
    TIndyClientResponse(Result).FContent := respText;
    TIndyClientResponse(Result).LoadContentStream(response);
    TIndyClientResponse(Result).StatusCode := http.ResponseCode;
  except
    on E: EIdHTTPProtocolException do
    begin
      TIndyClientResponse(Result).StatusCode := E.ErrorCode;
    end;
  end;
  http.Free;
  response.Free;
  ioHandler.Free;
end;

function TIndyHttpClientWrapper.Put(url, ContentType: String; postData: TStream;
  header: TArray<THttpHeader>): IHTTPClientResponse;
var
  http: TIdHTTP;
  resp: string;
  h: THttpHeader;
  ioHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := TIndyClientResponse.Create;
  http := TIdHTTP.Create;
  ioHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  http.IOHandler := ioHandler;
  InitSSL(ioHandler);
  http.Request.UserAgent := ' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36';
  try
    http.Request.ContentType := ContentType;
    for h in header do
    begin
      http.Request.CustomHeaders.AddValue(h.key, h.value);
    end;

    resp := http.Put(url, postData);
    TIndyClientResponse(Result).FContent := resp;
    TIndyClientResponse(Result).StatusCode := http.ResponseCode;
  except
    on E: EIdHTTPProtocolException do
    begin
      TIndyClientResponse(Result).StatusCode := E.ErrorCode;
    end;
  end;
  http.Free;
  ioHandler.Free;
end;

function TIndyHttpClientWrapper.Post(url, ContentType: String;
  postData: TStream; header: TArray<THttpHeader>): IHTTPClientResponse;
var
  http: TIdHTTP;
  resp: string;
  h: THttpHeader;
  ioHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := TIndyClientResponse.Create;
  http := TIdHTTP.Create;
  ioHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  http.IOHandler := ioHandler;
  InitSSL(ioHandler);
  http.Request.UserAgent := ' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36';
  try
    http.Request.ContentType := ContentType;
    for h in header do
    begin
      http.Request.CustomHeaders.AddValue(h.key, h.value);
    end;

    resp := http.Post(url, postData);
    TIndyClientResponse(Result).FContent := resp;
    TIndyClientResponse(Result).StatusCode := http.ResponseCode;
  except
    on E: EIdHTTPProtocolException do
    begin
      TIndyClientResponse(Result).FContent := E.ErrorMessage;
      TIndyClientResponse(Result).StatusCode := E.ErrorCode;
    end;
  end;
  http.Free;
  ioHandler.Free;
end;

{ TIndyClientResponse }

constructor TIndyClientResponse.Create;
begin
  FContentStream := TMemoryStream.Create;
end;

destructor TIndyClientResponse.Destroy;
begin
  FContentStream.Free;
  inherited;
end;

function TIndyClientResponse.getContent: String;
begin
  Result := FContent;
end;

function TIndyClientResponse.getContentStream: TStream;
begin
  Result := FContentStream;
end;


function TIndyClientResponse.getStatusCode: Integer;
begin
  Result := FStatusCode;
end;


procedure TIndyClientResponse.LoadContentStream(stream: TStream);
begin
  stream.Position := 0;
  FContentStream.LoadFromStream(stream);
end;


procedure TIndyClientResponse.SaveContentStream(filename: String);
begin
  FContentStream.Position := 0;
  FContentStream.SaveToFile(filename);
end;

end.
