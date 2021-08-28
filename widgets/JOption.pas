unit JOption;

interface

uses
  JElement;

type
  JW3Option = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
  end;

  JW3OptionSelector = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
    Procedure AddOption(item, value: string);
  end;

implementation

{ JW3Option }

constructor JW3Option.Create(parent: TElement);
begin
  inherited Create('option', parent);
end;

{ JW3OptionSelector }

constructor JW3OptionSelector.Create(parent: TElement);
begin
  inherited Create('select', parent);
end;

procedure JW3OptionSelector.AddOption(item, value: string);
begin
  var Option := JW3Option.Create(self);
  Option.SetAttribute('value',value);
  Option.SetinnerHTML(item);
end;

end.
