{%MainUnit cocoaint.pas}
{ $Id: cocoawinapi.inc 15525 2008-06-23 06:39:58Z paul $ }
{******************************************************************************
  All Cocoa Winapi implementations.
  This are the implementations of the overrides of the Cocoa Interface for the
  methods defined in the
  lcl/include/winapi.inc

 ******************************************************************************
 Implementation
 ******************************************************************************

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

//##apiwiz##sps##   // Do not remove, no wizard declaration before this line

{------------------------------------------------------------------------------
  function ShowWindow(hWnd: HWND; nCmdShow: Integer): Boolean;

  nCmdShow:
    SW_SHOWNORMAL, SW_MINIMIZE, SW_SHOWMAXIMIZED
------------------------------------------------------------------------------}

procedure ColorToRGBFloat(cl: TColorRef; var r,g,b: Single); inline;
begin
  R:=(cl and $FF) / $FF;
  G:=((cl shr 8) and $FF) / $FF;
  B:=((cl shr 16) and $FF) / $FF;
end;

function RGBToColorFloat(r,g,b: Single): TColorRef; inline;
begin
  Result:=(Round(b*$FF) shl 16) or (Round(g*$FF) shl 8) or Round(r*$FF);
end;

{--------------------------------- WINDOWS ------------------------------------}

function TCocoaWidgetSet.ShowWindow(hWnd: HWND; nCmdShow: Integer): Boolean;
begin
  {$ifdef VerboseCocoaWinAPI}
    DebugLn('TCocoaWidgetSet.ShowWindow');
  {$endif}

  case nCmdShow of
    SW_SHOW, SW_SHOWNORMAL:
      NSWindow(hwnd).orderFront(nil);
    SW_HIDE:
      NSWindow(hwnd).orderOut(nil);
    SW_MINIMIZE:
      NSWindow(hwnd).miniaturize(nil);
  end;
  Result:=true;
end;

{------------------------------------------------------------------------------
  Method:  GetWindowRect
  Params:  Handle - Handle of window
           Rect   - Record for window coordinates
  Returns: if the function succeeds, the return value is nonzero; if the
           function fails, the return value is zero

  Retrieves the screen bounding rectangle of the specified window
 ------------------------------------------------------------------------------}
function TCocoaWidgetSet.GetWindowRect(Handle: hwnd; var ARect: TRect): Integer;
var
  dx, dy: Integer;
begin
  if Handle<>0 then begin
    ARect:=NSObject(Handle).lclFrame;
    if not NSObject(Handle).isKindOfClass_(NSWindow) then begin
      dx:=0; dy:=0;
      NSObject(Handle).lclLocalToScreen(dx, dx);
      MoveRect(ARect, dx, dy);
    end;
    Result:=1;
  end else
    Result:=0;
end;

function TCocoaWidgetSet.IsWindowEnabled(Handle: HWND): boolean;
begin
  if Handle<>0
    then Result:=NSObject(Handle).lclIsEnabled
    else Result:=False;
end;

function TCocoaWidgetSet.EnableWindow(hWnd: HWND; bEnable: Boolean): Boolean;
begin
  if hWnd<>0
    then NSObject(hWnd).lclSetEnabled(bEnable)
    else Result:=False;
end;

function TCocoaWidgetSet.IsWindowVisible(Handle: HWND): boolean;
begin
  if Handle<>0
    then Result:=NSObject(Handle).lclIsVisible
    else Result:=False;
end;

function TCocoaWidgetSet.GetClientBounds(handle : HWND; var ARect : TRect) : Boolean;
begin
  if Handle<>0 then begin
    Result:=True;
    ARect:=NSObject(handle).lclClientFrame;
  end else
    Result:=False;
end;

function TCocoaWidgetSet.GetClientRect(handle : HWND; var ARect : TRect) : Boolean;
var
  dx, dy: Integer;
begin
  if Handle<>0 then begin
    Result:=True;
    ARect:=NSObject(handle).lclClientFrame;
    dx:=0; dy:=0;
    NSObject(Handle).lclLocalToScreen(dx, dy);
    MoveRect(ARect, dx, dy);
  end else
    Result:=False;
end;

function TCocoaWidgetSet.GetParent(Handle : HWND): HWND;
begin
  if Handle<>0 then
    Result:=HWND(NSObject(Handle).lclParent)
  else
    Result:=0;
end;

function TCocoaWidgetSet.GetWindowRelativePosition(Handle: hwnd; var Left, Top: Integer): boolean;
begin
  if Handle<>0 then begin
    Result:=True;
    NSObject(handle).lclRelativePos(Left, Top);
  end else
    Result:=False;
end;

function TCocoaWidgetSet.GetWindowSize(Handle: hwnd; var Width, Height: Integer): boolean;
var
  r   : TRect;
begin
  if Handle<>0 then begin
    Result:=True;
    r:=NSObject(Handle).lclFrame;
    Width:=R.Right-R.Left;
    Height:=R.Bottom-R.Top;
  end else
    Result:=False;
end;

function TCocoaWidgetSet.InvalidateRect(aHandle : HWND; Rect : pRect; bErase : Boolean): Boolean;
begin
  if aHandle<>0 then begin
    Result:=True;
    if Assigned(Rect)
      then NSObject(aHandle).lclInvalidateRect(Rect^)
      else NSObject(aHandle).lclInvalidate;
  end else
    Result:=False;
end;

function TCocoaWidgetSet.UpdateWindow(Handle: HWND): Boolean;
begin
  Result:=InvalidateRect(Handle, nil, false);
end;

function TCocoaWidgetSet.GetProp(Handle : hwnd; Str : PChar): Pointer;
begin
  Result:=nil;
end;

function TCocoaWidgetSet.SetProp(Handle: hwnd; Str : PChar; Data : Pointer) : Boolean;
begin
  Result:=False;
end;

{----------------------------- WINDOWS SCROLLING ------------------------------}

function TCocoaWidgetSet.GetScrollBarSize(Handle: HWND; BarKind: Integer): integer;
begin
  Result:=0;
end;

function TCocoaWidgetSet.GetScrollbarVisible(Handle: HWND; SBStyle: Integer): boolean;
begin
  Result:=False;
end;

function TCocoaWidgetSet.GetScrollInfo(Handle: HWND; BarFlag: Integer; Var ScrollInfo: TScrollInfo): Boolean;
begin
  Result:=False;
end;

function TCocoaWidgetSet.SetScrollInfo(Handle : HWND; SBStyle : Integer; ScrollInfo: TScrollInfo; bRedraw : Boolean): Integer;
begin
  Result:=0;
end;

function TCocoaWidgetSet.ShowScrollBar(Handle: HWND; wBar: Integer; bShow: Boolean): Boolean;
begin
  Result:=False;
end;

{----------------------------------- DRAWING ----------------------------------}


type
  TPointArray = array [word] of TPoint;
  PPointArray = ^TPointArray;

function TCocoaWidgetSet.LineTo(DC: HDC; X, Y: Integer): Boolean;
var
  ctx : TCocoaContext;
begin
  ctx:=CheckDC(DC);
  Result:=Assigned(ctx);
  if not Result then Exit;

  ctx.LineTo(x,y);
end;

function TCocoaWidgetSet.MoveToEx(DC: HDC; X, Y: Integer; OldPoint: PPoint): Boolean;
var
  ctx : TCocoaContext;
begin
  ctx:=CheckDC(DC);
  Result:=Assigned(ctx);
  if not Result then Exit;

  if Assigned(OldPoint) then OldPoint^:=ctx.PenPos;
  ctx.MoveTo(x,y);
end;

function TCocoaWidgetSet.Polygon(DC: HDC; Points: PPoint; NumPts: Integer; Winding: boolean): boolean;
var
  ctx : TCocoaContext;
begin
  ctx:=CheckDC(DC);
  Result:=Assigned(ctx) and Assigned(Points) and (NumPts>=2);
  if not Result then Exit;

  ctx.Polygon(PPointArray(Points)^, NumPts, Winding);
  Result:=True;
end;

function TCocoaWidgetSet.Polyline(DC: HDC; Points: PPoint; NumPts: Integer): boolean;
var
  ctx : TCocoaContext;
begin
  ctx:=CheckDC(DC);
  Result:=Assigned(ctx) and Assigned(Points) and (NumPts>0);
  if not Result then Exit;

  ctx.Polyline(PPointArray(Points)^, NumPts);
  Result:=True;
end;

function TCocoaWidgetSet.Rectangle(DC: HDC; X1, Y1, X2, Y2: Integer): Boolean;
var
  ctx : TCocoaContext;
begin
  ctx:=CheckDC(DC);
  Result:=Assigned(ctx);
  if not Result then Exit;

  ctx.Rectangle(X1, Y1, X2, Y2, False, nil);
  Result:=True;
end;

function TCocoaWidgetSet.FillRect(DC: HDC; const Rect: TRect; Brush: HBRUSH): Boolean;
var
  ctx : TCocoaContext;
  br  : TCocoaGDIObject;
begin
  ctx:=CheckDC(DC);
  br:=CheckGDIOBJ(Brush);
  Result:=Assigned(ctx) and (not Assigned(br) or (br is TCocoaBrush));
  if not Result then Exit;

  with Rect do
    ctx.Rectangle(Left, Top, Right, Bottom, True, TCocoaBrush(br));
end;

function TCocoaWidgetSet.Ellipse(DC: HDC; x1, y1, x2, y2: Integer): Boolean;
var
  ctx : TCocoaContext;
begin
  ctx:=CheckDC(DC);
  Result:=Assigned(ctx);
  if not Result then Exit;

  ctx.Ellipse(x1, y1, x2, y2);
end;

{----------------------------------- REGION -----------------------------------}

{------------------------------------------------------------------------------
  Method:  CreatePolygonRgn
  Params:  Points   - Pointer to array of polygon points
           NumPts   - Number of points passed
           FillMode - Filling mode
  Returns: The new polygonal region

  Creates a new polygonal region from the specified points
 ------------------------------------------------------------------------------}
function TCocoaWidgetSet.CreatePolygonRgn(Points: PPoint; NumPts: Integer;
  FillMode: integer): HRGN;
begin
  {$IFDEF VerboseWinAPI}
    DebugLn('TCocoaWidgetSet.CreatePolygonRgn NumPts: ' + DbgS(NumPts) +
      ' FillMode: ' + DbgS(FillMode));
  {$ENDIF}

  Result := HRGN(TCocoaRegion.Create(Points, NumPts, FillMode=ALTERNATE));
end;

function CocoaCombineMode(fnCombineMode: Integer): TCocoaCombine;
begin
  case fnCombineMode of
    RGN_AND:  Result:=cc_And;
    RGN_OR:   Result:=cc_Or;
    RGN_XOR:  Result:=cc_Xor;
    RGN_DIFF: Result:=cc_Diff;
  else
    Result:=cc_Copy;
  end;
end;

function TCocoaWidgetSet.CombineRgn(Dest, Src1, Src2: HRGN;
  fnCombineMode: Longint): Longint;
begin
  Result := LCLType.Error;
  if (Dest = 0) or (Src1 = 0) or (fnCombineMode<RGN_AND) or (fnCombineMode>RGN_COPY) then Exit;
  if (fnCombineMode <> RGN_COPY) and (Src2 = 0) then Exit;

  TCocoaRegion(Dest).CombineWith(TCocoaRegion(Src1), cc_Copy);

  if fnCombineMode <> RGN_COPY then
    TCocoaRegion(Dest). CombineWith(TCocoaRegion(Src2), CocoaCombineMode(fnCombineMode));
end;

function TCocoaWidgetSet.CreateRectRgn(X1, Y1, X2, Y2: Integer): HRGN;
begin
  {$IFDEF VerboseWinAPI}
    DebugLn('TCocoaWidgetSet.CreateRectRgn R: ' + DbgS(Classes.Rect(X1, Y1, X2, Y2)));
  {$ENDIF}

  Result := HRGN(TCocoaRegion.Create(X1, Y1, X2, Y2));
end;

//todo:
//function TCocoaWidgetSet.CreateEllipticRgn(p1, p2, p3, p4: Integer): HRGN;
//begin
//end;

{---------------------------- PEN AND BRUSH -----------------------------------}

function TCocoaWidgetSet.CreatePenIndirect(const LogPen: TLogPen): HPEN;
var
  p   : TCocoaPen;
  cl  : DWORD;
begin
  {$IFDEF VerboseWinAPI}
    DebugLn('TCocoaWidgetSet.CreatePenIndirect');
  {$ENDIF}
  p:=TCocoaPen.Create;
  if LogPen.lopnWidth.x>0 then p.Width:=LogPen.lopnWidth.x;
  p.Style:=LogPen.lopnStyle;
  if LogPen.lopnColor and $8000000 > 0 then cl:=GetSysColor(LogPen.lopnColor)
  else cl:=LogPen.lopnColor;
  //todo:!
  ColorToRGBFloat(cl, p.R, p.G, p.B);
  Result := HPEN(p);//TCocoaPen.Create(LogPen));
end;

function TCocoaWidgetSet.CreateBrushIndirect(const LogBrush: TLogBrush): HBRUSH;
var
  b     : TCocoaBrush;
begin
  b:=TCocoaBrush.Create;
  with b do ColorToRGBFloat(LogBrush.lbColor, R, G, B);
  Result:=HBRUSH(b);
end;

{------------------------------- SYNC OBJECTS ---------------------------------}

procedure TCocoaWidgetSet.InitializeCriticalSection(var CritSection: TCriticalSection);
begin
  CritSection:=TCriticalSection(NSRecursiveLock.alloc);
end;

procedure TCocoaWidgetSet.DeleteCriticalSection(var CritSection: TCriticalSection);
begin
  if CritSection=0 then Exit;
  NSRecursiveLock(CritSection).release;
  CritSection:=0;
end;

type
  //workaround for CocoaInt bug
  NSLockExtension = objccategory(NSRecursiveLock)
    procedure lock; message 'lock';
    procedure unlock; message 'unlock';
  end; external;

procedure TCocoaWidgetSet.EnterCriticalSection(var CritSection: TCriticalSection);
begin
  if CritSection=0 then Exit;
  NSRecursiveLock(CritSection).lock;
end;

procedure TCocoaWidgetSet.LeaveCriticalSection(var CritSection: TCriticalSection);
begin
  if CritSection=0 then Exit;
  NSRecursiveLock(CritSection).unlock;
end;

{------------------------------- DEVICE CONTEXT -------------------------------}

function TCocoaWidgetSet.GetDC(hWnd: HWND): HDC;
begin
  if hWnd=0 then begin
    if not Assigned(ScreenContext) then ScreenContext:=TCocoaContext.Create;
    Result:=HDC(ScreenContext);
  end else
    //todo:!
    Result:=0;
end;

function TCocoaWidgetSet.DeleteObject(GDIObject: HGDIOBJ): Boolean;
var
  gdi: TCocoaGDIObject;
begin
  Result:=True;
  gdi:=CheckGDIOBJ(GdiObject);
  if Assigned(gdi) then gdi.Release;
end;

function TCocoaWidgetSet.SelectObject(ADC: HDC; GDIObj: HGDIOBJ): HGDIOBJ;
var
  dc: TCocoaContext;
  gdi: TCocoaGDIObject;
const
  SName = 'TCarbonWidgetSet.SelectObject';
begin
  {$IFDEF VerboseWinAPI}
    DebugLn('TCocoaWidgetSet.SelectObject DC: ' + DbgS(DC) + ' GDIObj: ' +  DbgS(GDIObj));
  {$ENDIF}
  Result := 0;

  dc:=CheckDC(ADC);
  gdi:=CheckGDIOBJ(GDIObj);
  if not Assigned(dc) then Exit;

  if gdi is TCocoaBrush then begin // select brush
    Result := HBRUSH(dc.Brush);
    dc.Brush := TCocoaBrush(gdi);
  end else if gdi is TCocoaPen then begin // select pen
    Result := HPEN(dc.Pen);
    dc.Pen := TCocoaPen(gdi);
  end else if gdi is TCocoaFont then begin // select font
    Result := HFONT(dc.Font);
    dc.Font := TCocoaFont(gdi);
  end else if gdi is TCocoaRegion then begin // select region
    Result := HBRUSH(dc.Region);
    dc.Region := TCocoaRegion(gdi);
  end else if gdi is TCocoaBitmap then begin // select bitmap
    {if not (ADC is TCarbonBitmapContext) then
    begin
      DebugLn(SName + ' Error - The specified device context is not bitmap context!');
      Exit;
    end;}
    Result := HBITMAP(dc.Bitmap);
    dc.Bitmap:=TCocoaBitmap(gdi);
    //TCarbonBitmapContext(ADC).Bitmap := TCarbonBitmap(GDIObj);
  end;

  if Result<>0 then TCocoaGDIObject(Result).Release;
  if Assigned(gdi) then gdi.AddRef;

  {$IFDEF VerboseWinAPI}
    DebugLn('TCocoaWidgetSet.SelectObject Result: ' + DbgS(Result));
  {$ENDIF}
end;

function TCocoaWidgetSet.RectVisible(DC: HDC; const ARect: TRect): Boolean;
var
  ClipBox: CGRect;
  ctx : TCocoaContext;
  R: TRect;
begin
  Result := False;

  {$IFDEF VerboseWinAPI}
    DebugLn('TCarbonWidgetSet.RectVisible DC: ' + DbgS(DC) + ' R: ' + DbgS(ARect));
  {$ENDIF}

  ctx:=CheckDC(DC);
  if not Assigned(ctx) or (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top) then Exit;

  // In Quartz 2D there is no direct access to clipping path of CGContext,
  // therefore we can only test bounding box of the clipping path.

  ClipBox := CGContextGetClipBoundingBox(ctx.CGContext);
  Result := IntersectRect(R, ARect, CGRectToRect(ClipBox));

  {$IFDEF VerboseWinAPI}
    DebugLn('TCarbonWidgetSet.RectVisible Result: ' + DbgS(Result) + ' Clip: ' + DbgS(CGRectToRect(ClipBox)));
  {$ENDIF}
end;

function TCocoaWidgetSet.MoveWindowOrgEx(DC: HDC; dX, dY: Integer): Boolean;
var
  ctx : TCocoaContext;
begin
  Result := False;
  ctx:=CheckDC(DC);
  if not Assigned(ctx) then Exit;

  {$IFDEF VerboseWinAPI}
  DebugLn('TCarbonWidgetSet.MoveWindowOrgEx DC: ' + DbgS(DC) + ' ' + DbgS(DX) + ', ' + DbgS(DY));
  {$ENDIF}
  ctx.SetOrigin(dX, dY);
  Result := True;
end;

function TCocoaWidgetSet.GetWindowOrgEx(dc : hdc; P : PPoint): Integer;
var
  ctx : TCocoaContext;
begin
  ctx:=CheckDC(dc);
  if not Assigned(ctx) or not Assigned(P) then
    Result:=0
  else begin
    ctx.GetOrigin(p^.X, p^.Y);
    Result:=1;
  end;
end;

{------------------------------- FONT AND TEXT --------------------------------}

function TCocoaWidgetSet.CreateFontIndirect(const LogFont: TLogFont): HFONT;
begin
  Result:=CreateFontIndirectEx(LogFont, LogFont.lfFaceName);
end;

function TCocoaWidgetSet.CreateFontIndirectEx(const LogFont: TLogFont;
  const LongFontName: string): HFONT;
var
  cf  : TCocoaFont;
begin
  cf:=TCocoaFont.Create;
  cf.Size:=LogFont.lfHeight;
  cf.Name:=LongFontName;
  if LogFont.lfWeight>FW_NORMAL then Include(cf.Style, cfs_Bold);
  if LogFont.lfItalic>0 then Include(cf.Style, cfs_Italic);
  if LogFont.lfUnderline>0 then Include(cf.Style, cfs_Underline);
  if LogFont.lfStrikeOut>0 then Include(cf.Style, cfs_Strikeout);
  cf.Antialiased:=logFont.lfQuality>=ANTIALIASED_QUALITY;
  Result:=HFONT(cf);
end;

function TCocoaWidgetSet.ExtTextOut(DC: HDC; X, Y: Integer; Options: Longint;
  Rect: PRect; Str: PChar; Count: Longint; Dx: PInteger): Boolean;
var
  ctx : TCocoaContext;
begin
  ctx:=CheckDC(DC);
  Result:=Assigned(ctx);
  if not Assigned(ctx) then Exit;
  ctx.TextOut(X,Y, Str, Count, Dx);
end;

function TCocoaWidgetSet.SetTextColor(DC: HDC; Color: TColorRef): TColorRef;
var
  ctx : TCocoaContext;
begin
  ctx:=CheckDC(DC);
  if not Assigned(ctx) then begin
    Result:=0;
    Exit;
  end;
  with ctx do begin
    Result:=RGBToColorFloat(TR, TG, TB);
    ColorToRGBFloat(Color, TR, TG, TB);
  end;
end;

function TCocoaWidgetSet.GetTextColor(DC: HDC) : TColorRef;
var
  ctx : TCocoaContext;
begin
  ctx:=CheckDC(DC);
  if not Assigned(ctx) then begin
    Result:=0;
    Exit;
  end;
  with ctx do Result:=RGBToColorFloat(TR, TG, TB);
end;

function TCocoaWidgetSet.TextOut(DC: HDC; X,Y : Integer; Str : Pchar; Count: Integer) : Boolean;
begin
  Result:=ExtTextOut(DC, X, Y, 0, nil, Str, Count, nil);
end;

function TCocoaWidgetSet.EnumFontFamiliesEx(DC: HDC; lpLogFont: PLogFont;
  Callback: FontEnumExProc; Lparam: LParam; Flags: dword): longint;
var
  fontManager : NSFontManager;
  arr         : NSArray;
  fname       : NSString;
  i           : Integer;

  ELogFont    : TEnumLogFontEx;
  Metric      : TNewTextMetricEx;
  FontName    : AnsiString;
begin
  Result:=0;
  if not Assigned(Callback) then Exit;
  fontManager:=NSFontManager.sharedFontManager;
  arr:=fontManager.availableFontFamilies;
  for i:=0 to arr.count-1 do begin
    fname:=NSString(arr.objectAtIndex(i));
    try
      FontName:=NSStringToString(fname);
      FillChar(ELogFont, SizeOf(ELogFont), #0);
      FillChar(Metric, SizeOf(Metric), #0);
      ELogFont.elfLogFont.lfFaceName := FontName;
      ELogFont.elfFullName := FontName;
      //todo: read the data from all fonts of the fontfamily
      Result:=CallBack(ELogFont, Metric, TRUETYPE_FONTTYPE, lparam);
      if Result=0 then Break;
    except
      Break;
    end;
  end;
  arr.release;
end;

function TCocoaWidgetSet.SaveDC(DC: HDC): Integer;
var
  ctx : TCocoaContext;
  cg  : CGContextRef;
begin
  ctx := CheckDC(DC);
  if not Assigned(ctx) then begin
    Result:=0;
    Exit;
  end;
  cg:=ctx.CGContext;
  if Assigned(cg) then begin
    CGContextSaveGState(cg);
    inc(ctx.Stack);
    Result:=ctx.Stack;
  end else
    Result:=0;
end;

function TCocoaWidgetSet.RestoreDC(DC: HDC; SavedDC: Integer): Boolean;
var
  ctx : TCocoaContext;
  cg  : CGContextRef;
  cnt : Integer;
  i   : Integer;
begin
  Result:=False;
  ctx := CheckDC(DC);
  cg:=ctx.CGContext;
  if not Assigned(ctx) or not Assigned(cg) then Exit;

  if SavedDC<0 then cnt:=1
  else cnt:=ctx.Stack-SavedDC+1;
  Result:=cnt>0;

  if Result then begin
    for i:=1 to cnt do CGContextRestoreGState(cg);
    dec(ctx.Stack, cnt);
  end;
end;

//##apiwiz##eps##   // Do not remove, no wizard declaration after this line
