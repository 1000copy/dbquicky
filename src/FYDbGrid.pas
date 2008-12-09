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
  dbclient,ADODB,db,FlatSB;

type
  TFYDBGrid = class(TCustomDBGrid)
  private
    FBorderColor: TColor;
    FFlatScrollBars : Boolean;
    FColorLine: TColor;
    FSingleColor: TColor;
    FDoubleColor: TColor;
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

  if GdSelected in State then  exit;
  if DataSource.DataSet.RecNo mod 2<>0 then
    Canvas.Brush.Color:= FSingleColor   //读取单横颜色值。。。  
  else Canvas.Brush.Color:=FDoubleColor; // 读取双横颜色值。$00F7E7E7。。 
  DefaultDrawColumnCell(Rect, DataCol, Column, State);
//  Canvas.Pen.Color:=$00FBE1C8;
 { Canvas.MoveTo(Rect.Left,Rect.Bottom);
  Canvas.LineTo(Rect.Right,Rect.Bottom);
  Canvas.MoveTo(Rect.Right,Rect.Top);
  Canvas.LineTo(Rect.Right,Rect.Bottom);  }
  Canvas.Brush.Color:=FColorLine;      //选择线型颜色。。。
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

  //对表格进行绘制

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


end.
