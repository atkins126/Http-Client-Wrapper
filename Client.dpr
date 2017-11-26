program Client;

uses
  Vcl.Forms,
  ClientTestFrm in 'ClientTestFrm.pas' {ClientTestDlg},
  HttpClientWrapperLib in 'source\HttpClientWrapperLib.pas',
  IndyHttpClientWrapper in 'source\IndyHttpClientWrapper.pas',
  NetHttpClientWrapper in 'source\NetHttpClientWrapper.pas',
  AlcinoeHttpClientWrapper in 'source\AlcinoeHttpClientWrapper.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TClientTestDlg, ClientTestDlg);
  Application.Run;
end.
