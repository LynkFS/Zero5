unit JElement;

interface

uses Types;

type
  TMouseClickEvent   = procedure(sender:TObject);
  TResizeEvent       = procedure(sender:TObject);
  TReadyExecuteEvent = procedure(sender:TObject);

  TElement = class
  private
    procedure SetLeft(aLeft: integer);
    function  GetLeft: Integer;
    procedure SetTop(aTop: integer);
    function  GetTop: Integer;
    procedure SetWidth(aWidth: integer);
    function  GetWidth: Integer;
    procedure SetHeight(aHeight: integer);
    function  GetHeight: Integer;

    FOnClick:  TMouseClickEvent;
    FOnResize: TResizeEvent;
    FOnReadyExecute: TReadyExecuteEvent;
    procedure _setMouseClick(const aValue: TMouseClickEvent);
    procedure _setOnResize(const aValue: TResizeEvent);
    procedure _setOnReadyExecute(const aValue: TReadyExecuteEvent);
  public
    FElement: JHTMLElement;
    handle: Variant;
    constructor Create(element: String; parent: TElement);
    destructor Destroy; override;

    Procedure SetProperty(S1: String; S2: String);
    Procedure SetAttribute(S1: String; S2: String);

    Procedure SetCSS(prop, value: String); overload;
    Procedure SetCSS(pseudo, prop, value: string); overload;
    Function  GetCSSVar(value: string) : String;

    Procedure SetBounds(aleft, atop, awidth, aheight: integer);
    Procedure SetinnerHTML(S1: String);
    Function  GetinnerHTML : String;

    property  Left: Integer read getLeft write setLeft;
    property  Top: Integer read getTop write setTop;
    property  Width: Integer read getWidth write setWidth;
    property  Height: Integer read getHeight write setHeight;

    property  OnClick: TMouseClickEvent read FOnClick write _setMouseClick;
    procedure CBClick(eventObj: JEvent); virtual;

    property  OnReSize: TResizeEvent read FOnResize write _setOnResize;
    procedure CBResize(eventObj: JEvent); virtual;

    property  OnReadyExecute: TReadyExecuteEvent read FOnReadyExecute write _setOnReadyExecute;
    procedure CBReadyExecute(eventObj: JEvent); virtual;

    procedure Observe;
    procedure PropertyObserve;
    procedure Clear;
    //procedure ReadyExecute(const OnReady: Procedure);       //not needed when using observe.

    procedure touch2Mouse(e: variant);

    tag, name: string;
    FParent: TElement;
end;

type
  TMutationObserver = class
  protected
    Constructor Create;virtual;
    procedure   CBMutationChange(mutationRecordsList:variant);virtual;
  public
    FHandle:    Variant;
end;

implementation

uses Globals;

{ TElement }

constructor TElement.Create(element: String; parent: TElement);
begin
  // cache element
  FElement := JHTMLElement(document.createElement(element));
  FElement.className := element;
  FElement.id := TW3Identifiers.GenerateUniqueObjectId();

  var FElementStyle := JElementCSSInlineStyle(FElement).style;
  FElementStyle.setProperty('visibility','visible');
  FElementStyle.setProperty('display','inline-block');
  FElementStyle.setProperty('position','absolute');
  FElementStyle.setProperty('overflow','auto');

  FParent := parent;

  If parent = nil
    then handle := document.body.appendChild(FElement)
    else begin
      handle := parent.FElement.appendChild(FElement);
    end;

  SetBounds(0,0,0,0);

  FElement.addEventListener("click", @CBClick, false);
  window.addEventListener("resize", @CBResize, false);
  FElement.addEventListener("readyexecute", @CBReadyExecute, false);

  Observe;

end;

Procedure TElement.SetProperty(s1: String; S2: String);
begin
  var FElementStyle := JElementCSSInlineStyle(FElement).style;
  FElementStyle.setProperty(S1, S2);
end;

Procedure TElement.SetAttribute(S1: String; S2: String);
begin
  FElement.setAttribute(S1, S2);
end;

procedure TElement.SetCSS(prop, value: String);
begin
//sheet.addRule('#OBJ5','background-color: #4CAF50;');
//sheet.insertRule('#OBJ5 { color: green }', 0);
//addRule works in all browsers except FireFox, however insertRule works in all

  var s0,s1 : string;
  s0 := '#' + FElement.id; //'#OBJ5';
  s1 := prop + ': ' + value;

//  styleSheet.addRule(s0,s1);
  styleSheet.insertRule(s0 + ' { ' + s1 +'}', 0);
end;

Procedure TElement.SetCSS(pseudo, prop, value: string);
begin
//sheet.addRule('#OBJ5:hover','background-color: #4CAF50;');
//sheet.insertRule('#OBJ5:hover { color: green }', 0);

  var s0,s1 : string;
  s0 := '#' + FElement.id; //'#OBJ5';
  s1 := prop + ': ' + value;

  //styleSheet.addRule(s0+':'+ pseudo,s1);
  //console.log(s0+':'+ pseudo,s1);
  styleSheet.insertRule(s0 + ':' + pseudo + ' { ' + s1 +' }', styleSheet.cssRules.length);     //,0
  //console.log(s0 + ':' + pseudo + ' { ' + s1 + ' }');
end;

Function TElement.GetCSSVar(value: string) : String;
begin
  Result :=
    window.getComputedStyle(document.documentElement).getPropertyValue(value);
end;

Procedure TElement.SetBounds(aleft, atop, awidth, aheight: integer);
begin
  left   := aleft;
  top    := atop;
  width  := awidth;
  height := aheight;
end;

Procedure TElement.SetinnerHTML(S1: String);
begin
  FElement.innerHTML := S1;
end;

Function TElement.GetinnerHTML : String;
begin
  Result := FElement.innerHTML;
end;

procedure TElement._setMouseClick(const aValue: TMouseClickEvent);
begin
  FOnClick := aValue;
end;

procedure TElement.CBClick(eventObj: JEvent);
begin
  eventObj.stopPropagation;
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TElement._setOnResize(const aValue: TResizeEvent);
begin
  FOnResize := aValue;
end;

procedure TElement.CBResize(eventObj: JEvent);
begin
  if Assigned(FOnResize) then
    FOnResize(Self);
end;

procedure TElement._setOnReadyExecute(const aValue: TReadyExecuteEvent);
begin
  FOnReadyExecute := aValue;
end;

procedure TElement.CBReadyExecute(eventObj: JEvent);
begin
//  eventObj.stopPropagation;
  if Assigned(FOnReadyExecute) then
    FOnReadyExecute(Self);
end;

procedure TElement.SetLeft(aLeft: Integer);
begin
  var FElementStyle := JElementCSSInlineStyle(FElement).style;
  FElementStyle.setProperty('left',inttostr(aLeft)+'px');
end;

function  TElement.GetLeft: Integer;
begin
  var FElementStyle := JElementCSSInlineStyle(FElement).style;

  var S : string := FElementStyle.getPropertyValue('left');
  if StrEndsWith(S,'px') then SetLength(S, S.Length-2);
//  alternatively : if Pos('px',S) > 0 then SetLength(S, S.Length-2);
  Result := StrToInt(S);
end;

procedure TElement.SetTop(aTop: Integer);
begin
  var FElementStyle := JElementCSSInlineStyle(FElement).style;
  FElementStyle.setProperty('top',inttostr(aTop)+'px');
end;

function  TElement.GetTop: Integer;
begin
  var FElementStyle := JElementCSSInlineStyle(FElement).style;

  var S : string := FElementStyle.getPropertyValue('top');
  if StrEndsWith(S,'px') then SetLength(S, S.Length-2);
  Result := StrToInt(S);
end;

procedure TElement.SetWidth(aWidth: Integer);
begin
  var FElementStyle := JElementCSSInlineStyle(FElement).style;
  if aWidth = screenwidth
    then FElementStyle.setProperty('width','calc(100%)')
    else FElementStyle.setProperty('width',inttostr(aWidth)+'px');
end;

function  TElement.GetWidth: Integer;
begin
  var FElementStyle := JElementCSSInlineStyle(FElement).style;

  var S : string := FElementStyle.getPropertyValue('width');
  if StrEndsWith(S,'px') then SetLength(S, S.Length-2);
  Result := StrToInt(S);
end;

procedure TElement.SetHeight(aHeight: Integer);
begin
  var FElementStyle := JElementCSSInlineStyle(FElement).style;
  FElementStyle.setProperty('height',inttostr(aHeight)+'px');
end;

function  TElement.GetHeight: Integer;
begin
  var FElementStyle := JElementCSSInlineStyle(FElement).style;

  var S : string := FElementStyle.getPropertyValue('height');
  if StrEndsWith(S,'px') then SetLength(S, S.Length-2);
  Result := StrToInt(S);
end;

procedure TElement.Clear;
begin
  While assigned(FElement.firstChild) do
    FElement.removeChild(FElement.firstChild);
end;

destructor TElement.Destroy;
begin
  If assigned(FElement.parentNode) then
    Felement.parentNode.removeChild(Felement);
end;

procedure TElement.touch2Mouse(e: variant);
begin
//mapping touch events to mouse events. See JSplitter for example
//https://www.codicode.com/art/easy_way_to_add_touch_support_to_your_website.aspx

  var theTouch := e.changedTouches[0];
  var mouseEv : variant;

  case e.type of
    "touchstart": mouseEv := "mousedown";
    "touchend":   mouseEv := "mouseup";
    "touchmove":  mouseEv := "mousemove";
    else exit;
  end;

  var mouseEvent := document.createEvent("MouseEvent");
  mouseEvent.initMouseEvent(mouseEv, true, true, window, 1, theTouch.screenX, theTouch.screenY, theTouch.clientX, theTouch.clientY, false, false, false, false, 0, null);
  theTouch.target.dispatchEvent(mouseEvent);

  e.preventDefault();
end;

procedure TElement.PropertyObserve;
begin
  //in w3c.dom
  var options : JMutationObserverInit;
  asm @options = Object.create(@options); end;
  options.attributes := true;
  options.attributeOldValue := true;

  var callback : JMutationCallback := procedure(mutations: array of JMutationRecord; observer: JMutationObserver)
  begin
    //console.log(handle.style.height);
    //console.log(self.Height);
    DisPatchEvent('PropertyChange',handle.id,'click',nil);
  end;

  var MyObserver : JMutationObserver;
  asm @MyObserver = Object.create(@MyObserver); end;
  MyObserver := JMutationObserver.Create(callback);

  MyObserver.observe(self.FElement, options);

end;

procedure TElement.Observe;
begin
  var MyObserver := TMutationObserver.Create;
  var v: variant := new JObject;
  v.attributes := true;
  v.attributeOldValue := true;
//  v.childList := true;

  MyObserver.FHandle.observe(handle, v);

end;


//#############################################################################
// TMutationObserver
//#############################################################################

Constructor TMutationObserver.Create;
var
  mRef: procedure (data:Variant);
  mhandle:  variant;
begin
  inherited Create;

  mRef:=@CBMutationChange;
  asm
    @mHandle = new MutationObserver(function (_a_d) {@mRef(_a_d);});
  end;
  Fhandle:=mHandle;
end;

procedure TMutationObserver.CBMutationChange(mutationRecordsList:variant);
var
  LEvent: Variant;
begin
  FHandle.disconnect();
  asm @LEvent = new Event('readyexecute'); end;
  mutationRecordsList[length(mutationRecordsList)-1].target.dispatchEvent(LEvent);
end;


initialization
//
  ScreenWidth := Window.innerWidth;
  ScreenHeight := Window.innerHeight;

end.
