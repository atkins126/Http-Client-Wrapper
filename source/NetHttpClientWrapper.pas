unit NetHttpClientWrapper;

interface

uses
  HttpClientWrapperLib, System.Classes, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TNetHttpClientWrapper = class(TInterfacedObject, IHttpClientWrapper, IHttpClientFileDownload)
  private
    FBasicAuthUser: String;
    FBasicAuthPassword: String;
    FUseCustomCertifcateValidation: Boolean;
    function getHttpClient: TNetHttpClient;
    procedure ValidateServerCertificate(const Sender: TObject; const ARequest: TURLRequest; const Certificate: TCertificate; var Accepted: Boolean);
    procedure AuthEvent(const Sender: TObject; AnAuthTarget: TAuthTargetType; const ARealm, AURL: string; var AUserName, APassword: string; var AbortAuth: Boolean;
      var Persistence: TAuthPersistenceType);
  public
    constructor Create;
    procedure SetBasicAuth(username, password: String);
    function Get(url: String): IHTTPClientResponse;overload;
    function Get(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;overload;
    function Get(url: String; out response: String): IHTTPClientResponse;overload;

    function DownloadFile(url: string; filename: String): Boolean;

    function Post(url: String; ContentType: String; postData: TStream): IHTTPClientResponse; overload;
    function Post(url: String; ContentType: String; postData: TStream; header: TArray<THttpHeader>): IHTTPClientResponse;overload;
    function Post(url: String; ContentType: String; postData: TStrings; header: TArray<THttpHeader>): IHTTPClientResponse;overload;

    function Put(url: String; ContentType: String; postData: TStream; header: TArray<THttpHeader>): IHTTPClientResponse;

    function Delete(url: String; header: TArray<THttpHeader>): IHTTPClientResponse;

    property BasicAuthUser: String read FBasicAuthUser write FBasicAuthUser;
    property BasicAuthPassword: String read FBasicAuthPassword write FBasicAuthPassword;

    property UseCustomCertifcateValidation: Boolean read FUseCustomCertifcateValidation write FUseCustomCertifcateValidation;
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

procedure TNetHttpClientWrapper.AuthEvent(const Sender: TObject; AnAuthTarget: TAuthTargetType; const ARealm,
  AURL: string; var AUserName, APassword: string; var AbortAuth: Boolean; var Persistence: TAuthPersistenceType);
begin
  if AnAuthTarget = TAuthTargetType.Server then
  begin
    AUserName := BasicAuthUser;
    APassword := BasicAuthPassword;
  end;
end;

constructor TNetHttpClientWrapper.Create;
begin
  FUseCustomCertifcateValidation := false;
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

function TNetHttpClientWrapper.DownloadFile(url, filename: String): Boolean;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
  fs: TFileStream;
begin
  http := getHttpClient;
  fs := TFileStream.Create(filename, fmCreate);
  try
    resp := http.Get(url, fs);
    Result := true;
  finally
    fs.Free;
    http.Free;
  end;
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
  if (FUseCustomCertifcateValidation) or ((TOSVersion.Platform = TOSVersion.TPlatform.pfAndroid) and (not TOSVersion.Check(5, 0))) then
  begin
    Result.OnValidateServerCertificate := ValidateServerCertificate;
  end;
  if (TOSVersion.Platform = TOSVersion.TPlatform.pfWindows) and (not TOSVersion.Check(6, 2)) then
  begin
    Result.SecureProtocols := [THTTPSecureProtocol.TLS11, THTTPSecureProtocol.TLS12];
  end;

  if not BasicAuthUser.Trim.IsEmpty then
  begin
    Result.OnAuthEvent := AuthEvent;
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

procedure TNetHttpClientWrapper.SetBasicAuth(username, password: String);
begin
  BasicAuthUser := username;
  BasicAuthPassword := password;
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
