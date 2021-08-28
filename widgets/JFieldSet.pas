unit JFieldSet;

interface

uses
  JElement;

type
  JW3FieldSet = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
    Legend: String;
    Title : TElement;
  end;

implementation

uses Globals;

{ JW3FieldSet }

constructor JW3FieldSet.Create(parent: TElement);
begin
  inherited Create('fieldset', parent);
  SetProperty('border','1px solid silver');

  //self.Observe;
  self.OnReadyExecute := procedure(sender: TObject)
  begin
    //construct legend when applicable
    If self.legend <> '' then
    begin
      Title := TElement.Create('legend',self);
      Title.handle.innerHTML := self.Legend;
      Title.handle.removeAttribute('style');
    end;

    var d := self.handle.children;
    for var i := 0 to d.length -1 do begin
      If d[i].style.height = '0px' then
      begin
        d[i].style.left   := '10px';
        d[i].style.top    := inttostr(30 + (i*34)) + 'px';
        d[i].style.width  := inttostr(self.width-4) + 'px';
        d[i].style.height := '30px';
      end;
    end;

  end;
end;

end.

