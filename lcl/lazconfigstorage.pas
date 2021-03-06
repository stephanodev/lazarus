{
 *****************************************************************************
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************

  Author: Mattias Gaertner

  Abstract:
    This unit defines various base classes for loading and saving of configs.
}
unit LazConfigStorage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, AvgLvlTree, LCLProc;
  
type
  { TConfigStorage }

  TConfigStorage = class
  private
    FPathStack: TStrings;
    FCurrentBasePath: string;
  protected
    function  GetFullPathValue(const APath, ADefault: String): String; virtual; abstract;
    function  GetFullPathValue(const APath: String; ADefault: Integer): Integer; virtual; abstract;
    function  GetFullPathValue(const APath: String; ADefault: Boolean): Boolean; virtual; abstract;
    procedure SetFullPathValue(const APath, AValue: String); virtual; abstract;
    procedure SetDeleteFullPathValue(const APath, AValue, DefValue: String); virtual; abstract;
    procedure SetFullPathValue(const APath: String; AValue: Integer); virtual; abstract;
    procedure SetDeleteFullPathValue(const APath: String; AValue, DefValue: Integer); virtual; abstract;
    procedure SetFullPathValue(const APath: String; AValue: Boolean); virtual; abstract;
    procedure SetDeleteFullPathValue(const APath: String; AValue, DefValue: Boolean); virtual; abstract;
    procedure DeleteFullPath(const APath: string); virtual; abstract;
    procedure DeleteFullPathValue(const APath: string); virtual; abstract;
  public
    constructor Create(const Filename: string; LoadFromDisk: Boolean); virtual;
    destructor Destroy; override;
    procedure Clear; virtual; abstract;
    function  GetValue(const APath, ADefault: String): String;
    function  GetValue(const APath: String; ADefault: Integer): Integer;
    function  GetValue(const APath: String; ADefault: Boolean): Boolean;
    procedure GetValue(const APath: String; out ARect: TRect;
                       const ADefault: TRect);
    procedure GetValue(const APath: String; out APoint: TPoint;
                       const ADefault: TPoint);
    procedure GetValue(const APath: String; const List: TStrings);
    procedure SetValue(const APath, AValue: String);
    procedure SetDeleteValue(const APath, AValue, DefValue: String);
    procedure SetValue(const APath: String; AValue: Integer);
    procedure SetDeleteValue(const APath: String; AValue, DefValue: Integer);
    procedure SetValue(const APath: String; AValue: Boolean);
    procedure SetDeleteValue(const APath: String; AValue, DefValue: Boolean);
    procedure SetValue(const APath: String; const AValue: TRect);
    procedure SetDeleteValue(const APath: String; const AValue, DefValue: TRect);
    procedure SetValue(const APath: String; const AValue: TPoint);
    procedure SetDeleteValue(const APath: String; const AValue, DefValue: TPoint);
    procedure SetValue(const APath: String; const AValue: TStrings);
    procedure DeletePath(const APath: string);
    procedure DeleteValue(const APath: string);
    property CurrentBasePath: string read FCurrentBasePath;
    function ExtendPath(const APath: string): string;
    procedure AppendBasePath(const Path: string);
    procedure UndoAppendBasePath;
    procedure WriteToDisk; virtual; abstract;
    function GetFilename: string; virtual; abstract;
  end;
  
  TConfigStorageClass = class of TConfigStorage;


  { TConfigMemStorageNode }

  TConfigMemStorageNode = class
  public
    Name: string;
    Value: string;
    Parent: TConfigMemStorageNode;
    Childs: TAvgLvlTree; // tree of TConfigMemStorageNode
    procedure ClearChilds;
    constructor Create(AParent: TConfigMemStorageNode; const AName: string);
    destructor Destroy; override;
  end;

  TConfigMemStorageModification = (cmsmSet, cmsmGet, cmsmDelete, cmsmDeleteValue);

  { TConfigMemStorage }

  TConfigMemStorage = class(TConfigStorage)
  private
    procedure CreateRoot;
    procedure CreateChilds(Node: TConfigMemStorageNode);
    procedure Modify(const APath: string; Mode: TConfigMemStorageModification;
                     var AValue: string);
  protected
    procedure DeleteFullPath(const APath: string); override;
    procedure DeleteFullPathValue(const APath: string); override;
    function GetFullPathValue(const APath, ADefault: String): String; override;
    function GetFullPathValue(const APath: String; ADefault: Boolean): Boolean;
      override;
    function GetFullPathValue(const APath: String; ADefault: Integer): Integer;
      override;
    procedure SetDeleteFullPathValue(const APath, AValue, DefValue: String);
      override;
    procedure SetDeleteFullPathValue(const APath: String; AValue, DefValue:
      Boolean); override;
    procedure SetDeleteFullPathValue(const APath: String; AValue, DefValue:
      Integer); override;
    procedure SetFullPathValue(const APath, AValue: String); override;
    procedure SetFullPathValue(const APath: String; AValue: Boolean); override;
    procedure SetFullPathValue(const APath: String; AValue: Integer); override;
  public
    Root: TConfigMemStorageNode;
    function GetFilename: string; override;
    procedure WriteToDisk; override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure SaveToConfig(Config: TConfigStorage; const APath: string);
    procedure LoadFromConfig(Config: TConfigStorage; const APath: string);
    procedure WriteDebugReport;
  end;

procedure LoadStringToStringTree(Config: TConfigStorage; const Path: string;
                                 Tree: TStringToStringTree);
procedure SaveStringToStringTree(Config: TConfigStorage; const Path: string;
                                 Tree: TStringToStringTree);

function CompareConfigMemStorageNames(p1, p2: PChar): integer;
function CompareConfigMemStorageNodes(Node1, Node2: Pointer): integer;
function ComparePCharWithConfigMemStorageNode(aPChar, ANode: Pointer): integer;

implementation

procedure LoadStringToStringTree(Config: TConfigStorage; const Path: string;
  Tree: TStringToStringTree);
var
  Cnt: LongInt;
  SubPath: String;
  CurName: String;
  CurValue: String;
  i: Integer;
begin
  Tree.Clear;
  Cnt:=Config.GetValue(Path+'Count',0);
  for i:=0 to Cnt-1 do begin
    SubPath:=Path+'Item'+IntToStr(i)+'/';
    CurName:=Config.GetValue(SubPath+'Name','');
    CurValue:=Config.GetValue(SubPath+'Value','');
    Tree.Values[CurName]:=CurValue;
  end;
end;

procedure SaveStringToStringTree(Config: TConfigStorage; const Path: string;
  Tree: TStringToStringTree);
var
  Node: TAvgLvlTreeNode;
  Item: PStringToStringItem;
  i: Integer;
  SubPath: String;
begin
  Config.SetDeleteValue(Path+'Count',Tree.Tree.Count,0);
  Node:=Tree.Tree.FindLowest;
  i:=0;
  while Node<>nil do begin
    Item:=PStringToStringItem(Node.Data);
    SubPath:=Path+'Item'+IntToStr(i)+'/';
    Config.SetDeleteValue(SubPath+'Name',Item^.Name,'');
    Config.SetDeleteValue(SubPath+'Value',Item^.Value,'');
    Node:=Tree.Tree.FindSuccessor(Node);
    inc(i);
  end;
end;

function CompareConfigMemStorageNames(p1, p2: PChar): integer;
// compare strings till / or #0
begin
  if (p1=nil) then begin
    if (p2=nil) or (p2^ in ['/',#0]) then begin
      // both empty
      Result:=0;
    end else begin
      // p1 shorter
      Result:=-1;
    end;
  end else begin
    if p2=nil then begin
      // p2 shorter
      Result:=1;
    end else begin
      repeat
        if p1^ in ['/',#0] then begin
          if p2^ in ['/',#0] then begin
            // same
            exit(0);
          end else begin
            // p1 shorter
            exit(-1);
          end;
        end else begin
          if p2^ in ['/',#0] then begin
            // p2 shorter
            exit(1);
          end else if p1^=p2^ then begin
            // continue
          end else begin
            // differ
            exit(ord(p1^)-ord(p2^));
          end;
        end;
        inc(p1);
        inc(p2);
      until false;
    end;
  end;
end;

function CompareConfigMemStorageNodes(Node1, Node2: Pointer): integer;
var
  CfgNode1: TConfigMemStorageNode absolute Node1;
  CfgNode2: TConfigMemStorageNode absolute Node2;
begin
  Result:=CompareConfigMemStorageNames(PChar(CfgNode1.Name),PChar(CfgNode2.Name));
end;

function ComparePCharWithConfigMemStorageNode(aPChar, ANode: Pointer): integer;
begin
  Result:=CompareConfigMemStorageNames(PChar(aPChar),
                                      PChar(TConfigMemStorageNode(ANode).Name));
end;

{ TConfigStorage }

constructor TConfigStorage.Create(const Filename: string; LoadFromDisk: Boolean
  );
begin

end;

destructor TConfigStorage.Destroy;
begin
  FPathStack.Free;
  inherited Destroy;
end;

function TConfigStorage.GetValue(const APath, ADefault: String): String;
begin
  Result:=GetFullPathValue(ExtendPath(APath),ADefault);
end;

function TConfigStorage.GetValue(const APath: String; ADefault: Integer
  ): Integer;
begin
  Result:=GetFullPathValue(ExtendPath(APath),ADefault);
end;

function TConfigStorage.GetValue(const APath: String; ADefault: Boolean
  ): Boolean;
begin
  Result:=GetFullPathValue(ExtendPath(APath),ADefault);
end;

procedure TConfigStorage.GetValue(const APath: String; out ARect: TRect;
  const ADefault: TRect);
begin
  ARect.Left:=GetValue(APath+'Left',ADefault.Left);
  ARect.Top:=GetValue(APath+'Top',ADefault.Top);
  ARect.Right:=GetValue(APath+'Right',ADefault.Right);
  ARect.Bottom:=GetValue(APath+'Bottom',ADefault.Bottom);
end;

procedure TConfigStorage.GetValue(const APath: String; out APoint: TPoint;
  const ADefault: TPoint);
begin
  APoint.X:=GetValue(APath+'X',ADefault.X);
  APoint.Y:=GetValue(APath+'Y',ADefault.Y);
end;

procedure TConfigStorage.GetValue(const APath: String; const List: TStrings);
var
  NewCount: LongInt;
  i: Integer;
  NewLine: String;
begin
  NewCount:=GetValue(APath+'Count',0);
  for i:=0 to NewCount-1 do begin
    NewLine:=GetValue(APath+'Item'+IntToStr(i+1)+'/Value','');
    if List.Count>i then
      List[i]:=NewLine
    else
      List.Add(NewLine);
  end;
  while List.Count>NewCount do List.Delete(List.Count-1);
end;

procedure TConfigStorage.SetValue(const APath, AValue: String);
begin
  SetFullPathValue(ExtendPath(APath),AValue);
end;

procedure TConfigStorage.SetDeleteValue(const APath, AValue, DefValue: String);
begin
  SetDeleteFullPathValue(ExtendPath(APath),AValue,DefValue);
end;

procedure TConfigStorage.SetValue(const APath: String; AValue: Integer);
begin
  SetFullPathValue(ExtendPath(APath),AValue);
end;

procedure TConfigStorage.SetDeleteValue(const APath: String; AValue,
  DefValue: Integer);
begin
  SetDeleteFullPathValue(ExtendPath(APath),AValue,DefValue);
end;

procedure TConfigStorage.SetValue(const APath: String; AValue: Boolean);
begin
  SetFullPathValue(ExtendPath(APath),AValue);
end;

procedure TConfigStorage.SetDeleteValue(const APath: String; AValue,
  DefValue: Boolean);
begin
  SetDeleteFullPathValue(ExtendPath(APath),AValue,DefValue);
end;

procedure TConfigStorage.SetValue(const APath: String; const AValue: TRect);
begin
  SetValue(APath+'Left',AValue.Left);
  SetValue(APath+'Top',AValue.Top);
  SetValue(APath+'Right',AValue.Right);
  SetValue(APath+'Bottom',AValue.Bottom);
end;

procedure TConfigStorage.SetDeleteValue(const APath: String; const AValue,
  DefValue: TRect);
begin
  SetDeleteValue(APath+'Left',AValue.Left,DefValue.Left);
  SetDeleteValue(APath+'Top',AValue.Top,DefValue.Top);
  SetDeleteValue(APath+'Right',AValue.Right,DefValue.Right);
  SetDeleteValue(APath+'Bottom',AValue.Bottom,DefValue.Bottom);
end;

procedure TConfigStorage.SetValue(const APath: String; const AValue: TPoint);
begin
  SetValue(APath+'X',AValue.X);
  SetValue(APath+'Y',AValue.Y);
end;

procedure TConfigStorage.SetDeleteValue(const APath: String; const AValue,
  DefValue: TPoint);
begin
  SetDeleteValue(APath+'X',AValue.X,DefValue.X);
  SetDeleteValue(APath+'Y',AValue.Y,DefValue.Y);
end;

procedure TConfigStorage.SetValue(const APath: String; const AValue: TStrings);
var
  i: Integer;
begin
  SetDeleteValue(APath+'Count',AValue.Count,0);
  for i:=0 to AValue.Count-1 do
    SetDeleteValue(APath+'Item'+IntToStr(i+1)+'/Value',AValue[i],'');
end;

procedure TConfigStorage.DeletePath(const APath: string);
begin
  DeleteFullPath(ExtendPath(APath));
end;

procedure TConfigStorage.DeleteValue(const APath: string);
begin
  DeleteFullPathValue(ExtendPath(APath));
end;

function TConfigStorage.ExtendPath(const APath: string): string;
begin
  Result:=FCurrentBasePath+APath;
end;

procedure TConfigStorage.AppendBasePath(const Path: string);
begin
  if FPathStack=nil then FPathStack:=TStringList.Create;
  FPathStack.Add(FCurrentBasePath);
  FCurrentBasePath:=FCurrentBasePath+Path;
  if (FCurrentBasePath<>'')
  and (FCurrentBasePath[length(FCurrentBasePath)]<>'/') then
    FCurrentBasePath:=FCurrentBasePath+'/';
end;

procedure TConfigStorage.UndoAppendBasePath;
begin
  if (FPathStack=nil) or (FPathStack.Count=0) then
    raise Exception.Create('TConfigStorage.UndoAppendBasePath');
  FCurrentBasePath:=FPathStack[FPathStack.Count-1];
  FPathStack.Delete(FPathStack.Count-1);
end;

{ TConfigMemStorage }

procedure TConfigMemStorage.CreateRoot;
begin
  Root:=TConfigMemStorageNode.Create(nil,'');
end;

procedure TConfigMemStorage.CreateChilds(Node: TConfigMemStorageNode);
begin
  Node.Childs:=TAvgLvlTree.Create(@CompareConfigMemStorageNodes);
end;

procedure TConfigMemStorage.Modify(const APath: string;
  Mode: TConfigMemStorageModification; var AValue: string);
var
  Node: TConfigMemStorageNode;
  p: PChar;
  StartPos: PChar;
  ChildNode: TAvgLvlTreeNode;
  Child: TConfigMemStorageNode;
  NewName: string;
begin
  //DebugLn(['TConfigMemStorage.Modify APath="',APath,'" Mode=',ord(Mode),' AValue="',AValue,'"']);
  p:=PChar(APath);
  if p=nil then begin
    if Root<>nil then begin
      if Mode in [cmsmDelete,cmsmDeleteValue] then
        Root.Value:='';
      if Mode=cmsmDelete then
        Root.ClearChilds;
    end;
  end else begin
    if Root=nil then begin
      if Mode in [cmsmDelete,cmsmDeleteValue] then exit;
      CreateRoot;
    end;
    Node:=Root;
    repeat
      StartPos:=p;
      while (not (p^ in ['/',#0])) do inc(p);
      //DebugLn(['TConfigMemStorage.Modify Node="',Node.Name,'" StartPos="',StartPos,'"']);
      // child node
      if Node.Childs=nil then begin
        if Mode in [cmsmDelete,cmsmDeleteValue] then exit;
        CreateChilds(Node);
      end;
      ChildNode:=Node.Childs.FindKey(StartPos,@ComparePCharWithConfigMemStorageNode);
      if ChildNode=nil then begin
        if Mode in [cmsmDelete,cmsmDeleteValue] then exit;
        NewName:='';
        SetLength(NewName,p-StartPos);
        if NewName<>'' then
          System.Move(StartPos^,NewName[1],p-StartPos);
        //DebugLn(['TConfigMemStorage.Modify Adding "',NewName,'"']);
        Child:=TConfigMemStorageNode.Create(Node,NewName);
        Node.Childs.Add(Child);
      end else
        Child:=TConfigMemStorageNode(ChildNode.Data);
      Node:=Child;
      if p^='/' then begin
        // next level
        while (p^='/') do inc(p);
      end else begin
        // end of path
        case Mode of
        cmsmSet: Node.Value:=AValue;
        cmsmGet: AValue:=Node.Value;
        cmsmDelete,cmsmDeleteValue:
          begin
            Node.Value:='';
            if Mode=cmsmDelete then
              Node.ClearChilds;
            while (Node<>nil) and ((Node.Childs=nil) or (Node.Childs.Count=0))
            do begin
              Child:=Node;
              Node:=Node.Parent;
              if Root=Child then Root:=nil;
              Child.Free;
            end;
          end;
        end;
        exit;
      end;
    until false;
  end;
end;

procedure TConfigMemStorage.DeleteFullPath(const APath: string);
var
  V: string;
begin
  V:='';
  Modify(APath,cmsmDelete,V);
end;

procedure TConfigMemStorage.DeleteFullPathValue(const APath: string);
var
  V: string;
begin
  V:='';
  Modify(APath,cmsmDeleteValue,V);
end;

function TConfigMemStorage.GetFullPathValue(const APath, ADefault: String
  ): String;
begin
  Result:=ADefault;
  Modify(APath,cmsmGet,Result);
end;

function TConfigMemStorage.GetFullPathValue(const APath: String; ADefault:
  Boolean): Boolean;
var
  s: string;
begin
  if ADefault then
    s := 'True'
  else
    s := 'False';

  s := GetFullPathValue(APath, s);

  if CompareText(s,'TRUE')=0 then
    Result := True
  else if CompareText(s,'FALSE')=0 then
    Result := False
  else
    Result := ADefault;
end;

function TConfigMemStorage.GetFullPathValue(const APath: String; ADefault:
  Integer): Integer;
begin
  Result := StrToIntDef(GetFullPathValue(APath, IntToStr(ADefault)),ADefault);
end;

procedure TConfigMemStorage.SetDeleteFullPathValue(const APath, AValue, DefValue
  : String);
begin
  if AValue=DefValue then
    DeleteFullPathValue(APath)
  else
    SetFullPathValue(APath,AValue);
end;

procedure TConfigMemStorage.SetDeleteFullPathValue(const APath: String; AValue,
  DefValue: Boolean);
begin
  if AValue=DefValue then
    DeleteFullPath(APath)
  else
    SetFullPathValue(APath,AValue);
end;

procedure TConfigMemStorage.SetDeleteFullPathValue(const APath: String; AValue,
  DefValue: Integer);
begin
  if AValue=DefValue then
    DeleteFullPath(APath)
  else
    SetFullPathValue(APath,AValue);
end;

procedure TConfigMemStorage.SetFullPathValue(const APath, AValue: String);
var
  V: String;
begin
  V:=AValue;
  Modify(APath,cmsmSet,V);
end;

procedure TConfigMemStorage.SetFullPathValue(const APath: String; AValue:
  Boolean);
begin
  if AValue then
    SetFullPathValue(APath, 'True')
  else
    SetFullPathValue(APath, 'False');
end;

procedure TConfigMemStorage.SetFullPathValue(const APath: String; AValue:
  Integer);
begin
  SetFullPathValue(APath,IntToStr(AValue));
end;

function TConfigMemStorage.GetFilename: string;
begin
  Result:='';
end;

procedure TConfigMemStorage.WriteToDisk;
begin
  raise Exception.Create('TConfigMemStorage.WriteToDisk invalid operation');
end;

destructor TConfigMemStorage.Destroy;
begin
  FreeAndNil(Root);
  inherited Destroy;
end;

procedure TConfigMemStorage.Clear;
begin
  FreeAndNil(Root);
end;

procedure TConfigMemStorage.SaveToConfig(Config: TConfigStorage;
  const APath: string);

  procedure Save(Node: TConfigMemStorageNode; SubPath: string);
  var
    ChildNode: TAvgLvlTreeNode;
    Child: TConfigMemStorageNode;
    Names: String;
  begin
    if Node=nil then exit;
    if (Node<>Root) then
      SubPath:=SubPath+'_'+Node.Name+'/';
    Config.SetDeleteValue(SubPath+'Value',Node.Value,'');
    Names:='';
    if Node.Childs<>nil then begin
      ChildNode:=Node.Childs.FindLowest;
      while ChildNode<>nil do begin
        Child:=TConfigMemStorageNode(ChildNode.Data);
        if Names<>'' then Names:=Names+'/';
        Names:=Names+Child.Name;
        Save(Child,SubPath);
        ChildNode:=Node.Childs.FindSuccessor(ChildNode);
      end;
    end;
    Config.SetDeleteValue(SubPath+'Childs',Names,'');
  end;

begin
  Save(Root,APath);
end;

procedure TConfigMemStorage.LoadFromConfig(Config: TConfigStorage;
  const APath: string);

  procedure Load(Node: TConfigMemStorageNode; SubPath: string);
  var
    ChildNames: string;
    ChildName: string;
    p: PChar;
    StartPos: PChar;
    Child: TConfigMemStorageNode;
  begin
    if Node=nil then exit;
    if (Node<>Root) then
      SubPath:=SubPath+'_'+Node.Name+'/';
    Node.Value:=Config.GetValue(SubPath+'Value','');
    ChildNames:=Config.GetValue(SubPath+'Childs','');
    //DebugLn(['Load SubPath="',SubPath,'" Value="',Node.Value,'" ChildNames="',ChildNames,'"']);
    if ChildNames<>'' then begin
      p:=PChar(ChildNames);
      repeat
        StartPos:=p;
        while not (p^ in ['/',#0]) do inc(p);
        ChildName:='';
        SetLength(ChildName,p-StartPos);
        if ChildName<>'' then
          System.Move(StartPos^,ChildName[1],p-StartPos);
        Child:=TConfigMemStorageNode.Create(Node,ChildName);
        if Node.Childs=nil then
          CreateChilds(Node);
        Node.Childs.Add(Child);
        Load(Child,SubPath);
        if p^=#0 then break;
        inc(p);
      until false;
    end;
  end;

begin
  //DebugLn(['TConfigMemStorage.LoadFromConfig ']);
  Clear;
  if Root=nil then
    CreateRoot;
  Load(Root,APath);
end;

procedure TConfigMemStorage.WriteDebugReport;

  procedure w(Node: TConfigMemStorageNode; Prefix: string);
  var
    AVLNode: TAvgLvlTreeNode;
  begin
    if Node=nil then exit;
    DebugLn(['TConfigMemStorage.WriteDebugReport ',Prefix,'Name="',Node.Name,'" Value="',Node.Value,'"']);
    if Node.Childs<>nil then begin
      AVLNode:=Node.Childs.FindLowest;
      while AVLNode<>nil do begin
        w(TConfigMemStorageNode(AVLNode.Data),Prefix+'  ');
        AVLNode:=Node.Childs.FindSuccessor(AVLNode);
      end;
    end;
  end;

begin
  DebugLn(['TConfigMemStorage.WriteDebugReport ']);
  w(Root,'');
end;

{ TConfigMemStorageNode }

procedure TConfigMemStorageNode.ClearChilds;
var
  OldChilds: TAvgLvlTree;
begin
  if Childs<>nil then begin
    OldChilds:=Childs;
    Childs:=nil;
    OldChilds.FreeAndClear;
    OldChilds.Free;
  end;
end;

constructor TConfigMemStorageNode.Create(AParent: TConfigMemStorageNode;
  const AName: string);
begin
  Parent:=AParent;
  Name:=AName;
end;

destructor TConfigMemStorageNode.Destroy;
begin
  ClearChilds;
  if (Parent<>nil) and (Parent.Childs<>nil) then
    Parent.Childs.Remove(Self);
  inherited Destroy;
end;

end.

