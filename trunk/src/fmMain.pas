unit fmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, Grids, DBGrids, ADODB, ExtCtrls, Buttons,Registry,
  DBCtrls, Menus,Clipbrd,fuRange,cc, FYDbGrid;

type
  TForm1 = class(TForm)
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    DataSource1: TDataSource;
    pnl1: TPanel;
    spl1: TSplitter;
    edt1: TEdit;
    btn2: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    edt2: TEdit;
    lbl3: TLabel;
    lbl4: TLabel;
    btn1: TButton;
    lblrecordcount_curr: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lblrecordcount: TLabel;
    qry1: TADOQuery;
    edtsql: TEdit;
    btnrun: TButton;
    pnl2: TPanel;
    ListBox1: TListBox;
    dbmemo: TDBMemo;
    mm1: TMainMenu;
    File1: TMenuItem;
    exporttablelisst1: TMenuItem;
    exportfieldlist1: TMenuItem;
    Filtersbyrecordcount1: TMenuItem;
    mmoLog: TMemo;
    backup: TMenuItem;
    Restore: TMenuItem;
    DBGrid1: TFYDBGrid;
    procedure ListBox1Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnrunClick(Sender: TObject);
    procedure exporttablelisst1Click(Sender: TObject);
    procedure exportfieldlist1Click(Sender: TObject);
    procedure Filtersbyrecordcount1Click(Sender: TObject);
    procedure backupClick(Sender: TObject);
    procedure RestoreClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure fydbgrd1ColEnter(Sender: TObject);
  private
    function gettables(min,max: integer): string;
    function GetTableRecords(tablename: string): Integer;
    { Private declarations }
    procedure ResetDB(min,max:Integer);
    procedure Log(err:string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function GetRootByName(Name : String):DWORD;
begin
  if name = 'HKEY_CLASSES_ROOT'  then
    result := HKEY_CLASSES_ROOT
  else if name = 'HKEY_CURRENT_USER'  then
    result := HKEY_CURRENT_USER
  else if name = 'HKEY_LOCAL_MACHINE'  then
    result := HKEY_LOCAL_MACHINE
  else if name = 'HKEY_USERS'  then
    result := HKEY_USERS
  else if name = 'HKEY_PERFORMANCE_DATA'  then
    result := HKEY_PERFORMANCE_DATA
  else if name = 'HKEY_CURRENT_CONFIG'  then
    result := HKEY_CURRENT_CONFIG
  else if name = 'HKEY_DYN_DATA'  then
    result := HKEY_DYN_DATA
  else
    raise Exception.CreateFmt('Root Name not exists:%s',[Name]);
end;
function GetRootFromFullKey (keyName:string): DWORD;
var sl : TStringList ;
  s : string ;
begin
  sl := TStringList.Create;
  try
    sl.Delimiter := '\';
    sl.DelimitedText := keyName ;
    s := '';
    if sl.Count <> 0 then
      s := sl.Strings[0];
    Result := GetRootByName(s);
  finally
      sl.Free;
  end;
end;
function GetKeyFromFullKey (keyName:string): string;
var sl : TStringList ;
  s : string ;
begin
  sl := TStringList.Create;
  try
    sl.Delimiter := '\';
    sl.DelimitedText := keyName ;
    if sl.Count > 0 then
    begin
      sl.Delete(0);
      Result := sl.DelimitedText ;
    end else
      Result := '';
  finally
      sl.Free;
  end;
end;
function GetRegistryValue(KeyName,ItemName: string): string;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create();
  try
    Registry.RootKey := GetRootFromFullKey(KeyName);
    // False because we do not want to create it if it doesn't exist
    Registry.OpenKey(GetKeyFromFullKey(KeyName), False);
    Result := Registry.ReadString(ItemName);
  finally
    Registry.Free;
  end;
end;
function SetRegistryValue(KeyName: string;name,value : string): string;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create();
  try
    Registry.RootKey := GetRootFromFullKey(KeyName);
    // False because we do not want to create it if it doesn't exist
    Registry.OpenKey(GetKeyFromFullKey(KeyName), true);
    Registry.WriteString(Name,value);
  finally
    Registry.Free;
  end;
end;
function TForm1.GetTableRecords (tablename : string): Integer ;
var q : TADOQuery ;
begin
   q := TADOQuery.Create(nil);
   try
     q.Connection := ADOConnection1 ;
     tablename := '['+tablename+']';
     q.SQL.Text := 'select count(*) from '+ tablename ;
     q.Open ;
     result := q.Fields[0].AsInteger ;
     //raise Exception.Create('a')
   finally
     q.free ;
   end;
end;
function TForm1.gettables(min,max : integer):string;
var
  sl ,slresult: TStringList;
  tname : string;
  i ,records: Integer ;
begin
  sl := TStringList.Create;
  slresult := TStringList.Create;
  try
    ADOConnection1.GetTableNames(sl,False);
    for i := 0 to sl.Count -1 do
    begin
      tname := sl.Strings[i] ;
      try
        records :=GetTableRecords(tname);
      except
        on e : Exception do
          Log(e.Message);
      end;
      if (max = -1 ) and (min = -1 )
      //and TRegexp.Match('^Product',tname)
      then
        slresult.Add(tname)
      else if ( records< max ) and (records > min )then begin
        slresult.Add(tname);
      end;
    end;
    Result := slresult.Text ;
  finally
    sl.Free;
    slresult.Free  ;
  end;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
var tablename :string; sql : string ;
begin
  dbmemo.DataField := '';
  ADOQuery1.Close ;
  tablename := '[' + ListBox1.Items[ListBox1.itemindex] +']';
  if edt2.Text = '0' then
   sql := 'select  * from ' + tablename
  else
    sql  := 'select top '+edt2.Text + ' * from ' + tablename;
  ADOQuery1.SQL.Text := sql;
  ADOQuery1.Open ;
  lblrecordcount_curr.Caption  :=  IntToStr(ADOQuery1.RecordCount) ;
  qry1.Close ;
  qry1.SQL.Text := 'select count(*) from ' + tablename ;
  qry1.Open ;
  lblrecordcount.Caption  :=  qry1.Fields[0].AsString ;
  lblrecordcount_curr.Caption  :=  IntToStr(ADOQuery1.RecordCount) ;
  edtsql.text := sql;
end;

procedure TForm1.btn1Click(Sender: TObject);
var s : string ;
begin
  s :=   PromptDataSource(Handle,edt1.Text );
  if s <> '' then
    edt1.Text := s ;
end;

procedure TForm1.btn2Click(Sender: TObject);
var
  max ,min : Integer;
begin
  ResetDB(-1,-1);
end;
procedure TForm1.FormCreate(Sender: TObject);
var
  s : string ;
begin    
  s := GetRegistryValue('HKEY_LOCAL_MACHINE\software\dbquick','connstr')  ;
  if s <> '' then
  edt1.text :=  s;
  s := GetRegistryValue('HKEY_LOCAL_MACHINE\software\dbquick','top')  ;
  if s <> '' then
    edt2.text :=  s;
  edtsql.text := '';
  mmoLog.Text := '';
  mmolog.Visible := False ;
end;

procedure TForm1.btnrunClick(Sender: TObject);
begin
  //
  ADOQuery1.Close ;
  ADOQuery1.SQL.Text := edtsql.Text ;
  ADOQuery1.Open ;
end;



procedure TForm1.exporttablelisst1Click(Sender: TObject);
var s : string ;i : integer ;sl :TStringList ;
begin
   sl := TStringlist.Create ;
   try
     for i := 0 to ListBox1.Items.Count -1 do   begin
       s := s + '['+ ListBox1.Items.Strings[i]+']';
       if i <> ListBox1.Items.Count -1 then
         s := s +',';
     end;
     clipboard.SetTextBuf(PChar(s));
   finally
     sl.Free ;
   end;
end;

procedure TForm1.exportfieldlist1Click(Sender: TObject);
var s : string ;i : integer ;sl :TStringList ;
begin
   try
     for i := 0 to ADOQuery1.Fields.Count -1 do   begin
       s := s + '['+ ADOQuery1.Fields[i].FieldName+']';
       if i <> ADOQuery1.Fields.Count -1 then
         s := s +',';
     end;
     clipboard.SetTextBuf(PChar(s));
   finally
   end;
end;

procedure TForm1.Filtersbyrecordcount1Click(Sender: TObject);
var
  max ,min : Integer;
begin
  if TfmRange.GetRange(min,max)  then
  begin
    ResetDB(min,max);
  end
end;

procedure TForm1.ResetDB(min, max: Integer);
var
  fmRange : TfmRange ;
begin
  ADOConnection1.Close ;
  ADOConnection1.ConnectionString := edt1.Text ;
  listbox1.Items.Text  := gettables(min,max);
  ListBox1.Sorted := True ;
  SetRegistryValue('HKEY_LOCAL_MACHINE\software\dbquick','connstr',edt1.Text );
  SetRegistryValue('HKEY_LOCAL_MACHINE\software\dbquick','top',edt2.Text );
end;

procedure TForm1.Log(err: string);
begin
  mmoLog.Visible := true ;
  mmoLog.Lines.Add(err);
end;

procedure TForm1.backupClick(Sender: TObject);
var conn :TSqlconn; dbname : string;
begin
  //Showmessage(ADOConnection1.DefaultDatabase);
  dbname := ADOConnection1.DefaultDatabase;
  if dbname <> '' then begin
    conn := TSqlconn.Create;
    try
      conn.ConnStr := edt1.Text ;
      conn.BackupDB(ADOConnection1.DefaultDatabase,'c:\bak');
      ShowMessage('completed');
    finally
      conn.Free;
    end;
  end else begin
    ShowMessage('db not connected');
  end;
end;

procedure TForm1.RestoreClick(Sender: TObject);
var conn :TSqlconn; dbname : string;
begin
  //Showmessage(ADOConnection1.DefaultDatabase);
  dbname := ADOConnection1.DefaultDatabase;
  if dbname <> '' then begin
    conn := TSqlconn.Create;
    try
    conn.ConnStr := edt1.Text ;
    conn.RestoreDB('newnorthwind','c:\','c:\bak');
    ShowMessage('completed');
    finally
      conn.Free;
    end;
  end else begin
    ShowMessage('db not connected');
  end;
end;
// ALTER DATABASE database    MODIFY NAME = new_dbname

procedure TForm1.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if Column.Field.DisplayText='(MEMO)' then
    DBGrid1. Canvas.TextRect(Rect, 0, 0, Column.Field.AsString)  // write text to canvas
  else
    DBGrid1. DefaultDrawColumnCell(Rect, DataCol, Column, State); // default draw

end;

procedure TForm1.fydbgrd1ColEnter(Sender: TObject);
var s : string ;
begin
  s := DBGrid1.SelectedField.FieldName;
  if (DBGrid1.SelectedField is TMemoField) or (DBGrid1.SelectedField  is TStringField)  then begin

     if ADOQuery1.FieldList.IndexOf(s) <> -1 then
      dbmemo.DataField := s
  end
  else if (DBGrid1.SelectedField is  TGraphicField) then
    //dbimg.DataField := s
  else
     dbmemo.DataField := '';
end;

end.
