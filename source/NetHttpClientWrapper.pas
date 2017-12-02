unit NetHttpClientWrapper;

interface

uses
  HttpClientWrapperLib, System.Classes;

type
  TNetHttpClientWrapper = class(TInterfacedObject, IHttpClientWrapper)
  public
    function Get(url: String): IHTTPClientResponse;overload;
    function Get(url: String; out response: String): IHTTPClientResponse;overload;

    function Post(url: String; ContentType: String; postData: TStream): IHTTPClientResponse;
  end;

implementation

uses
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent;

{ TIndyHttpClientWrapper }

function TNetHttpClientWrapper.Get(url: String): IHTTPClientResponse;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
begin
  http := TNetHTTPClient.Create(nil);
  Result := THTTPClientResponse.Create;
  resp := http.Get(url);
  THTTPClientResponse(Result).Content := resp.ContentAsString;
  THTTPClientResponse(Result).LoadContentStream(resp.ContentStream);
  THTTPClientResponse(Result).StatusCode := resp.StatusCode;
  http.Free;
end;

function TNetHttpClientWrapper.Get(url: String; out response: String): IHTTPClientResponse;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
begin
  http := TNetHTTPClient.Create(nil);
  Result := THTTPClientResponse.Create;
  resp := http.Get(url);
  THTTPClientResponse(Result).Content := resp.ContentAsString;
  THTTPClientResponse(Result).LoadContentStream(resp.ContentStream);
  THTTPClientResponse(Result).StatusCode := resp.StatusCode;
  response := Result.Content;
  http.Free;
end;

function TNetHttpClientWrapper.Post(url: String;
  ContentType: String; postData: TStream): IHTTPClientResponse;
var
  http: TNetHTTPClient;
  resp: IHTTPResponse;
begin
  http := TNetHTTPClient.Create(nil);
  Result := THTTPClientResponse.Create;
  http.ContentType := ContentType;
  resp := http.Post(url, postData);
  THTTPClientResponse(Result).Content := resp.ContentAsString;
  THTTPClientResponse(Result).LoadContentStream(resp.ContentStream);
  THTTPClientResponse(Result).StatusCode := resp.StatusCode;
  http.Free;
end;


end.
