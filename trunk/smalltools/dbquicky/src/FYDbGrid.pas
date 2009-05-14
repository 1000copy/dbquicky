{******************************************************************}
{ 在dbgrid基础上加入边框线,和外框线.隔行画底线.点击标题排序等功能. }
{  作者:yxp132                                                     }
{   QQ:85076500                                                    }
{   Email:132xyz20@163.com                                         }
{                                                                  }
{******************************************************************}
unit FYDbGrid;

interface

uses
  Windows, Messages, Classes, Controls, Forms, Graphics, StdCtrls, Grids,dbgrids,
  dbclient,ADODB,db,FlatSB,SysUtils;

type
  Tcellstyle=(csRaised,csLowered,csNone);
  TFYDBGrid = class(TCustomDBGrid)
  private
    FBorderColor: TColor;
    FFlatScrollBars : Boolean;
    FColorLine: TColor;
    FSingleColor: TColor;
    FDoubleColor: TColor;
    Fshowimages : Boolean ;
    FShowmemotext : Boolean ;
    procedure CMMouseEnter (var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave (var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMSetFocus (var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus (var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMNCCalcSize (var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCPaint (var Message: TMessage); message WM_NCPAINT;
    procedure SetColors(const Value: TColor);
    procedure SetColorLine(const Value: TColor);
    procedure SetSingleColor(Const Value: TColor);
    procedure SetDoubleColor(const Value: TColor);
    procedure DrawCell(ACol, ARow: Integer; ARect: TRect;
      AState: TGridDrawState);
    procedure DrawColumnCell1(const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState);
  protected
    procedure DrawColumnCell(const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState); override;
    procedure TitleClick(Column: TColumn);  override;
    procedure RedrawBorder (const Clip: HRGN);
  public
    constructor Create (AOwner: TComponent); override;
    property Canvas;
    property SelectedRows;
  published
    property FlatScroll : Boolean read FFlatScrollBars write FFlatScrollBars default false;
    property ColorBorder: TColor read FBorderColor write SetColors default $008396A0;
    property ColorLine: TColor read FColorLine Write SetColorLine default clGreen;
    property ColorRowSingle :TColor read FSingleColor Write SetSingleColor default clWhite;
    property ColorRowDouble :TColor read FDoubleColor Write SetDoubleColor default $00EFEFDE;
    property Align;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Columns stored False; //StoreColumns;
    property Constraints;
    property Ctl3D;
    property DataSource;
    property DefaultDrawing;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FixedColor;
    property Font;
    property ImeMode;
    property ImeName;
    property Options;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TitleFont;
    property Visible;
    property OnCellClick;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnDrawDataCell;  { obsolete }
    property OnDrawColumnCell;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditButtonClick;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;
  end;

procedure Register;

implementation

{ TOSPDBGrid }
const
imagetypes=[ftblob,ftgraphic,ftTypedBinary,ftParadoxOle,ftDBaseOle];
memotypes=[ftmemo,ftfmtmemo];

procedure Register;
begin
  RegisterComponents('FYVCL', [TFYDBGrid]);
end;

constructor TFYDBGrid.Create(AOwner: TComponent);
begin
  inherited;
  BorderStyle := bsNone;
  Options := Options-[dgColLines, dgRowLines];
  ControlStyle := ControlStyle - [csFramed];
  FBorderColor:= $00804000;
  FColorLine:= clTeal;
  FSingleColor:= clWhite;
  FDoubleColor:=$00FFF0E1;
  FixedColor:=$00CAE4FF;
  Fshowimages := false;
  FShowmemotext := true ;
end;

procedure TFYDBGrid.WMNCPaint(var Message: TMessage);
begin
  inherited;
  RedrawBorder(HRGN(Message.WParam));
end;

procedure TFYDBGrid.RedrawBorder(const Clip: HRGN);
var
  DC: HDC;
  R: TRect;
  BtnFaceBrush: HBRUSH;
begin
  DC := GetWindowDC(Handle);
  try
    GetWindowRect(Handle, R);
    OffsetRect(R, -R.Left, -R.Top);
    BtnFaceBrush := CreateSolidBrush(ColorToRGB(FBorderColor));
    FrameRect(DC, R, BtnFaceBrush);
    if FFlatScrollBars then InitializeFlatSB(Handle);
    //InflateRect(R, -1, -1);
  finally
    ReleaseDC(Handle, DC);
  end;
  DeleteObject(BtnFaceBrush);
end;

procedure TFYDBGrid.SetColors(const Value: TColor);
begin
  FBorderColor := Value;
  RedrawBorder(0);
end;

procedure TFYDBGrid.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if not(csDesigning in ComponentState) then
    RedrawBorder(0);
end;

procedure TFYDBGrid.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not(csDesigning in ComponentState) then
    RedrawBorder(0);
end;

procedure TFYDBGrid.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if (GetActiveWindow <> 0) then
  begin
    RedrawBorder(0);
  end;
end;

procedure TFYDBGrid.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  RedrawBorder(0);
end;

procedure TFYDBGrid.WMNCCalcSize(var Message: TWMNCCalcSize);
begin
  inherited;
  InflateRect(Message.CalcSize_Params^.rgrc[0], -1, -1);
end;

procedure TFYDBGrid.DrawColumnCell(const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
var
  FRect:TRect;
  value  :string;
begin
  inherited;
  // draw memo and picture 
  DrawColumnCell1( Rect,DataCol, Column,State);
  if GdSelected in State then  exit;
  if DataSource.DataSet.RecNo mod 2<>0 then
    Canvas.Brush.Color:= FSingleColor   
  else Canvas.Brush.Color:=FDoubleColor;
  //lcj comment
  // DefaultDrawColumnCell(Rect, DataCol, Column, State);
  Canvas.Brush.Color:=FColorLine;     

  //绘制数据区的上边框
  FRect.Left:=Rect.Left-1;
  FRect.Right:=Rect.Right;
  Frect.Top:=-1;
  Frect.Bottom:=17;
  Canvas.FrameRect(FRect);

  //绘制数据区的左边框
  FRect.Left:=-1;
  FRect.Right:=11;
  Frect.Top:=Rect.Top-1;
  Frect.Bottom:=Rect.Bottom;
  Canvas.FrameRect(FRect);
  //绘制数据区的表格边框
  
  FRect.Bottom:=Rect.Bottom;
  FRect.Top:=Rect.Top-1;
  FRect.Left:=Rect.Left-1;
  FRect.Right:=Rect.Right;
  Canvas.FrameRect(FRect);

end;


procedure TFYDBGrid.SetColorLine(const Value: TColor);
begin
  FColorLine := Value;
  RedrawBorder(0);
end;

procedure TFYDBGrid.SetDoubleColor(const Value: TColor);
begin
  FDoubleColor := Value;
//  RedrawBorder(0);
end;

procedure TFYDBGrid.SetSingleColor(const Value: TColor);
begin
  FSingleColor := Value;
//  RedrawBorder(0);
end;

procedure TFYDBGrid.TitleClick(Column: TColumn);
var s,cFieldName:string; 
    i:integer; 
    DataSet:TDataSet; 
    procedure setTitle; 
    var ii:integer;
        cStr:string;
        c:TColumn; 
    begin 
      for ii:=0 to TDBGrid(Column.Grid).Columns.Count-1 do
      begin
        c:=TDBGrid(Column.Grid).Columns[ii]; 
        cStr:=c.Title.Caption;
        if (pos('▲',cStr)=1) or (pos('▼',cStr)=1) then begin 
          Delete(cStr,1,2); 
          c.Title.Caption:=cStr;
        end; 
      end; 
    end;
begin                     
  inherited;
  setTitle;
  DataSet:=Column.Grid.DataSource.DataSet;
  if Column.Field.FieldKind=fkLookup then 
    cFieldName:=Column.Field.KeyFields 
  else if Column.Field.FieldKind=fkCalculated then 
    cFieldName:=Column.Field.KeyFields 
  else 
    cFieldName:=Column.FieldName; 
  if DataSet is TCustomADODataSet then begin 
    s:=TCustomADODataSet(DataSet).Sort; 
    if s='' then begin 
      s:=cFieldName; 
      Column.Title.Caption:='▲'+Column.Title.Caption;
    end 
    else begin 
      if Pos(cFieldName,s)<>0 then begin 
        i:=Pos('DESC',s); 
        if i<=0 then begin 
          s:=s+' DESC'; 
          Column.Title.Caption:='▼'+Column.Title.Caption;
        end 
        else begin 
          Column.Title.Caption:='▲'+Column.Title.Caption;
          Delete(s,i,4); 
        end; 
      end 
      else begin 
        s:=cFieldName;
        Column.Title.Caption:='▲'+Column.Title.Caption;
      end; 
    end;
    TCustomADODataSet(DataSet).Sort:=s; 
  end 
  else if DataSet is TClientDataSet then begin 
    if TClientDataSet(DataSet).indexfieldnames<>'' then
    begin 
      i:=TClientDataSet(DataSet).IndexDefs.IndexOf('i'+Column.FieldName); 
      if i=-1 then 
      begin 
        with TClientDataSet(DataSet).IndexDefs.AddIndexDef do 
        begin 
          Name:='i'+Column.FieldName; 
          Fields:=Column.FieldName; 
          DescFields:=Column.FieldName; 
        end; 
      end; 
      TClientDataSet(DataSet).IndexFieldNames:='';
      TClientDataSet(DataSet).IndexName:='i'+Column.FieldName; 
      Column.Title.Caption:='▼'+Column.Title.Caption;
    end
    else 
    begin 
      TClientDataSet(DataSet).IndexName:='';
      TClientDataSet(DataSet).IndexFieldNames:=column.fieldname;
      Column.Title.Caption:='▲'+Column.Title.Caption ;
    end;
  end;
end;
procedure TFyDbGrid.DrawColumnCell1(const Rect:TRect;DataCol:Integer;
Column: TColumn; State: TGridDrawState);
  var f:TField;

  procedure imagecell;
  var
  r:trect;
  w,h:integer;
  pic:TPicture;
  x:single;
  begin
  with rect,canvas do
    begin
    r:=rect;
    fillrect(rect);
    pic:=tpicture.create;
     try
     pic.assign(f);
     if not ((pic.Graphic=nil) or (pic.Graphic.Empty)) then
        begin
        x:=(pic.width/pic.height);{aspect ratio}
        h:=r.bottom-r.top;
        w:=trunc(h*x);
        if w>(right-left) then  {re-proportion pic}
           begin
           w:=(right-left);
           h:=trunc(w/x);
           end;
        r.left:=(right+left-w) shr 1;
        r.right:=r.left+w;
        r.top:=(bottom+top-h) shr 1;
        r.bottom:=r.top+h;
        inflaterect(r,-1,-1);
        stretchdraw(r,pic.graphic);
        end;
     finally
     pic.free;
     end;
    end;
  end;

  {draw multi-line text in memo fields}
  procedure memocell;
  var
  r:Trect;
  s:string;
  begin
  with canvas do
    begin
    fillrect(rect);
    s:=f.asstring;
    if s='' then exit;
    r:=rect;
    inflaterect(r,-1,-1);
    r.right:=r.right-getsystemmetrics(SM_CXVSCROLL);
    drawtext(canvas.handle,pchar(s),-1,r,DT_WORDBREAK or DT_NOPREFIX);
    end;
  end;

begin
//inherited drawcolumncell(rect,datacol,column,state);
if (gdFixed in state) then exit;
f:=column.field;
if (f.datatype in imagetypes) and Fshowimages then imagecell;
if (f.datatype in memotypes) and FShowmemotext then memocell;
end;


procedure TFyDbGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
    MasterCol,Column: TColumn;
    TitleRect: TRect;
    LeftPoint,i, LineHeight: Integer;
    Strs: TStringList;
 procedure drawrect(l,t,r,b:integer;p1,p2:Tcolor);
 begin
 with ARect,canvas do
  begin
  Pen.Color :=p1 ;
  PolyLine([Point(l,b),Point(l,t),Point(r,t)]);
  Pen.Color :=p2;
  PolyLine([Point(l,b),Point(r,b),Point(r,t)]);
  end;
 end;
  function BreakStr(ACanvas: TCanvas; StrWidth: Integer; Str: String): TStringList;
  const Dividers=' ,.<>:;-*/+"''$#()=';
  var i: Integer;
      tmp: String;
      Words: TStringList;
  begin
    Words:=TStringList.Create;
    Result:=TStringList.Create;
    tmp:='';
    for i:=1 to Length(Str) do
    begin
      tmp:=tmp+Str[i];
      if Pos(Str[i],Dividers)>0 then begin Words.Add(tmp); tmp:='' end;
    end;
    Words.Add(tmp);
    tmp:='';
    Result.Add(Words[0]);
    for i:=1 to Words.Count-1 do
    begin
      if (ACanvas.TextWidth(Result[Result.Count-1]+Words[i])>StrWidth) then
      begin
        Result[Result.Count-1]:=Trim(Result[Result.Count-1]); //trim the blanks at the line's edges
        Result.Add(Words[i]);
      end
      else
        Result[Result.Count-1]:=Result[Result.Count-1]+Words[i];
    end;
  end;
begin
inherited;
 if (dgTitles in Options) and (ARow=0) and ((ACol>0) or (not (dgIndicator in Options))) then
  begin
    if dgIndicator in Options then Column:=Columns[ACol-1] else Column:=Columns[ACol];
    TitleRect:=CalcTitleRect(Column, ARow, MasterCol);
    if MasterCol = nil then
    begin
      Canvas.Brush.Color := FixedColor;
      Canvas.FillRect(ARect);
      Exit;
    end;
    Canvas.Font := MasterCol.Title.Font;
    Canvas.Brush.Color := MasterCol.Title.Color;
    Canvas.FillRect(TitleRect);
    Strs:=BreakStr(Canvas,ARect.Right-ARect.Left-4,MasterCol.Title.Caption);
    LineHeight:=Canvas.TextHeight('Wg');
//    Strs:=BreakStr(Canvas,ARect.Right-ARect.Left-4,'asdfgad adsfgdffff gfdfg dfgdfgdg');
    for i:=0 to Strs.Count-1 do
    begin
      case Column.Title.Alignment of
        taLeftJustify:
          LeftPoint:=ARect.Left+2;
        taRightJustify:
          LeftPoint:=ARect.Right-Canvas.TextWidth(Strs[i])-3;
        taCenter:
          LeftPoint:=ARect.Left+(ARect.Right-ARect.Left) shr 1 - (Canvas.TextWidth(Strs[i]) shr 1);
      else
        LeftPoint:=0;
      end;
      Canvas.TextRect(ARect,LeftPoint,ARect.Top+2,Strs[i]);
      ARect.Top:=ARect.Top+LineHeight+2;
    end;
    Strs.Free;
    if [dgRowLines, dgColLines]*Options=[dgRowLines, dgColLines] then
    begin
      DrawEdge(Canvas.Handle, TitleRect, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
      DrawEdge(Canvas.Handle, TitleRect, BDR_RAISEDINNER, BF_TOPLEFT);
    end;
  end
  else inherited;

{
with ARect do
  begin
   case fcellstyle of
   csRaised:  drawrect(left,top,right,bottom-1,clWindow,clBtnShadow);
   csLowered: drawrect(left,top,right,bottom,clBtnShadow,clWindow);
   end
  end;}
end;

end.
