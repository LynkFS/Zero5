unit JWindow;

interface

uses
  JElement, JPanel, JButton, JToolBar;

type
  JW3Window = class(TElement)
  protected
    procedure ArrangeElements;
  public
    WindowArea : JW3Panel;
    ToolBar: JW3ToolBar;
    CloseButton: JW3Button;
    constructor Create(parent: TElement); virtual;
    procedure OpenWindow;
    procedure CloseWIndow;
  end;

implementation

uses Globals;

{ JW3Window }

constructor JW3Window.Create(parent: TElement);
begin
  inherited Create('div', parent);
  self.SetProperty('display','none');
  self.SetProperty('background-color', 'white');  //'rgb(255,255,255)');
  self.SetProperty('background-color', 'rgba(255,255,255,0.4)');
  self.SetProperty('z-index','9998');
  self.handle.style.width  := '100%';
  self.handle.style.height := '100%';

  WindowArea := JW3Panel.Create(self);
  WindowArea.SetProperty('background-color', '#82C9F6');
  WindowArea.SetProperty('margin', '1% 1% 1% 1%');
  WindowArea.SetProperty('border', '1px solid #888');
  WindowArea.SetProperty('width', '97%');
  WindowArea.SetProperty('height', '94%');
  WindowArea.SetProperty('box-shadow','3px 3px 3px 0px rgba(0, 0, 0, 0.2)');

//Init ToolBar
  ToolBar := JW3ToolBar.Create(WindowArea);
  ToolBar.SetBounds(0, 0, width, 40);
  ToolBar.setProperty('background-color', '#699BCE');  //'#42A2DC');
  ToolBar.SetProperty('width', '100%');
  ToolBar.SetProperty('box-shadow',#'0 2px 2px 0 rgba(0, 0, 0, 0.14),
                                     0 1px 5px 0 rgba(0, 0, 0, 0.12),
                                     0 3px 1px -2px rgba(0, 0, 0, 0.2)');

  CloseButton := JW3Button.Create(ToolBar);
  CloseButton.SetinnerHTML('x');
  CloseButton.SetProperty('z-index','9999');
  CloseButton.SetAttribute('style', #'margin: 2px 2px;
    float: right; cursor: pointer;');

  CloseButton.OnClick := procedure(sender:TObject)
  begin
    CloseWindow;
  end;

end;

procedure JW3Window.OpenWindow;
begin
  ArrangeElements;
  self.SetProperty('display','inline-block');
end;

procedure JW3Window.CloseWindow;
begin
  self.Destroy;
end;

procedure JW3Window.ArrangeElements;
begin
  //move all children of self, except WindowArea, to WindowArea
  //so this component can be invoked as if it is a normal form
  var d := self.handle.children;
  var TempArray : Array of variant;
  for var i := 0 to d.length -1 do
    TempArray.Add(d[i]);

  for var j := 0 to TempArray.length -1 do
    If TempArray[j].id <> WindowArea.handle.id then
      WindowArea.handle.appendChild(TempArray[j]);
  //
end;

end.

