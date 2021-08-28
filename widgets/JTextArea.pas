unit JTextArea;

interface

uses
  JElement;

type
  JW3TextArea = class(TElement)
  private
    procedure SetText(S1: String);
    function  GetText : String;
  public
    constructor Create(parent: TElement); virtual;
    property Text : string read GetText write SetText;
  end;

implementation

uses Globals;

{ JW3TextArea }

constructor JW3TextArea.Create(parent: TElement);
begin
  inherited Create('textarea', parent);
end;

Procedure JW3TextArea.SetText(S1: String);
begin
  handle.value := S1;
end;

Function JW3TextArea.GetText : String;
begin
  Result := handle.value;
end;

end.
