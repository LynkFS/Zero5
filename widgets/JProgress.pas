unit JProgress;

interface

uses
  JElement, JPanel;

type
  JW3Progress = class(TElement)
  private
    procedure SetPerc(aPerc: float);
    function  GetPerc: float;
    Light: TElement;
    timer : variant;
  public
    constructor Create(parent: TElement); virtual;
    property Perc: float read getPerc write setPerc;
    ProgressBar : TElement;
  end;

implementation

uses Globals;

{ JW3Progress }

constructor JW3Progress.Create(parent: TElement);
begin
  inherited Create('div', parent);

  ProgressBar := JW3Panel.Create(self);

  Light := JW3Panel.Create(ProgressBar);
  Light.SetProperty('border-radius','2px');
  Light.SetProperty('background-color','white');
  Light.SetProperty('opacity','0.5');

  Light.Left := 0;
  timer := window.setInterval(lambda
    Light.Left := Light.Left + 4;
    If Light.Left + Light.Width > ProgressBar.Width then Light.Left := 0;
    If Light.Left + Light.Width + 2 >= Width then begin
      Light.Left := -Light.Width;
      window.clearInterval(timer);
    end;
  end, 20);
//
end;

procedure JW3Progress.SetPerc(aPerc: Float);
begin
  If aPerc > 100 then aPerc := 100;
  If aPerc < 0   then aPerc := 0;

  var f : float := (Width * aPerc)/100;
  ProgressBar.SetProperty('width',FloatToStr(f,0) + 'px');
  ProgressBar.SetBounds(0,0,ProgressBar.Width,self.height);
  ProgressBar.SetProperty('overflow','hidden');

  Light.Width := ProgressBar.Height * 2;
  Light.Height := ProgressBar.Height - 4;
  Light.Top := 2;
end;

function JW3Progress.GetPerc: float;
begin
  var f : float := (ProgressBar.width / width) * 100;
  Result := f;
end;

end.
