unit ClientTestFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TClientTestDlg = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Button2: TButton;
    Memo1: TMemo;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  ClientTestDlg: TClientTestDlg;

implementation

uses
  HttpClientWrapperLib, Vcl.Imaging.pngimage, IdMultipartFormData,
  NetHttpClientWrapper;

{$R *.dfm}

procedure TClientTestDlg.Button1Click(Sender: TObject);
var
  client: THttpClientWrapper;
  teext: string;
begin
  client := THttpClientWrapper.Create(TNetHttpClientWrapper.Create);
  client.Get('http://httpbin.org/headers', teext);
  Memo1.Text := teext;
  client.Free;
end;

procedure TClientTestDlg.Button2Click(Sender: TObject);
var
  client: THttpClientWrapper;
  resp: IHTTPClientResponse;
  stream: TStringStream;
begin
  client := THttpClientWrapper.Create(TNetHttpClientWrapper.Create);
  stream := TStringStream.Create('{"name": "Dennis"}');
  resp := client.Post('http://httpbin.org/post', 'application/json', stream);
  stream.Free;

  Memo1.Text := resp.Content;
  client.Free;
end;

procedure TClientTestDlg.Button3Click(Sender: TObject);
var
  client: THttpClientWrapper;
  resp: IHTTPClientResponse;
  form: TIdMultiPartFormDataStream;
begin
  form := TIdMultiPartFormDataStream.Create;
  form.AddFormField('Name', 'ABCDE');

  client := THttpClientWrapper.Create(TNetHttpClientWrapper.Create);
  resp := client.Post('https://requestb.in/1idy81g1', form.RequestContentType, form);

  form.Free;

  Memo1.Text := resp.Content;
  client.Free;
end;

procedure TClientTestDlg.Button4Click(Sender: TObject);
var
  client: THttpClientWrapper;
begin
  client := THttpClientWrapper.Create(TNetHttpClientWrapper.Create);
  client.OnResponse :=
    procedure(resp: IHTTPClientResponse)
    begin
      Memo1.Lines.Text := resp.Content;
    end;
  client.AsyncGet('http://httpbin.org/delay/5');
end;

procedure TClientTestDlg.Button5Click(Sender: TObject);
var
  client: THttpClientWrapper;
  strStream: TStringStream;
begin
  client := THttpClientWrapper.Create(TNetHttpClientWrapper.Create);
  client.OnResponse :=
    procedure(resp: IHTTPClientResponse)
    begin
      Memo1.Lines.Text := resp.Content;
      strStream.Free;
    end;

  strStream := TStringStream.Create('{"Name": "Dennis"}');
  client.AsyncPost('http://httpbin.org/post', 'application/json', strStream);
end;

end.
