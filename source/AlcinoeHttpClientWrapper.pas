unit AlcinoeHttpClientWrapper;

interface

uses
  HttpClientWrapperLib, System.Classes;

type
  TAlcinoeHttpClientWrapper = class(TInterfacedObject, IHttpClientWrapper)
  public
    function Get(url: String): IHTTPClientResponse;overload;
    function Get(url: String; out response: String): IHTTPClientResponse;overload;

    function Post(url: String; ContentType: String; postData: TStream): IHTTPClientResponse;
  end;

implementation

uses
  ALWinHttpClient, ALHttpClient, System.SysUtils;

{ TIndyHttpClientWrapper }

function TAlcinoeHttpClientWrapper.Get(url: String): IHTTPClientResponse;
var
  http: TALWinHttpClient;
  resp: TMemoryStream;
  respHeader: TALHTTPResponseHeader;
  strStream: TStringStream;
begin
  http := TALWinHttpClient.Create;
  Result := THTTPClientResponse.Create;
  respHeader := TALHTTPResponseHeader.Create;
  resp := TMemoryStream.Create;
  http.Get(url, resp, respHeader);

  strStream := TStringStream.Create;
  strStream.LoadFromStream(resp);
  THTTPClientResponse(Result).Content := strStream.DataString;
  strStream.Free;

  THTTPClientResponse(Result).LoadContentStream(resp);
  THTTPClientResponse(Result).StatusCode := StrToInt(respHeader.StatusCode);

  resp.Free;
  respHeader.Free;
  http.Free;
end;

function TAlcinoeHttpClientWrapper.Get(url: String; out response: String): IHTTPClientResponse;
var
  http: TALWinHttpClient;
  resp: TStringStream;
  respHeader: TALHTTPResponseHeader;
begin
  http := TALWinHttpClient.Create;
  Result := THTTPClientResponse.Create;
  respHeader := TALHTTPResponseHeader.Create;
  resp := TStringStream.Create;
  http.Get(url, resp, respHeader);
  response := resp.DataString;
  THTTPClientResponse(Result).Content := resp.DataString;
  THTTPClientResponse(Result).LoadContentStream(resp);
  THTTPClientResponse(Result).StatusCode := StrToInt(respHeader.StatusCode);

  resp.Free;
  respHeader.Free;
  http.Free;
end;

function TAlcinoeHttpClientWrapper.Post(url: String;
  ContentType: String; postData: TStream): IHTTPClientResponse;
var
  http: TALWinHttpClient;
  resp: TMemoryStream;
  respHeader: TALHTTPResponseHeader;
  strStream: TStringStream;
begin
  http := TALWinHttpClient.Create;
  Result := THTTPClientResponse.Create;
  respHeader := TALHTTPResponseHeader.Create;
  resp := TMemoryStream.Create;

  http.RequestHeader.UserAgent := ' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36';
  http.RequestHeader.ContentType := ContentType;
  try
    http.Post(url,postdata, resp, respHeader);
  except
    on E: EALHTTPClientException do
    begin
      THTTPClientResponse(Result).Content := E.Message;
    end;
  end;

  resp.Position := 0;
  strStream := TStringStream.Create;
  strStream.LoadFromStream(resp);
  THTTPClientResponse(Result).Content := strStream.DataString;
  strStream.Free;

  THTTPClientResponse(Result).LoadContentStream(resp);
  THTTPClientResponse(Result).StatusCode := StrToInt(respHeader.StatusCode);

  resp.Free;
  respHeader.Free;
  http.Free;
end;

initialization
  THttpClientWrapper.RegisterClient(
    function: IHttpClientWrapper
    begin
      Result := TAlcinoeHttpClientWrapper.Create
    end);

end.
