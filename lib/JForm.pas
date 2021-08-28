unit JForm;

interface

uses
  JElement;

type
  TW3Form = class(TElement)
  public
    procedure InitializeForm; virtual;
    procedure InitializeObject; virtual;
    procedure ReSize; virtual;
    constructor Create(parent: TElement); virtual;
    //Caption : String;
  end;

  TFormClass = class of TW3Form;

implementation

uses Globals;

{ TW3Form }

constructor TW3Form.Create(parent: TElement);
begin
  inherited Create('div', parent);
  SetProperty('border','1px double #2196f3');
  Left := 5; Top := 5;
  setProperty('width','calc(100% - 12px)');
  setProperty('height','calc(100% - 12px)');
  setProperty('background-color','white');

  /* This forces the browsers that support it to
     use the GPU rather than CPU for movement */
  self.setProperty('will-change','transform');
  self.setProperty('-webkit-transform','translateZ(0px)');
  self.setProperty(   '-moz-transform','translateZ(0px)');
  self.setProperty(    '-ms-transform','translateZ(0px)');
  self.setProperty(     '-o-transform','translateZ(0px)');
  self.setProperty(        'transform','translateZ(0px)');

  OnResize := procedure(sender:TObject)
  begin
    screenwidth  := window.innerWidth;
    screenheight := window.innerHeight;
    ReSize;
  end;

end;

Procedure TW3Form.InitializeForm;
begin
  //clear form
  self.Clear;
end;

Procedure TW3Form.InitializeObject;
begin
//
end;

Procedure TW3Form.ReSize;
begin
//
end;

end.

