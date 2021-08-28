unit JPanel;

interface

uses
  JElement;

type
  JW3Panel = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
    property Text : string read GetInnerHtml write SetInnerHtml;
  end;

implementation

{ JW3Panel }

constructor JW3Panel.Create(parent: TElement);
begin
  inherited Create('div', parent);
  SetProperty('user-select', 'none');

end;

end.
