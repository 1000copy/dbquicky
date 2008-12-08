unit fuRange;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfmRange = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    edtMin: TEdit;
    edtMax: TEdit;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Getmax :Integer;
    function GetMin :Integer;
    class function GetRange(var min,max : Integer):Boolean ;
  end;

var
  fmRange: TfmRange;

implementation

{$R *.dfm}

procedure TfmRange.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk ;
end;

procedure TfmRange.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel ;
end;

function TfmRange.Getmax: Integer;
begin
  Result := StrToInt(edtMax.text);
end;

function TfmRange.GetMin: Integer;
begin
  Result := StrToInt(edtMin.text);
end;

class function TfmRange.GetRange(var min,max: Integer): Boolean;
var
  fmRange : TfmRange ;
begin
  fmRange := TfmRange.Create(nil);
  result := False ;
  try
    if fmRange.ShowModal = mrOk then
    begin
      max := fmRange.GetMax ;
      min := fmRange.GetMin ;
      Result := True ;
    end
  finally
    fmRange.free ;
  end;
end;
end.
