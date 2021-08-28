unit JRadioButton;

interface

uses
  JElement, JPanel;

type
  JW3RadioButton = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
    Checked: Boolean := false;
    Label: String;
    RadioButtonDimension: integer := 16;
    Button : TElement;
  end;

var
  CheckImage: String;

implementation

uses Globals;

{ JW3RadioButton }

constructor JW3RadioButton.Create(parent: TElement);
begin
  inherited Create('div', parent);                //background for RadioButton & label

  //create RadioButton
  self.Button := TElement.Create('div', self);

  self.Button.SetProperty('border','1px solid #0066cc');
  self.Button.SetProperty('border-radius','50%');
  self.Button.setProperty('background-size', 'cover');
  self.Button.SetProperty('cursor','pointer');
  self.Button.Width  := RadioButtonDimension;
  self.Button.Height := RadioButtonDimension;

  self.Button.OnClick := procedure(sender: TObject)
  begin
    //set all radiobuttons to un-selected
    var d := self.handle.parentNode.children;
    for var i := 0 to d.length -1 do begin
      var e := d[i].children;
      for var j := 0 to e.length -1 do begin
        e[j].style.backgroundImage := 'none';
      end;
    end;
    //set clicked one to selected
    self.Button.SetProperty('background-image',CheckImage);
    //window.postMessage([self.Button.handle.id,'click',checked],'*');
    //old method, replaced with DispatchEvent :

    //dispatch event
    DisPatchEvent('RadioButton',self.handle.id,'click',checked);

    // event listener for RadioButton click in calling program :
    //  document.addEventListener('RadioButton', procedure(e: variant)
    //  begin
    //    var msg := JSON.parse(e.detail);
    //    If msg.id = RadioButton1.handle.id then begin


  end;

  self.OnClick := self.Button.OnClick;

  //self.Observe;
  self.OnReadyExecute := procedure(sender: TObject)
  begin
    If Checked then
      self.Button.SetProperty('background-image',CheckImage);

    var Label1 := JW3Panel.Create(self);
    Label1.SetinnerHTML(Label);
    Label1.OnClick := Button.OnClick;
    Label1.SetProperty('cursor','pointer');
    //Label1.SetProperty('font-size', '0.85em');
    Label1.Handle.style.width:='auto';
    Label1.Handle.style.height:='auto';

    self.Button.SetBounds(0,0,RadioButtonDimension,RadioButtonDimension);
    Label1.SetBounds(trunc(RadioButtonDimension*1.5),
                     self.Button.top+RadioButtonDimension-Label1.handle.clientHeight+2,
                     Label1.handle.clientWidth+2,
                     RadioButtonDimension-RadioButtonDimension+Label1.handle.clientHeight);

  end;

end;

initialization

  CheckImage := 'url(data:image/jpeg;base64,'+
     '/9j/4AAQSkZJRgABAgAAZABkAAD/7AARRHVja3kAAQAEAAAAHgAA/+4ADkFkb2JlAGTAAAAAAf/bAIQ' +
     'AEAsLCwwLEAwMEBcPDQ8XGxQQEBQbHxcXFxcXHx4XGhoaGhceHiMlJyUjHi8vMzMvL0BAQEBAQEBAQE' +
     'BAQEBAQAERDw8RExEVEhIVFBEUERQaFBYWFBomGhocGhomMCMeHh4eIzArLicnJy4rNTUwMDU1QEA/Q' +
     'EBAQEBAQEBAQEBA/8AAEQgAOQA5AwEiAAIRAQMRAf/EAI8AAAICAwEAAAAAAAAAAAAAAAUGAAQBAgcD' +
     'AQEBAQEBAAAAAAAAAAAAAAAFAwQBAhAAAQMDAAUHCgcAAAAAAAAAAQACAxEEBSExQRITUWGBkSJCBnG' +
     'hscHRMlJyIzPhYpKyUxQWEQACAQMCAwcFAQAAAAAAAAABAhEAEgMTBCFBUWGBocEiQhQxcZEycpL/2g' +
     'AMAwEAAhEDEQA/AOgKnf5O1sGVldV592Nulx9imUyDLC2Mp0yO7MTeV3sCTZppZ5HSyuL5HGrnFattt' +
     'tT1NwQeNZdzudP0rxc+FE7nxHfykiHdgZsoN53W72KmcpkSam5k/UR6FVWKhIrhxqICL+KObNkYyXb8' +
     '0RhzuTiNeNxB8LwHfijWP8Q29yRFcAQSnQDXsOPl2dKVVF4ybbE4/UKeq8K949zlQ/sWHRuNdAWUA8P' +
     '5VzyLG4dV1PovOug7h9SPo74z6ul3zyt60j8lNLV7o53dKUvENy6bIGLuQANHlPacULVjIEm+uCdfFf' +
     '8AuKrpXEoXGijkoorKxbI7HmxoxhcK27b/AGbmvArRjBo36ayTyJjjs7WJgZHCxrRs3QvPGtY3H24j9' +
     '3htPWKnzq0is+Z3dpJgGAKVwYURFgCSJJoRkcBbXDHSWzRDONIA0NceQjYlUgtJaRQg0I5wugpLzLWt' +
     'ydwG6t4HpIBK1bLMzEoxugSJrLvcKqA6i2TBiqkcj4pGyxmj2EOaecJj/wBNb/xuS0taBbbRcG5gR3G' +
     'sVxtK8iZ7xRPPW7oMlIaUbLSRvTr86HJvzWNN9bAx/fiqWfmB1t6UoEFpIcKEaCDoIIUNrlD4wPcgtP' +
     'lV91iKZCfa5uHnTDgMtCyIWVy4MLT9J50NIPdJR/XpC5+t2zztG62R7W8gcQFPNsg7Fla2eJETVMO9K' +
     'KFZbo4AzFOOQydvYxEvcHTU7EQ1k8/IEmySPlkdLIaveS5x5ytSSTUmpOslRWwbdcQMG4n6mo59w2Ui' +
     'RaB9BUAJIDRUnQANpRr/ADE/xt6lPD2NdLML2UUijP069542+QelM65rrrjFPtP+uld0G0Dlj3D/AD1' +
     'qIXk8HBekyxnhXB1u7rvmHrRRRGYdS8aU3dnnSebTsOrFvb5Uk3OKv7YniQuLR32Deb1hVCCDQihXQV' +
     'TuPvMSqnNHqGM/ZiPKimGGfScg+6g+dJ8NrczmkMT3k8gNOtGsf4bcSJL40GyFp1/M4epMLdSypZ/k2' +
     'mwKP5Mt4xVcHxrheWP9CF8JrVrWsaGMAa1ooANAAC2UURfGe2lOEdlf/9k=)';

end.

