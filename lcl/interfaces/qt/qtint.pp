{ $Id$ }
{ 
 /*************************************************************************** 
                         QTINT.pp  -  QTInterface Object
                             ------------------- 
 
                   Initial Revision  : Thu July 1st CST 1999 
 
 
 ***************************************************************************/ 
 
 *****************************************************************************
 *                                                                           *
 *  This file is part of the Lazarus Component Library (LCL)                 *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    * 
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}
 
unit qtint;
 
{$mode objfpc}{$H+}

interface

{$I qtdefines.inc}

{$ifdef Trace}
{$ASSERTIONS ON}
{$endif}
 
uses 
  {$IFDEF MSWINDOWS}
  Windows, // used to retrieve correct caption color values
  {$ENDIF}
  // Bindings - qt4 must come first to avoid type redefinition problems
  qt4,
  // FPC
  Classes, SysUtils, Math, Types, maps,
  // LCL
  InterfaceBase, LCLProc, LCLType, LMessages, LCLMessageGlue, LCLStrConsts,
  Controls, ExtCtrls, Forms,
  Dialogs, StdCtrls, Comctrls, LCLIntf, GraphType, GraphUtil, Themes,
  Arrow, CheckLst,
  // WS
  qtproc;

type
  { TQtWidgetSet }

  TQtWidgetSet = Class(TWidgetSet)
  private
    App: QApplicationH;

    // cache for WindowFromPoint
    FLastWFPMousePos: TPoint;
    FLastWFPResult: HWND;

    FEatNextDeactivate: Boolean;
    FOverrideCursor: TObject;
    SavedDCList: TFPList;
    CriticalSection: TRTLCriticalSection;
    SavedHandlesList: TMap;
    FSocketEventMap: TMap;
    StayOnTopList: TMap;
    // global hooks
    FAppEvenFilterHook: QObject_hookH;
    FAppFocusChangedHook: QApplication_hookH;

    FDockImage: QRubberBandH;
    FDragImageList: QWidgetH;
    FDragHotSpot: TPoint;
    FDragImageLock: Boolean;
    FCachedColors: array[0..MAX_SYS_COLORS] of PLongWord;
    FSysColorBrushes: array[0..MAX_SYS_COLORS] of HBrush;
    procedure ClearCachedColors;
    procedure SetOverrideCursor(const AValue: TObject);
    procedure QtRemoveStayOnTop(const ASystemTopAlso: Boolean = False);
    procedure QtRestoreStayOnTop(const ASystemTopAlso: Boolean = False);
  protected
    FStockNullBrush: HBRUSH;
    FStockBlackBrush: HBRUSH;
    FStockLtGrayBrush: HBRUSH;
    FStockGrayBrush: HBRUSH;
    FStockDkGrayBrush: HBRUSH;
    FStockWhiteBrush: HBRUSH;

    FStockNullPen: HPEN;
    FStockBlackPen: HPEN;
    FStockWhitePen: HPEN;
    FStockSystemFont: HFONT;
    FStockDefaultDC: HDC;
    
    function CreateThemeServices: TThemeServices; override;
    function EventFilter(Sender: QObjectH; Event: QEventH): Boolean; cdecl;
    procedure FocusChanged(old: QWidgetH; now: QWidgetH); cdecl;
    procedure OnWakeMainThread(Sender: TObject);
  public
    function LCLPlatform: TLCLPlatform; override;
    function  GetLCLCapability(ACapability: TLCLCapability): PtrUInt; override;
    // Application
    procedure AppInit(var ScreenInfo: TScreenInfo); override;
    procedure AppRun(const ALoop: TApplicationMainLoop); override;
    procedure AppWaitMessage; override;
    procedure AppProcessMessages; override;
    procedure AppTerminate; override;
    procedure AppMinimize; override;
    procedure AppRestore; override;
    procedure AppBringToFront; override;
    procedure AppSetIcon(const Small, Big: HICON); override;
    procedure AppSetTitle(const ATitle: string); override;
    function AppRemoveStayOnTopFlags(const ASystemTopAlso: Boolean = False): Boolean; override;
    function AppRestoreStayOnTopFlags(const ASystemTopAlso: Boolean = False): Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function  DCGetPixel(CanvasHandle: HDC; X, Y: integer): TGraphicsColor; override;
    procedure DCSetPixel(CanvasHandle: HDC; X, Y: integer; AColor: TGraphicsColor); override;
    procedure DCRedraw(CanvasHandle: HDC); override;
    procedure DCSetAntialiasing(CanvasHandle: HDC; AEnabled: Boolean); override;
    procedure SetDesigning(AComponent: TComponent); override;

    // create and destroy
    function CreateTimer(Interval: integer; TimerFunc: TWSTimerProc): THandle; override;
    function DestroyTimer(TimerHandle: THandle): boolean; override;

    // device contexts
    function IsValidDC(const DC: HDC): Boolean; virtual;
    function IsValidGDIObject(const GDIObject: HGDIOBJ): Boolean; virtual;

    // qt object handles map
    procedure AddHandle(AHandle: TObject);
    procedure RemoveHandle(AHandle: TObject);
    function IsValidHandle(AHandle: HWND): Boolean;

    // cache for WindowFromPoint to reduce very expensive calls
    // of QApplication_widgetAt() inside WindowFromPoint().
    function IsWidgetAtCache(AHandle: HWND): Boolean;
    procedure InvalidateWidgetAtCache;
    function IsValidWidgetAtCachePointer: Boolean;
    function GetWidgetAtCachePoint: TPoint;

    // drag image list
    function DragImageList_BeginDrag(AImage: QImageH; AHotSpot: TPoint): Boolean;
    procedure DragImageList_EndDrag;
    function DragImageList_DragMove(X, Y: Integer): Boolean;
    function DragImageList_SetVisible(NewVisible: Boolean): Boolean;
  public
    {$IFDEF HASX11}
    FLastMinimizeEvent: DWord; // track mainform minimize events -> TQtMainWindow.EventFilter
    {$ENDIF}
    function CreateDefaultFont: HFONT; virtual;
    function GetQtDefaultDC: HDC; virtual;
    procedure DeleteDefaultDC; virtual;
    procedure SetQtDefaultDC(Handle: HDC); virtual;
    procedure InitStockItems;
    procedure FreeStockItems;
    procedure FreeSysColorBrushes(const AInvalidateHandlesOnly: Boolean = False);

    property DragImageLock: Boolean read FDragImageLock write FDragImageLock;
    property OverrideCursor: TObject read FOverrideCursor write SetOverrideCursor;

    {$I qtwinapih.inc}
    {$I qtlclintfh.inc}
  end;


type
  TEventProc = record
    Name : String[25];
    CallBack : procedure(Data : TObject);
    Data : Pointer;
  end;

  CallbackProcedure = procedure (Data : Pointer);

  pTRect = ^TRect;

  procedure EventTrace(message : string; data : pointer);
  function HwndFromWidgetH(const WidgetH: QWidgetH): HWND;
  function DTFlagsToQtFlags(const Flags: Cardinal): Integer;
  function GetQtVersion: String;
  function QtVersionCheck(const AMajor, AMinor, AMicro: Integer): Boolean;
  {$IFDEF HASX11}
  function IsCurrentDesktop(AWidget: QWidgetH): Boolean;
  function GetWindowManager: String;
  procedure SetSkipX11Taskbar(Widget: QWidgetH; const ASkipTaskBar: Boolean);
  {$ENDIF}

const
   QtVersionMajor: Integer = 0;
   QtVersionMinor: Integer = 0;
   QtVersionMicro: Integer = 0;
   TargetEntrys = 3;
   QEventLCLMessage = QEventUser;
   LCLQt_CheckSynchronize = QEventType(Ord(QEventUser) + $1001);
   LCLQt_PopupMenuClose = QEventType(Ord(QEventUser) + $1002);
   LCLQt_PopupMenuTriggered = QEventType(Ord(QEventUser) + $1003);
   // QEventType(Ord(QEventUser) + $1004 is reserved by
   // LCLQt_ClipboardPrimarySelection (qtobjects) to reduce includes !

var
  QtWidgetSet: TQtWidgetSet;

implementation

uses 
////////////////////////////////////////////////////
// I M P O R T A N T
////////////////////////////////////////////////////
// To get as little as possible circles,
// uncomment only those units with implementation
////////////////////////////////////////////////////
 {$IFDEF HASX11}
 XAtom, X, XLib,
 {$ENDIF}
 QtWSFactory,
 QtCaret,
 QtThemes,
////////////////////////////////////////////////////
  Graphics, buttons, Menus,
  // Bindings
  qtprivate, qtwidgets, qtobjects;


const
  KEYMAP_VKUNKNOWN = $10000;
  KEYMAP_TOGGLE    = $20000;
  KEYMAP_EXTENDED  = $40000;

function DTFlagsToQtFlags(const Flags: Cardinal): Integer;
const
  QtTextSingleLine            = $0100;
  QtTextDontClip              = $0200;
  QtTextExpandTabs            = $0400;
  QtTextShowMnemonic          = $0800;
  QtTextWordWrap              = $1000;
  QtTextWrapAnywhere          = $2000;
  QtTextHideMnemonic          = $8000;
  QtTextDontPrint             = $4000;
  QtTextIncludeTrailingSpaces =	$08000000;
  QtTextJustificationForced   = $10000;
begin
  Result := 0;
  // horizontal alignment
  if Flags and DT_CENTER <> 0 then
    Result := Result or  QtAlignHCenter
  else
  if Flags and DT_RIGHT <> 0 then
    Result := Result or QtAlignRight
  else
    Result := Result or QtAlignLeft;
  // vertical alignment
  if Flags and DT_VCENTER <> 0 then
    Result := Result or QtAlignVCenter
  else
  if Flags and DT_BOTTOM <> 0 then
    Result := Result or QtAlignBottom
  else
    Result := Result or QtAlignTop;

  // mutually exclusive wordbreak and singleline
  if Flags and DT_WORDBREAK <> 0 then
    Result := Result or QtTextWordWrap
  else
  if Flags and DT_SINGLELINE <> 0 then
    Result := Result or QtTextSingleLine;

  if Flags and DT_NOPREFIX = 0 then
    Result := Result or QtTextShowMnemonic;

  if Flags and DT_NOCLIP <> 0 then
    Result := Result or QtTextDontClip;

  if Flags and DT_EXPANDTABS <> 0 then
    Result := Result or QtTextExpandTabs;
end;
  
procedure EventTrace(message: string; data: pointer);
begin

end;

function QtObjectFromWidgetH(const WidgetH: QWidgetH): TQtWidget;
var
  V: QVariantH;
  Ok: Boolean;
  QtWg: TQtWidget;
begin
  Result := nil;
  
  if WidgetH = nil then
    exit;
    
  V := QVariant_Create();
  try
    QObject_property(QObjectH(WidgetH), V, 'lclwidget');
    if not QVariant_IsNull(v) and QVariant_isValid(V) then
    begin
      //Write('Got a valid variant .. ');
{$IFDEF CPU32}
      QtWg := TQtWidget(QVariant_toUint(V, @Ok));
{$ENDIF}
{$IFDEF CPU64}
      QtWg := TQtWidget(QVariant_toULongLong(V, @Ok));
{$ENDIF}
      if OK then
      begin
        //Write('Converted successfully, Control=');
        if QtWg<>nil then
        begin
          Result := QtWg;
          //WriteLn(Result.LCLObject.Name);
        end else
          ;//WriteLn('nil');
      end else
        ;//WriteLn('Can''t convert to UINT');
    end else
      ;//Writeln('GetFocus: Variant is NULL or INVALID');
  finally
    QVariant_Destroy(V);
  end;
end;

function HwndFromWidgetH(const WidgetH: QWidgetH): HWND;
begin
  Result := 0;
  if WidgetH = nil then
    exit;
  Result := HWND(QtObjectFromWidgetH(WidgetH));
end;

function GetFirstQtObjectFromWidgetH(WidgetH: QWidgetH): TQtWidget;
begin
  Result := nil;
  if WidgetH = nil then
    Exit;
  repeat
    Result := QtObjectFromWidgetH(WidgetH);
    if Result = nil then
    begin
      WidgetH := QWidget_parentWidget(WidgetH);
      if WidgetH = nil then
        break;
    end;
  until Result <> nil;
end;

{------------------------------------------------------------------------------
  Method: GetQtVersion
  Params:  none
  Returns: String

  Returns current Qt lib version used by application.
 ------------------------------------------------------------------------------}
function GetQtVersion: String;
begin
  Result := QtVersion;
end;

procedure QtVersionInt(out AMajor, AMinor, AMicro: integer);
var
  S: String;
  i: Integer;
  sLen: integer;
begin
  AMajor := 0;
  AMinor := 0;
  AMicro := 0;
  S := GetQtVersion;
  sLen := length(S);

  // 5 is usual length of qt version eg. 4.6.3
  if sLen < 5 then
    exit;
  if sLen = 5 then
  begin
    TryStrToInt(S[1], AMajor);
    TryStrToInt(S[3], AMinor);
    TryStrToInt(S[5], AMicro);
  end else
  begin
    i := Pos('.', S);
    // major
    if i > 0 then
    begin
      TryStrToInt(Copy(S, 1, i -1), AMajor);
      Delete(S, 1, i - 1);
    end;
    // minor
    i := Pos('.', S);
    if i > 0 then
    begin
      TryStrToInt(Copy(S, 1, i -1), AMinor);
      Delete(S, 1, i - 1);
    end;
    // micro
    i := Pos('.', S);
    if i > 0 then
      TryStrToInt(Copy(S, 1, i -1), AMinor);
  end;
end;

{------------------------------------------------------------------------------
  Method: QtVersionCheck
  Params:  AMajor, AMinor, AMicro: Integer
  Returns: Boolean

  Function checks if qt lib version satisfies our function params values.
  Returns TRUE if successfull.
  It is possible to check Major and/or Minor version only (or any of those
  3 params) by setting it's param to -1.
  eg. QtVersionCheck(4, 5, -1) checks only major and minor version and will
  not process micro version check.
  NOTE: It checks qt lib version used by application.
 ------------------------------------------------------------------------------}
function QtVersionCheck(const AMajor, AMinor, AMicro: Integer): Boolean;
begin
  Result := False;
  if AMajor > 0 then
    Result := AMajor = QtVersionMajor;
  if (AMajor > 0) and not Result then
    exit;
  if AMinor >= 0 then
    Result := AMinor = QtVersionMinor;
  if (AMinor >= 0) and not Result then
    exit;
  if AMicro >= 0 then
    Result := AMicro = QtVersionMicro;
end;

{$IFDEF HASX11}
{$I qtx11.inc}
{$ENDIF}
{$I qtobject.inc}
{$I qtwinapi.inc}
{$I qtlclintf.inc}

end.
