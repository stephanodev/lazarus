{
 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.        *
 *                                                                         *
 ***************************************************************************

  Author: Michael Van Canneyt
}
unit FrmMakeSkel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Buttons,
  StdCtrls, EditBtn, ButtonPanel, ExtCtrls;

type

  { TMakeSkelForm }

  TMakeSkelForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    CBDisableArguments: TCheckBox;
    CBDisableErrors: TCheckBox;
    CBDisablePrivate: TCheckBox;
    CBDisableProtected: TCheckBox;
    CBDisableResults: TCheckBox;
    CBDisableSeeAlso: TCheckBox;
    EAdditionalOptions: TEdit;
    EPackage: TEdit;
    FEinputFile: TFileNameEdit;
    FEoutputFIle: TFileNameEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LEPackage: TLabel;
    Panel1: TGroupBox;
    Panel2: TGroupBox;
    procedure CheckEnabled(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  MakeSkelForm: TMakeSkelForm;

implementation

{$R *.lfm}

{ TMakeSkelForm }

procedure TMakeSkelForm.CheckEnabled(Sender: TObject);
begin
  if Sender=nil then ;
end;

end.

