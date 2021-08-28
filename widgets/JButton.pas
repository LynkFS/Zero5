unit JButton;

interface

uses
  JElement;

type
  JW3Button = class(TElement)
  private
    procedure setDisabled(disabled: boolean);
    function  getDisabled: boolean;
  public
    constructor Create(parent: TElement); virtual;
    property Caption : string read GetInnerHtml write SetInnerHtml;
    property Disabled: Boolean read getDisabled write setDisabled;
  end;

implementation

uses Globals;

{ JW3Button }

constructor JW3Button.Create(parent: TElement);
begin
  inherited Create('button', parent);
  SetProperty('color','white');
  SetProperty('cursor','pointer');
  SetProperty('border','0px');
  SetProperty('border-radius', '4px');
  SetProperty('user-select', 'none');

  SetCss(           'background-color' , getCSSVar('--button-colorbase'));
  SetCss('focus',   'outline' ,          getCSSVar('--button-borderfocus'));
  SetCss('enabled', 'background-color' , getCSSVar('--button-colorbase'));
  SetCss('disabled','background-color' , getCSSVar('--button-disabled'));
  SetCss('hover',   'background-color' , getCSSVar('--button-colorhover'));
  SetCss('active',  'background-color' , getCSSVar('--button-coloractive'));

  //note the order of hover and active above, hover has to be prior to active

  Disabled := false;

end;

procedure JW3Button.setDisabled(disabled: boolean);
begin
  if disabled then
  begin
    self.handle.setAttribute('disabled',true);
    self.setProperty('pointer-events','none');
    SetProperty('opacity','0.6');
    SetProperty('color','rgb(96,96,96)');
  end else
  begin
    self.handle.removeAttribute('disabled');
    self.setProperty('pointer-events','auto');
    SetProperty('opacity','1.0');
    SetProperty('color','white');
  end;
end;

function  JW3Button.getDisabled: boolean;
begin
  result := false;
  if self.handle.hasAttribute('disabled') then
  begin
    result := self.handle.getAttribute('disabled');
  end;

end;

end.
