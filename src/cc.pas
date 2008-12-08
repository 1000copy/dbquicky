unit cc;

interface
uses Windows,Dialogs,SysUtils,adodb,Classes,RegExpr;
type
  TSqlconn = class
  private
    FConn: TADOConnection;
    FConnStr: String;
    function CheckNoSlash(str:string):string;
    procedure SetConnStr(const Value: String);
  public
    constructor Create ;reintroduce;
    destructor Destroy ;override;
    procedure BackupDB(DBName, FileName: String);
    procedure DeleteDB(DBName: String);
    function GetConnString(ADBName: String): string;
    function GetLogicalName(FromFile: String): String;
    procedure RestoreDB(DBName, DirName, SrcFileName: String);
    function ExistDB(Name: string): boolean;
    function Exec (sql :string): Integer;
    function QueryStrings(sql :string): String;
    property ConnStr : String  read FConnStr write SetConnStr;
  end;
  TRegexp = class
    class function Match(regexp,str:string):Boolean;
  end;
implementation

function TSqlconn.ExistDB(Name : string):boolean ;
var sql : string ;
begin
  sql :='SELECT name FROM master.dbo.sysdatabases WHERE name = N''%s''';
  sql := Format(sql,[Name]);
  result := '' <> QueryStrings(sql);
end;
procedure TSqlconn.BackupDB(DBName, FileName: String);
const
 sql = 'BACKUP DATABASE %s  TO DISK = ''%s''';//1 = dbname,2=filename
 procedure CheckDB(DBName:String);
 begin
   if not ExistDB(DBName) then
     Raise Exception.CreateFmt('??????????:%s',[DBName]);
 end;
 procedure CheckFile(FileName:String);
 begin
   if not DirectoryExists(ExtractFilePath(FileName)) then
     Raise Exception.CreateFmt('????????????:%s',[FileName]);
 end;
begin
    CheckDB(DBName);
    CheckFile(FileName);
    Exec(Format(sql,[DBName,FileName]));
end;



function TSqlconn.GetLogicalName(FromFile:String):String;
begin
    Result  := QueryStrings(
      Format('RESTORE FILELISTONLY FROM DISK = ''%s'' ',[FromFile])
      );
end;

function TSqlconn.GetConnString(ADBName: String): string;
const Connstr =
    'Provider=SQLOLEDB.1;Password=%s;'+
    'Persist Security Info=False;User ID=%s;'+
    'Initial Catalog=%s;'+
    'Data Source=%s';
begin
  //Result := Format(Connstr,[FPassword,FUser,ADBName,FHost]);
end;

procedure TSqlconn.RestoreDB(DBName, DirName,SrcFileName: String);
const
 sql = 'RESTORE DATABASE ${DBName}  FROM DISK = ''${SrcFileName}'' '+
       'WITH MOVE ''${LogicalDataName}'' TO ''${DirName}\${DBName}.mdf'', '+
       'MOVE ''${LogicalLogName}'' TO ''${DirName}\${DBName}_log.ldf''';//1 = dbname,2=filename
 procedure CheckDB(DBName:String);
 begin
   if ExistDB(DBName) then
     Raise Exception.CreateFmt('db exists :%s',[DBName]);
 end;
 procedure CheckFile(FileName:String);
 begin
   if not FileExists(FileName) then
     Raise Exception.CreateFmt('file not exists:%s',[FileName]);
 end;
var
  LogicalName,s : String;
  sl :TStringList;
begin
    //CheckDB(DBName);
    LogicalName := GetLogicalName(SrcFileName);
    if ExistDB(DBName) then begin
      if Messagebox(0,Pchar(Format('db exists:%s,delete?',[DBName])),'warning',MB_OKCancel) <> 1 then
        exit
      else
        DeleteDB(DBName);
    end;
    CheckFile(SrcFileName);
    sl := TStringList.Create;
    try
    sl.CommaText := LogicalName ;
    s := sql;
    s := StringReplace(s,'${DBName}',DBName,[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'${SrcFileName}',SrcFileName,[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'${DirName}',CheckNoSlash(DirName),[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'${LogicalDataName}',sl.Strings[0],[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'${LogicalLogName}',sl.Strings[1],[rfReplaceAll, rfIgnoreCase]);
    exec('use master');
    Exec(s);
    exec('use '+ FConn.DefaultDatabase);
    finally
      sl.free;
    end;
end;



constructor TSqlconn.Create;
begin
  inherited ;
  FConn := TADOConnection.Create(nil);
  FConn.LoginPrompt := False ;
end;

function TSqlconn.Exec(sql: string): Integer;
begin
  FConn.Execute(sql,Result);
end;

function TSqlconn.QueryStrings(sql: string): String;
var
  query :TADOQuery ;
  sl : TStringList;
begin
  query := TADOQuery.Create(nil) ;
  sl := TStringList.Create;
  try
    query.Connection := FConn ;
    query.SQL.Text := sql ;
    query.Open ;
    while not query.Eof do
    begin
      sl.Add(query.fields[0].asstring);
      query.Next ;
    end;
    Result := sl.DelimitedText;
  finally
    query.Free;
    sl.free ;
  end
end;

function TSqlconn.CheckNoSlash(str: string): string;
begin
  if Copy(str,Length(str),1) ='\' then
    Result := Copy(str,1,Length(str)-1)
  else
    Result := str ;
end;


destructor TSqlconn.Destroy;
begin
  FConn.Free ;
  inherited;
end;

procedure TSqlconn.SetConnStr(const Value: String);
begin
  FConnStr := Value;
  if not FConn.Connected then
  begin
    FConn.ConnectionString := Value ;
    FConn.Connected := True ;
  end;
end;

procedure TSqlconn.DeleteDB(DBName: String);
begin
  Exec(Format('use master;drop database %s;',[DBName]));
end;

{ TRegexp }

class function TRegexp.Match(regexp, str: string): Boolean;
begin
  Result := ExecRegExpr(regexp,str);
end;

end.
