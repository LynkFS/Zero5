unit JTabControl;

interface

uses
  JElement, JPanel, JButton;

type
  JTab = class(TElement)                      //individual tab and its body area
  public
    constructor Create(parent: TElement); virtual;
    body : TElement;
    property Caption : string read GetInnerHtml write SetInnerHtml;
    property hidden : boolean;
  end;

  JW3TabControl = class(TElement)             //tabcontrol = array of tabs
  protected
    TabBar : JW3Panel;
  public
    constructor Create(parent: TElement); virtual;
    Tabs : array of JTab;
    TabHeight : integer := 26;   //default
    TabWidth : integer := 100;   //default 100
    AutoSize : boolean := false;
    ActiveTab: integer := -1;
    procedure AddTab(Caption: String);
    procedure ReDraw;
  end;

implementation

uses Globals;

{ JW3Tab }

constructor JTab.Create(parent: TElement);
begin
  inherited Create('div', parent);
  SetProperty('cursor','pointer');
  SetProperty('border','0px');
end;

{ JW3TabControl }

constructor JW3TabControl.Create(parent: TElement);
begin
  inherited Create('div', parent);

  self.OnReadyExecute := lambda(sender: TObject) ReDraw; end;
end;

Procedure JW3TabControl.AddTab(Caption: String);
begin
  //create the tab
  var Tab := JTab.Create(self);
  Tab.Width := TabWidth;
  Tab.Height := TabHeight;
  Tab.Left := Tabs.count * TabWidth;
  Tab.Caption := '&nbsp;&nbsp;' + Caption;
  Tab.Tag := IntToStr(Tabs.Count);
  //Tab.setProperty('padding-top', '2px');
  Tab.SetProperty('z-index','998');

  //create the body
  var Body := JW3Panel.Create(self);
  Body.top := TabHeight;
  Body.width := self.Width-2;
  Body.height := self.height - TabHeight - 2;

  //add to array
  Tab.Body := Body;
  Tabs.Add(Tab);

  Tab.OnClick := procedure(sender:TObject)
  begin
    //set all tabs to inactive
    For var i := 0 to Tabs.Count -1 do begin
      Tabs[i].setProperty('background-color', 'whitesmoke');
      Tabs[i].body.SetProperty('z-index','0');
    end;
    //activate clicked tab
    Tabs[StrToInt(Tab.Tag)].setProperty('background-color', 'white');
    Tabs[StrToInt(Tab.Tag)].body.setProperty('background-color', 'white');
    Tabs[StrToInt(Tab.Tag)].body.setProperty('border-bottom', 'none');
    Tabs[StrToInt(Tab.Tag)].body.SetProperty('z-index','999');

  end;

end;

Procedure JW3TabControl.ReDraw;
var
  j : integer := 0;
begin
  TabBar := JW3Panel.Create(self);
  TabBar.SetBounds(0,0,self.width,tabHeight-2);
  TabBar.setProperty('background-color', '#FAFAFA');  //'whitesmoke');
  TabBar.SetProperty('border-bottom','1px dotted silver');
  TabBar.SetProperty('margin','1px');
  TabBar.SetProperty('padding','0px');

  self.SetProperty('border','1px solid lightgrey');
  //self.SetProperty('border-top','none');
  //self.SetProperty('border-right','none');
  self.setProperty('background-color', 'white');

  var NrVisible: integer := 0;

  for var i := 0 to Tabs.Count -1 do begin
    Tabs[i].body.width := self.width-1;
    //Tabs[i].body.setProperty('border-right', '1px solid lightgrey');
    Tabs[i].handle.style.backgroundColor := 'whitesmoke';
    //Tabs[i].setProperty('border-top', '1px solid lightgrey');
    Tabs[i].SetProperty('border-right','1px solid lightgrey');
    If not Tabs[i].hidden then inc(NrVisible);
    If (ActiveTab = -1) or (Tabs[ActiveTab].hidden) then   //first time or hidden? if yes
      if NrVisible = 1 then                                //get first visible tab
        ActiveTab := i;                                    //and put it in activetab
    Tabs[ActiveTab].OnClick(self);    //activate activetab by simulating click
    If Tabs[i].hidden
      then Tabs[i].handle.style.display := 'none'
      else Tabs[i].handle.style.display := 'inline-block';
  end;

  for var i := 0 to Tabs.Count -1 do begin
    If AutoSize
      then Tabs[i].Width := trunc(self.width / NrVisible)
      else Tabs[i].width := TabWidth;
    //set tabs
    If not Tabs[i].hidden then begin
      Tabs[i].Left := j * Tabs[i].Width;
      Tabs[i].Width := Tabs[i].Width - 2;
      inc(j);
    end;
    //set bodies
    //Tabs[i].body.setProperty('background-color', 'white');

    Handle.style['overflow-x'] := 'hidden';              //NativeScrolling := false;
    if NrVisible * Tabs[i].Width > self.width then begin //tabs do not fit within components width
      Handle.style['overflow'] := 'auto';                //NativeScrolling := true
      Tabs[i].body.width := Tabs[i].width * NrVisible;
    end;
  end;

end;

end.

////////////////////////////////////////////////////////////////////////

unit JTabControl;

interface

uses
  JElement, JPanel, JButton;

type
  JTab = class(TElement)                      //individual tab and its body area
  public
    constructor Create(parent: TElement); virtual;
    body : TElement;
    property Caption : string read GetInnerHtml write SetInnerHtml;
    property hidden : boolean;
  end;

  JW3TabControl = class(TElement)             //tabcontrol = array of tabs
  public
    constructor Create(parent: TElement); virtual;
    Tabs : array of JTab;
    TabHeight : integer := 26;   //default
    TabWidth : integer := 100;   //default
    AutoSize : boolean := false;
    ActiveTab: integer := -1;
    procedure AddTab(Caption: String);
    procedure ReDraw;
  end;

implementation

uses Globals;

{ JW3Tab }

constructor JTab.Create(parent: TElement);
begin
  inherited Create('button', parent);
  SetProperty('cursor','pointer');
  SetProperty('border','0px');
end;

{ JW3TabControl }

constructor JW3TabControl.Create(parent: TElement);
begin
  inherited Create('div', parent);

  self.OnReadyExecute := lambda(sender: TObject) ReDraw; end;
end;

Procedure JW3TabControl.AddTab(Caption: String);
begin
  //create the tab
  var Tab := JTab.Create(self);
  Tab.Height := TabHeight;
  Tab.Width := TabWidth;
  Tab.Left := Tabs.count * TabWidth;
  Tab.Caption := Caption;
  Tab.Tag := IntToStr(Tabs.Count);

  //create the body
  var Body := JW3Panel.Create(self);
  Body.top := TabHeight;
  Body.width := self.Width-2;
  Body.height := self.height - TabHeight - 2;
  Body.SetProperty('border-top','1px dotted lightgrey');

  //add to array
  Tab.Body := Body;
  Tabs.Add(Tab);

  Tab.OnClick := procedure(sender:TObject)
  begin
    //set all tabs to inactive
    For var i := 0 to Tabs.Count -1 do begin
      Tabs[i].setProperty('background-color', 'lightgrey');
      Tabs[i].body.SetProperty('z-index','0');
    end;
    //activate clicked tab
    Tabs[StrToInt(Tab.Tag)].setProperty('background-color', 'white');
    Tabs[StrToInt(Tab.Tag)].body.setProperty('background-color', 'white');
    Tabs[StrToInt(Tab.Tag)].body.SetProperty('z-index','999');
  end;

end;

Procedure JW3TabControl.ReDraw;
var
  j : integer := 0;
begin

  var NrVisible: integer := 0;

  for var i := 0 to Tabs.Count -1 do begin
    Tabs[i].body.width := self.width;
    Tabs[i].handle.style.backgroundColor := 'lightgrey';
    If not Tabs[i].hidden then inc(NrVisible);
    If (ActiveTab = -1) or (Tabs[ActiveTab].hidden) then   //first time or hidden? if yes
      if NrVisible = 1 then                                //get first visible tab
        ActiveTab := i;                                    //and put it in activetab
    Tabs[ActiveTab].OnClick(self);    //activate activetab by simulating click
    If Tabs[i].hidden
      then Tabs[i].handle.style.display := 'none'
      else Tabs[i].handle.style.display := 'inline-block';
  end;

  for var i := 0 to Tabs.Count -1 do begin
    If AutoSize
      then Tabs[i].Width := trunc(self.width / NrVisible)
      else Tabs[i].width := TabWidth;
    //set tabs
    If not Tabs[i].hidden then begin
      Tabs[i].Left := j * Tabs[i].Width;
      inc(j);
    end;
    //set bodies
    Handle.style['overflow-x'] := 'hidden';              //NativeScrolling := false;
    if NrVisible * Tabs[i].Width > self.width then begin //tabs do not fit within components width
      Handle.style['overflow'] := 'auto';                  //NativeScrolling := true
      Tabs[i].body.width := Tabs[i].width * NrVisible;
    end;
  end;

end;

end.

