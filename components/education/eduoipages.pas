{
 *****************************************************************************
 *                                                                           *
 *  This file is part of the EducationLaz package                            *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************

  Author: Michael Kuhardt

  Abstract:
    Frame to setup pages for ObjectInspector
}
unit EduOIPages;

{$mode objfpc}{$H+}

interface

uses
  Classes, LResources, Forms, StdCtrls, ExtCtrls, LazConfigStorage, IDEOptionsIntf, EduOptions,
  ObjectInspector, ObjInspStrConsts;

type

  { TEduPropsEventsOptions }

  TEduOIPagesOptions = class(TEduOptionsNode)
  private
    FOIPageFavs: boolean;
    FOIPageRestricted: boolean;

  public
    constructor Create; override;
    destructor Destroy; override;
    function Load(Config: TConfigStorage): TModalResult; override;
    function Save(Config: TConfigStorage): TModalResult; override;
    procedure Apply(Enable: boolean); override;
    property OIPageFavs: boolean read FOIPageFavs write FOIPageFavs;
    property OIPageRestricted: boolean read FOIPageRestricted write FOIPageRestricted;

  end;

  { TEduOIPagesFrame }

  TEduOIPagesFrame = class(TAbstractIDEOptionsEditor)
    ckBoxRestricted: TCheckBox;
    ckBoxFavs: TCheckBox;
    grpBoxOIPages: TGroupBox;
    OptsPanel: TPanel;

  public
    function GetTitle: String; override;
    procedure ReadSettings(AOptions: TAbstractIDEOptions); override;
    procedure Setup(ADialog: TAbstractOptionsEditorDialog); override;
    class function SupportedOptionsClass: TAbstractIDEOptionsClass; override;
    procedure WriteSettings(AOptions: TAbstractIDEOptions); override;

  end;

var
  EduOIPagesOptions: TEduOIPagesOptions = nil;

procedure Register;

implementation

procedure Register;
begin
  EduOIPagesOptions:=TEduOIPagesOptions.Create;
  EducationOptions.Root.Add(EduOIPagesOptions);
  EduOIPagesOptionsID:=RegisterIDEOptionsEditor(EduOptionID,TEduOIPagesFrame,
                                                EduOIPagesOptionsID)^.Index;
end;

{ TEduOIPagesOptions }

constructor TEduOIPagesOptions.Create;

begin
  inherited Create;
  Name:='OIPages';

  FOIPageFavs:=false;
  FOIPageRestricted:=false;

end;

destructor TEduOIPagesOptions.Destroy;
begin
  inherited Destroy;
end;

function TEduOIPagesOptions.Load(Config: TConfigStorage): TModalResult;
begin

  FOIPageFavs:=Config.GetValue('OIPageFavs',true);
  FOIPageRestricted:=Config.GetValue('OIPageRestricted',true);

  Result:=inherited Load(Config);
end;

function TEduOIPagesOptions.Save(Config: TConfigStorage): TModalResult;
begin

  Config.SetValue('OIPageFavs',FOIPageFavs);
  Config.SetValue('OIPageRestricted',FOIPageRestricted);

  Result:=inherited Save(Config);
end;

procedure TEduOIPagesOptions.Apply(Enable: boolean);
begin
  inherited Apply(Enable);
end;

{ TEduOIPagesFrame }




function TEduOIPagesFrame.GetTitle: String;
begin
  Result:=ersEduOIPages;
end;

procedure TEduOIPagesFrame.ReadSettings(AOptions: TAbstractIDEOptions);
begin
  if AOptions=EducationOptions then begin
    ckBoxFavs.Checked:=EduOIPagesOptions.OIPageFavs;
    ckBoxRestricted.Checked:=EduOIPagesOptions.OIPageRestricted;
  end;
end;

procedure TEduOIPagesFrame.Setup(ADialog: TAbstractOptionsEditorDialog);
begin
  ckBoxFavs.Caption:=oisFavorites;
  ckBoxRestricted.Caption:=oisRestricted;
  grpBoxOIPages.Caption:=ersShowOIPages;
end;

class function TEduOIPagesFrame.SupportedOptionsClass: TAbstractIDEOptionsClass;
begin
  Result:=EducationIDEOptionsClass;
end;

procedure TEduOIPagesFrame.WriteSettings(AOptions: TAbstractIDEOptions);
begin
  if AOptions=EducationOptions then begin
    EduOIPagesOptions.OIPageFavs:=ckBoxFavs.Checked;
    EduOIPagesOptions.OIPageRestricted:=ckBoxRestricted.Checked;
  end;
end;

{$R *.lfm}

end.
