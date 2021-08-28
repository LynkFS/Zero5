unit JIframe;

interface

uses
  JElement, Globals;

type
  JW3IFrame = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
  end;

implementation

{ JW3IFrame }

constructor JW3IFrame.Create(parent: TElement);
begin
  inherited Create('iframe', parent);

  SetProperty('frameBorder','0px');
  SetProperty('border-radius','.25em');
//  SetProperty('box-shadow',#'0 2px 2px 0 rgba(0, 0, 0, 0.14),
//                             0 1px 5px 0 rgba(0, 0, 0, 0.12),
//                             0 3px 1px -2px rgba(0, 0, 0, 0.2)');

//  self.SetAttribute('loading','lazy');

  document.addEventListener('myCustomEvent2',procedure(evt:variant)
  begin
    console.log('myCustomEvent2');
    console.log(evt.detail);
  end, false);

  self.handle.onload := procedure ()
  begin
    var data : variant := new JObject;
    data.width  := 'calc(100% - 2px)'; //inttostr(self.width-2) +'px';
    data.height := 'calc(100% - 2px)'; //inttostr(self.height-2)+'px';
    var event: variant := new JObject;
    asm @event = new CustomEvent('myCustomEvent', { detail: @data })   end;
    self.handle.contentWindow.document.getElementById("Component2").dispatchEvent(event);
    //console.log(event);
  end;

end;

end.
