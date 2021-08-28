unit JInput;

interface

uses
  JElement;

type
  JW3Input = class(TElement)
  private
    procedure SetText(S1: String);
    function  GetText : String;
  public
    constructor Create(parent: TElement); virtual;
    property Text : string read GetText write SetText;
  end;

implementation

{ JW3Input }

constructor JW3Input.Create(parent: TElement);
begin
  inherited Create('input', parent);
  self.SetAttribute('type','text');
end;

Procedure JW3Input.SetText(S1: String);
begin
  handle.value := S1;
end;

Function JW3Input.GetText : String;
begin
  Result := handle.value;
end;

end.


