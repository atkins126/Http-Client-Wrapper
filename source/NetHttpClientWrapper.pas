unit NetHttpClientWrapper;

interface

uses
  HttpClientWrapperLib, System.Classes, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TNetHttpClientWrapper = class(TInterfacedObject, IHttpClientWrapper)
  private
    function getHttpClient: TNetHttpClient;
    procedure ValidateServerCertificate(const Sender: TObject; const ARequest: TURLRequest; const Certificate: TCertificate; var Accepted: Boolean);
  public
    function Get(url: String): IHTTPClientResponse;overload;
    function Get(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;overload;
    function Get(url: String; out response: String): IHTTPClientResponse;overload;

    function Post(url: String; ContentType: String; postData: TStream): IHTTPClientResponse; overload;
    function Post(url: String; ContentType: String; postData: TStream; header: TArray<THttpHeader>): IHTTPClientResponse;overload;
    function Post(url: String; ContentType: String; postData: TStrings; header: TArray<THttpHeader>): IHTTPClientResponse;overload;

    function Put(url: String; ContentType: String; postData: TStream; header: TArray<THttpHeader>): IHTTPClientResponse;

    function Delete(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;
  end;

implementation

uses
  System.NetEncoding, System.SysUtils;

{ TIndyHttpClientWrapper }

function TNetHttpClientWrapper.Get(url: String): IHTTPClientResponse;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
begin
  http := getHttpClient;
  Result := THTTPClientResponse.Create;
  resp := http.Get(url);
  THTTPClientResponse(Result).LoadContentStream(resp.ContentStream);
  THTTPClientResponse(Result).StatusCode := resp.StatusCode;
  http.Free;
end;

function TNetHttpClientWrapper.Delete(url: String;
  header: TArray<THttpHeader>): IHTTPClientResponse;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
  h: THttpHeader;
begin
  http := getHttpClient;

  for h in header do
  begin
    http.CustomHeaders[h.key] := h.value;
  end;

  Result := THTTPClientResponse.Create;
  resp := http.Delete(url);
  THTTPClientResponse(Result).LoadContentStream(resp.ContentStream);
  THTTPClientResponse(Result).StatusCode := resp.StatusCode;
  http.Free;
end;

function TNetHttpClientWrapper.Get(url: String; out response: String): IHTTPClientResponse;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
begin
  http := getHttpClient;
  Result := THTTPClientResponse.Create;
  resp := http.Get(url);
  THTTPClientResponse(Result).LoadContentStream(resp.ContentStream);
  THTTPClientResponse(Result).StatusCode := resp.StatusCode;
  response := Result.Content;
  http.Free;
end;

function TNetHttpClientWrapper.getHttpClient: TNetHttpClient;
begin
  Result := TNetHTTPClient.Create(nil);
  if (TOSVersion.Platform = TOSVersion.TPlatform.pfAndroid) and (not TOSVersion.Check(5, 0)) then
  begin
    Result.OnValidateServerCertificate := ValidateServerCertificate;
  end;
  if (TOSVersion.Platform = TOSVersion.TPlatform.pfWindows) and (not TOSVersion.Check(6, 2)) then
  begin
    Result.SecureProtocols := [THTTPSecureProtocol.TLS11, THTTPSecureProtocol.TLS12];
  end;
end;

function TNetHttpClientWrapper.Post(url, ContentType: String;
  postData: TStrings; header: TArray<THttpHeader>): IHTTPClientResponse;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
  h: THttpHeader;
begin
  http := getHttpClient;

  for h in header do
  begin
    http.CustomHeaders[h.key] := h.value;
  end;

  Result := THTTPClientResponse.Create;
  http.ContentType := ContentType;
  resp := http.Post(url, postData);
  THTTPClientResponse(Result).LoadContentStream(resp.ContentStream);
  THTTPClientResponse(Result).StatusCode := resp.StatusCode;
  http.Free;
end;

function TNetHttpClientWrapper.Put(url, ContentType: String; postData: TStream;
  header: TArray<THttpHeader>): IHTTPClientResponse;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
  h: THttpHeader;
begin
  http := getHttpClient;

  for h in header do
  begin
    http.CustomHeaders[h.key] := h.value;
  end;

  Result := THTTPClientResponse.Create;
  http.ContentType := ContentType;
  resp := http.Put(url, postData);
  THTTPClientResponse(Result).LoadContentStream(resp.ContentStream);
  THTTPClientResponse(Result).StatusCode := resp.StatusCode;
  http.Free;
end;

procedure TNetHttpClientWrapper.ValidateServerCertificate(const Sender: TObject;
  const ARequest: TURLRequest; const Certificate: TCertificate;
  var Accepted: Boolean);
begin
  Accepted := true;
end;

function TNetHttpClientWrapper.Post(url, ContentType: String; postData: TStream;
  header: TArray<THttpHeader>): IHTTPClientResponse;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
  h: THttpHeader;
begin
  http := getHttpClient;

  for h in header do
  begin
    http.CustomHeaders[h.key] := h.value;
  end;

  Result := THTTPClientResponse.Create;
  http.ContentType := ContentType;
  resp := http.Post(url, postData);
  THTTPClientResponse(Result).LoadContentStream(resp.ContentStream);
  THTTPClientResponse(Result).StatusCode := resp.StatusCode;
  http.Free;
end;

function TNetHttpClientWrapper.Get(url: String;
  header: TArray<THttpHeader>): IHTTPClientResponse;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
  h: THttpHeader;
begin
  http := getHttpClient;
  for h in header do
  begin
    if (h.key <> '') and (h.value <> '') then http.CustomHeaders[h.key] := h.value;
  end;
  Result := THTTPClientResponse.Create;
  resp := http.Get(url);
  THTTPClientResponse(Result).LoadContentStream(resp.ContentStream);
  THTTPClientResponse(Result).StatusCode := resp.StatusCode;
  http.Free;
end;

function TNetHttpClientWrapper.Post(url: String;
  ContentType: String; postData: TStream): IHTTPClientResponse;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
begin
  http := getHttpClient;
  Result := THTTPClientResponse.Create;
  http.ContentType := ContentType;
  resp := http.Post(url, postData);
  THTTPClientResponse(Result).LoadContentStream(resp.ContentStream);
  THTTPClientResponse(Result).StatusCode := resp.StatusCode;
  http.Free;
end;

end.
