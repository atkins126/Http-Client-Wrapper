unit IndyHttpClientWrapper;

interface

uses
  HttpClientWrapperLib, IdHTTP, System.Classes;

type
  TIndyHttpClientWrapper = class(TInterfacedObject, IHttpClientWrapper)
  public
    function Get(url: String): IHTTPClientResponse;overload;
    function Get(url: String; out response: String): IHTTPClientResponse;overload;

    function Post(url: String; ContentType: String; postData: TStream): IHTTPClientResponse;
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
begin
  http := TIdHTTP.Create;
  Result := THTTPClientResponse.Create;
  respStream := TMemoryStream.Create;
  try
    http.Get(url, respStream);
    respStream.Position := 0;
    respText := ReadStringAsCharset(respStream, http.Response.CharSet);
    THTTPClientResponse(Result).Content := respText;
    THTTPClientResponse(Result).LoadContentStream(respStream);
    THTTPClientResponse(Result).StatusCode := http.ResponseCode;
  except
    on E: EIdHTTPProtocolException do
    begin
      THTTPClientResponse(Result).StatusCode := E.ErrorCode;
    end;
  end;
  http.Free;
  respStream.Free;
end;

function TIndyHttpClientWrapper.Get(url: String; out response: String): IHTTPClientResponse;
var
  http: TIdHTTP;
begin
  http := TIdHTTP.Create;
  Result := THTTPClientResponse.Create;
  try
    response := http.Get(url);
    THTTPClientResponse(Result).Content := response;
    THTTPClientResponse(Result).StatusCode := http.ResponseCode;
  except
    on E: EIdHTTPProtocolException do
    begin
      THTTPClientResponse(Result).StatusCode := E.ErrorCode;
    end;
  end;
  http.Free;
end;

function TIndyHttpClientWrapper.Post(url: String;
  ContentType: String; postData: TStream): IHTTPClientResponse;
var
  http: TIdHTTP;
  resp: string;
begin
  Result := THTTPClientResponse.Create;
  http := TIdHTTP.Create;
  http.Request.UserAgent := ' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36';
  try
    http.Request.ContentType := ContentType;

    resp := http.Post(url, postData);
    THTTPClientResponse(Result).Content := resp;
  except
    on E: EIdHTTPProtocolException do
    begin
      THTTPClientResponse(Result).StatusCode := E.ErrorCode;
    end;
  end;
  http.Free;
end;

end.
