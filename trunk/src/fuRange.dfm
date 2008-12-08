object fmRange: TfmRange
  Left = 341
  Top = 174
  Width = 295
  Height = 158
  Caption = 'Range'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 24
    Top = 27
    Width = 17
    Height = 13
    Caption = 'Min'
  end
  object lbl2: TLabel
    Left = 24
    Top = 54
    Width = 20
    Height = 13
    Caption = 'Max'
  end
  object btnOk: TButton
    Left = 112
    Top = 98
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 208
    Top = 98
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object edtMin: TEdit
    Left = 72
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '-1'
  end
  object edtMax: TEdit
    Left = 72
    Top = 56
    Width = 121
    Height = 21
    TabOrder = 3
    Text = '-1'
  end
end
