program dbquicky;

uses
  Forms,
  fmMain in 'fmMain.pas' {Form1},
  fuRange in 'fuRange.pas' {fmRange},
  cc in 'cc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfmRange, fmRange);
  Application.Run;
end.
