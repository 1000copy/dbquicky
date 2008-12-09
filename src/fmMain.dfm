object Form1: TForm1
  Left = 141
  Top = 162
  Width = 1001
  Height = 495
  Caption = 'dbquicky'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mm1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object spl1: TSplitter
    Left = 185
    Top = 81
    Height = 368
  end
  object DBGrid1: TFYDBGrid
    Left = 188
    Top = 81
    Width = 805
    Height = 368
    ColorBorder = 8404992
    ColorLine = clTeal
    ColorRowDouble = 16773345
    Align = alClient
    BorderStyle = bsNone
    DataSource = DataSource1
    FixedColor = 13296895
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgTabs, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnColEnter = fydbgrd1ColEnter
    OnDrawColumnCell = DBGrid1DrawColumnCell
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 993
    Height = 81
    Align = alTop
    TabOrder = 0
    object lbl1: TLabel
      Left = 24
      Top = 8
      Width = 52
      Height = 13
      Caption = '&conn string'
      FocusControl = edt1
    end
    object lbl2: TLabel
      Left = 32
      Top = 40
      Width = 15
      Height = 13
      Caption = '&top'
      FocusControl = edt2
    end
    object lbl3: TLabel
      Left = 0
      Top = 64
      Width = 44
      Height = 13
      Caption = '&1table list'
    end
    object lbl4: TLabel
      Left = 192
      Top = 64
      Width = 44
      Height = 13
      Caption = '&2valuelist'
    end
    object lblrecordcount_curr: TLabel
      Left = 840
      Top = 56
      Width = 6
      Height = 13
      Caption = '0'
    end
    object lbl5: TLabel
      Left = 832
      Top = 40
      Width = 75
      Height = 13
      Caption = 'currrecordcount'
    end
    object lbl6: TLabel
      Left = 928
      Top = 40
      Width = 57
      Height = 13
      Caption = 'recordcount'
    end
    object lblrecordcount: TLabel
      Left = 928
      Top = 56
      Width = 6
      Height = 13
      Caption = '0'
    end
    object edt1: TEdit
      Left = 80
      Top = 10
      Width = 595
      Height = 21
      TabOrder = 0
      Text = 
        'Provider=SQLOLEDB.1;Persist Security Info=False;User ID=sa;Initi' +
        'al Catalog=openilas;Data Source=.;Password=;'
    end
    object btn2: TButton
      Left = 712
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Apply'
      TabOrder = 1
      OnClick = btn2Click
    end
    object edt2: TEdit
      Left = 80
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 2
      Text = '100'
    end
    object btn1: TButton
      Left = 678
      Top = 8
      Width = 29
      Height = 25
      Caption = '...'
      TabOrder = 3
      OnClick = btn1Click
    end
    object edtsql: TEdit
      Left = 216
      Top = 40
      Width = 457
      Height = 21
      TabOrder = 4
      Text = 'edtsql'
    end
    object btnrun: TButton
      Left = 678
      Top = 36
      Width = 29
      Height = 25
      Caption = 'Run'
      TabOrder = 5
      OnClick = btnrunClick
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 81
    Width = 185
    Height = 368
    Align = alLeft
    Caption = 'pnl2'
    TabOrder = 1
    object ListBox1: TListBox
      Left = 1
      Top = 1
      Width = 183
      Height = 277
      Align = alClient
      ItemHeight = 13
      TabOrder = 0
      OnClick = ListBox1Click
    end
    object dbmemo: TDBMemo
      Left = 1
      Top = 278
      Width = 183
      Height = 89
      Align = alBottom
      DataSource = DataSource1
      TabOrder = 1
    end
  end
  object mmoLog: TMemo
    Left = 192
    Top = 360
    Width = 801
    Height = 89
    Lines.Strings = (
      'mmoLog')
    TabOrder = 2
  end
  object ADOConnection1: TADOConnection
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 648
    Top = 352
  end
  object ADOQuery1: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from accessno')
    Left = 680
    Top = 352
  end
  object DataSource1: TDataSource
    DataSet = ADOQuery1
    Left = 720
    Top = 352
  end
  object qry1: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from accessno')
    Left = 784
    Top = 352
  end
  object mm1: TMainMenu
    Left = 552
    Top = 352
    object File1: TMenuItem
      Caption = 'File'
      object exporttablelisst1: TMenuItem
        Caption = 'clipboard tablelisst'
        OnClick = exporttablelisst1Click
      end
      object exportfieldlist1: TMenuItem
        Caption = 'Clipborad fieldlist'
        OnClick = exportfieldlist1Click
      end
      object Filtersbyrecordcount1: TMenuItem
        Caption = 'Filters by recordcount'
        OnClick = Filtersbyrecordcount1Click
      end
      object backup: TMenuItem
        Caption = 'Backup'
        OnClick = backupClick
      end
      object Restore: TMenuItem
        Caption = 'Restore'
        OnClick = RestoreClick
      end
    end
  end
end
