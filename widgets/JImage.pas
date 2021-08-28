unit JImage;

interface

uses
  JElement;

type
  JW3Image = partial class(TElement)
  public
    constructor Create(parent: TElement); virtual;
  end;

implementation

{ JW3Image }

constructor JW3Image.Create(parent: TElement);
begin
  inherited Create('img', parent);

  self.SetAttribute('loading','lazy');

end;

end.
