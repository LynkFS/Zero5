unit Globals;

interface

uses JApplication, Types, JElement;

type
  TW3Identifiers = static class
  private
    class var __UNIQUE: integer;
  public
    class function GenerateUniqueObjectId: string;
    class function GenerateUniqueObjectId2: string;
  end;

//framework globals
var Application : JW3Application;
var ScreenWidth : Integer := 0;
var ScreenHeight: integer := 0;
var document external 'document': variant;
var window   external 'window':   variant;
var console  external 'console':  variant;
var FileReader : variant := new JObject;
var smscursor: variant;
var styleSheet: variant;

function CreateObject(MyObject: variant): variant;
function CreateArray(MyArray: Array of Variant): variant;
function MeasureSize(content: string): integer;
function getSBWidth: integer;
function MeasureTextWidth(const FontName: string;
const FontSize: integer; const Text: string): integer;

function Sort(myArray: Array of TElement; attrib:string): Array of TElement;
procedure DisPatchEvent(customEvent,id,action: string; tag: variant);
var Twice : boolean := false;
procedure tapHandler(e: variant);

implementation

procedure tapHandler(e: variant);
begin
  //replaces double taps (consecutive touchstart events) into dblclicks
  if not Twice then begin
    Twice := true;
    Window.setTimeout( procedure() begin Twice := false; end, 300 );
  end else begin
    e.preventDefault();
    var event: variant;
    asm @event = new Event('dblclick'); end;
    e.target.dispatchEvent(event);
  end;
end;

procedure DisPatchEvent(customEvent,id,action: string; tag: variant);
begin
  //DisPatchEvent('RadioButton',self.Button.handle.id,'click','saved');
  var msg : variant := new JObject;
  msg.id := id;
  msg.action := action;
  msg.tag := tag;
  var payload : variant := new JObject;
  payload.detail := JSON.stringify(msg);
  var myEvent : variant := new JObject;
  asm @myEvent = new CustomEvent(@customEvent, @payload); end;
  document.dispatchEvent(myEvent);
end;

function Sort(myArray: Array of TElement; attrib:string): Array of TElement;
begin
    (* populate list *)
    for var x := 0 to myArray.length - 1 do
    begin
      result.add(myArray[x]);
    end;

    (* sort by X-pos *)
    if result.Count>1 then
    begin
      var mAltered: boolean;
      repeat
        mAltered := false;
        for var x := 1 to myArray.length - 1 do
        begin
          var mLast := TElement(result[x - 1]);
          var mCurrent := TElement(result[x]);
          if attrib = 'left' then begin
            if mCurrent.left < mLast.left then
            begin
              result.Swap(x - 1,x);
              mAltered := true;
            end;
          end;
          if attrib = 'top' then begin
            if mCurrent.top < mLast.top then
            begin
              result.Swap(x - 1,x);
              mAltered := true;
            end;
          end;
        end;
      until mAltered = false;
    end;

end;

class function TW3Identifiers.GenerateUniqueObjectId: string;
begin
  inc(__UNIQUE);
  result :='Component' + __UNIQUE.ToString();
end;

class function TW3Identifiers.GenerateUniqueObjectId2: string;
begin
  inc(__UNIQUE);
  result :='Compo_' + __UNIQUE.ToString();
end;

function CreateObject(MyObject: variant): variant;
begin
  result := JSON.parse(MyObject);
end;

function CreateArray(MyArray: Array of Variant): variant;
begin
  asm @result = new Array(@MyArray); end;
end;

function MeasureTextWidth(const FontName: string;
  const FontSize: integer; const Text: string): integer;
var
  mElement: variant;
Begin
    if Text.length >0 then
    begin
      mElement := document.createElement("p");
      if (mElement) then
      begin
        //mElement.style['font-family']   := FontName;
        mElement.style['font-size']     := '0.85em';  //IntToStr(FontSize) + 'px';
        mElement.style['white-space']   := 'nowrap';
        mElement.style['display']       := 'inline-block';
        mElement.style['overflow']      := 'scroll';
        mElement.style['margin']        := '0px';
        mElement.style['padding']       := '0px';
        mElement.style['border-style']  := 'none';
        mElement.style['border-width']  := '0px';
        mElement.style.width            := '1px';
        mElement.style.height           := '1px';

        mElement.innerHTML := Text.Replace(" ","_");

        document.body.appendChild(mElement);

        result := mElement.scrollWidth;
        //result.tmHeight := mElement.scrollHeight;

        document.body.removeChild(mElement);
      end;

    end;
end;

function MeasureSize(content: string): integer;
//var
//  mHandle:  variant;
begin
/*
  mHandle := document.createElement("span");
  mHandle.style.display    := 'inline-block';
  mHandle.style.visibility := 'hidden';
  mHandle.style.fontFamily := 'Times New Roman, sans-serif';
  //mHandle.style.fontSize   := '0.85em';

  mHandle.innerHTML := content;
  document.body.appendChild(mHandle);
  result := mHandle.clientWidth; //offsetWidth;

  document.body.removeChild(mHandle);
*/
  result := measuretextwidth('',0,content);
end;

function getSBWidth: integer;
begin

var x : integer := 0;
asm
function getScrollBarWidth() {
	var inner = document.createElement('p');
	inner.style.width = "100%";
	inner.style.height = "200px";

	var outer = document.createElement('div');
	outer.style.position = "absolute";
	outer.style.top = "0px";
	outer.style.left = "0px";
	outer.style.visibility = "hidden";
	outer.style.width = "200px";
	outer.style.height = "150px";
	outer.style.overflow = "hidden";
	outer.appendChild(inner);

	document.body.appendChild(outer);
	var w1 = inner.offsetWidth;
	outer.style.overflow = 'scroll';
	var w2 = inner.offsetWidth;

	if (w1 == w2) {
		w2 = outer.clientWidth;
	}

	document.body.removeChild(outer);

  @x = (w1 - w2);
	return (w1 - w2);
}

getScrollBarWidth();
end;

result := x;
end;


initialization
//
  Application := JW3Application.Create(nil);

  //iOS specifics
    //temporary hack to eliminate rubberbanding
    window.onscroll := procedure
    begin
      window.scrollTo(0, 0);
    end;
    //without this ios won't scroll
    application.handle.addEventListener('touchmove', procedure(event:variant)
    begin
      event.stopPropagation();
    end);
/*
  //general initialisation
    //create stylesheet if there isn't one
    var s = document.styleSheets;
    if s.length = 0 then begin
      var style := document.createElement("STYLE");
      document.head.appendChild(style);
    end;

    //set some initial <body> css values (native scrolling)
    var s1 := #'
    body {
      overflow-y: auto;
      -webkit-overflow-scrolling: touch;
      scroll-behavior: smooth;
      overscroll-behavior-y: none;
    }';
//    document.styleSheets[0].insertRule(s1, 0);

    //asm @FileReader = new Worker('https://www.lynkfs.com/native/www/filereader.js'); end;
    //asm @FileReader = new Worker('filereader.js'); end;
    //asm @FileReader = new Worker('https://www.lynkit.com.au/filereader.js'); end;

*/

    //asm @FileReader = new Worker('https://www.lynkit.com.au/filereader.js'); end;

    var styleEl :variant := document.createElement('style');
    // Append <style> element to <head>
    document.head.appendChild(styleEl);
    // Grab style element's sheet
    styleSheet := styleEl.sheet;

    //set some initial <body> css values (native scrolling)
    var s1 := #'
    body {
      overflow-y: auto;
      -webkit-overflow-scrolling: touch;
      scroll-behavior: smooth;
      overscroll-behavior-y: none;
    }';
    styleSheet.insertRule(s1, 0);

    //set initial css variables : buttons
    var s2 := #'
      :root {
        --button-colorbase:   #0099FF;
        --button-colorhover:  #0077FF;
        --button-coloractive: red;
        --button-borderfocus: 0px;
        --button-disabled: silver;
      }';
    styleSheet.insertRule(s2, 0);
end.
