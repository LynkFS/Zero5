unit JToggle;

interface

uses
  JElement, JButton;

type
  JW3Toggle = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
    Left, Middle, Right : JW3Button;
  end;

implementation

{ JW3Toggle }

constructor JW3Toggle.Create(parent: TElement);
begin
  inherited Create('div', parent);
  Left   := JW3Button.Create(self);
  Right  := JW3Button.Create(self);
  Middle := JW3Button.Create(self);
  Left.setProperty(  'background-color', 'whitesmoke');
  Right.setProperty( 'background-color', 'whitesmoke');
  Middle.setProperty('background-color', 'whitesmoke');
  Left.setProperty(  'color', 'black');
  Right.setProperty( 'color', 'black');
  Middle.setProperty('color', 'black');
  Left.setProperty(  'border-radius', '0px');
  Right.setProperty( 'border-radius', '0px');
  Middle.setProperty('border-radius', '0px');
  Left.Caption   := '-';
  Right.Caption  := '+';
  Middle.Caption := '0';

  //self.Observe;
  self.OnReadyExecute := procedure(sender: TObject)
  begin
    //position Buttons
    Left.SetBounds(0,1,trunc(self.width*3/8),self.height-2);
    Middle.SetBounds(trunc(self.width*3/8),1,trunc(self.width*2/8),self.height-2);
    Right.SetBounds(trunc(self.width*5/8),1,trunc(self.width*3/8),self.height-2);
    self.setProperty('background-color', 'whitesmoke');
  end;

end;

end.
