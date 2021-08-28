unit JDialog;

interface

uses
  JElement;

type
  JW3Dialog = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
    //property Caption : string read GetInnerHtml write SetInnerHtml;
  end;

implementation

uses Globals;

{ JW3Dialog }

constructor JW3Dialog.Create(parent: TElement);
begin
  inherited Create('div', parent);
  SetProperty('color','whitesmoke');
  SetProperty('border','1px solid silver');
  SetProperty('border-radius', '4px');
  SetProperty('cursor','pointer');
  //SetProperty('resize','both');
  SetProperty('box-shadow',#'0 -1px 1px 0 rgba(0, 0, 0, 0.25) inset,
                             0  1px 1px 0 rgba(0, 0, 0, 0.10) inset;)');

  SetCss('background-color' , 'whitesmoke');
  SetCss('hover', 'background-color' , 'white');

end;

end.

//////////////////////////////////////

type
  THeader = class(TW3CustomControl)
  protected
    headerheight: integer := 26;
    CloseButton, MinButton, MaxButton : TW3Button;
    TitleText : TW3Label;
  end;

  TContent = class(TW3CustomControl)
  end;

  TWindow = class(TW3CustomControl)
  protected
    procedure InitializeObject; override;
    procedure ReSize; override;
    procedure setTitle(title: string);
    procedure SetUpButtons;
    procedure MakeWindowMovable;
    procedure MakeWindowReSizable;
    procedure MakeWindowVisible;
    PrevSize : TRect;
    Minimised, Maximised : boolean := false;
    Header  : THeader;
  published
    Content : TContent;
    property Title: String write SetTitle;
  end;

  var document external 'document': variant;
  var window   external 'window':   variant;
  var console  external 'console':  variant;

  var ButtonStyling : String;

implementation

//#############################################################################
// TWindow
//#############################################################################

procedure TWindow.InitializeObject;
begin
  inherited;

  Header := THeader.Create(self);
  Header.TitleText := TW3Label.Create(Header);

  Content := TContent.Create(self);

  SetUpButtons;                     //standard window buttons
  MakeWindowVisible;                //bring-to-front by clicking header or content
  MakeWindowMovable;                //Move window by dragging header
  MakeWindowReSizable;              //Resize width/height by dragging Content

  Handle.ReadyExecute( procedure ()
  begin
    PrevSize := TRect.CreateSized(left, top, width, height);
    ReSize;
  end);

  Content.NativeScrolling := true;

end;

procedure TWindow.SetUpButtons;
begin
  //Close window
  Header.CloseButton := TW3Button.Create(Header);
  Header.CloseButton.innerHTML := 'x';            //font awesome might be better
  Header.CloseButton.handle.style.cssText := ButtonStyling;
  Header.CloseButton.OnClick := procedure(sender:TObject)
  begin
    self.handle.parentNode.removeChild(self.handle);
  end;

  //Maximise window
  Header.MaxButton := TW3Button.Create(Header);
  Header.MaxButton.innerHTML := '&#9744;';  //'&#128470;'
  Header.MaxButton.handle.style.cssText := ButtonStyling;
  Header.MaxButton.OnClick := procedure(sender:TObject)
  begin
    if not Maximised
      then self.setBounds(0,0,window.innerWidth-2,window.innerHeight-2)
      else self.setBounds(PrevSize.left, PrevSize.top,
                          PrevSize.Right-PrevSize.left, PrevSize.Bottom-PrevSize.Top);
    Maximised := not Maximised;
  end;

  //Minimise window
  Header.MinButton := TW3Button.Create(Header);
  Header.MinButton.innerHTML := '-';  //'&#128469;';
  Header.MinButton.handle.style.cssText := ButtonStyling;
  Header.MinButton.OnClick := procedure(sender:TObject)
  begin
    if not Minimised
      then self.top := window.innerHeight-header.headerheight
      else self.setBounds(PrevSize.left, PrevSize.top,
                          PrevSize.Right-PrevSize.left, PrevSize.Bottom-PrevSize.Top);
    Minimised := not Minimised;
  end;
//
end;

procedure TWindow.MakeWindowMovable;
begin
  //Move window
  Header.handle.onmousedown := procedure(e: variant)
  begin
    Header.handle.style.cursor := 'move';
    Header.TitleText.handle.style.cursor := 'move';
    var saveX := e.clientX;
    var saveY := e.clientY;

    Header.handle.onmousemove := procedure(e: variant)
    begin
      self.left    := self.Left - (saveX - e.clientX);
      self.top     := self.top - (saveY - e.clientY);
      PrevSize     := TRect.CreateSized(left, top, width, height);

      saveX := e.clientX;
      saveY := e.clientY;
    end;
  end;
  //
  Header.handle.onmouseup := procedure(e: variant)
  begin
    Header.handle.onmousemove := null;                       //nullify mousemove
    Header.handle.style.cursor := 'default';
    Header.TitleText.handle.style.cursor := 'default';
  end;
  //
  Header.handle.onmouseleave := procedure(e: variant)
  begin
    self.Parent.handle.onmousemove := header.handle.onmousemove;
    self.Parent.handle.onmouseup   := procedure(e: variant)
    begin
      self.parent.Handle.onmousemove := null;
    end;
    //self.Parent.handle.onmousedown := header.handle.onmousedown;
  end;
end;

procedure TWindow.MakeWindowReSizable;
begin
  //Resize width/height
  Content.handle.onmousedown := procedure(e: variant)
  begin
    //console.log(e.clientX);
    //if (e.clientX > self.left + self.width - 30) and
    //   (e.clientX < self.left + self.width) then
    //begin
    Content.handle.style.cursor := 'nwse-resize';
    var saveX := e.clientX;
    var saveY := e.clientY;

    Content.handle.onmousemove := procedure(e: variant)
    begin
      self.width  := self.width  - (saveX - e.clientX);
      self.height := self.height - (saveY - e.clientY);
      PrevSize    := TRect.CreateSized(left, top, width, height);

      saveX := e.clientX;
      saveY := e.clientY;
    end;
    //end;
  end;
  //
  Content.handle.onmouseup := procedure(e: variant)
  begin
    Content.handle.onmousemove := null;                       //nullify mousemove
    Content.handle.style.cursor := 'default';
  end;
end;

procedure TWindow.MakeWindowVisible;    //BringToFront
begin
  Header.handle.onclick := procedure(e: variant)
  begin
    var z : integer := 0;
    var x := document.getElementsByClassName('TWindow');
    for var i := 0 to x.length-1 do begin
      var y : integer := strtoint(x[i].style.zIndex);
      If y > z then z := y;   //determine highest zIndex in TWindow collection
    end;
    self.handle.style.zIndex := inttostr(z+1);  //inc by 1
  end;
  Content.Handle.onclick := header.Handle.onclick;
end;

procedure TWindow.ReSize;
begin
  inherited ReSize;

  Header.SetBounds(0,0,self.width-2,header.headerheight);
  Content.SetBounds(0,header.headerheight,self.width-2,self.height-2-header.headerheight);
  Header.TitleText.SetBounds(0,0,Header.width-(3*header.headerheight),Header.headerheight-2);

end;

procedure TWindow.SetTitle;
begin
  Header.TitleText.innerHtml := '<center>' + title + '</center>';
end;

initialization

  var Sheet := TW3StyleSheet.GlobalStyleSheet;
  var StyleCode := #'

  .TWindow {
    border : 1px solid silver;
  }

  .THeader {
    background: rgb(222,225,230);
    padding: 5px;
  }

  .TContent {
    background: #fff;
    padding: 5px;
    border-top : 1px solid lightgray;
  }

  ';
  Sheet.Append(StyleCode);

//
  ButtonStyling := #'
    margin: 0px;
    padding: 0px;
    margin-right: 2px;
    //top: 0px;
    font-size: 12px;
    border: none;
    box-shadow: none;
    border-radius: 0px;
    height: 16px;
    width:  16px;
    float: right;
    cursor: pointer;
  ';

end.
