unit JCanvas;

interface

uses
  JElement;

type
  JW3Canvas = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
    ctx : Variant;
  end;

implementation

uses Globals;

{ JW3Canvas }

constructor JW3Canvas.Create(parent: TElement);
begin
  inherited Create('canvas', parent);

  ctx := self.handle.getContext('2d');        //(self.AsChild).getContext('2d');
end;

end.
