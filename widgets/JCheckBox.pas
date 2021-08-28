unit JCheckBox;

interface

uses
  JElement, JPanel;

type
  JW3CheckBox = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
    Checked: Boolean := false;
    Label: String;
    CheckBoxDimension: integer := 16;
    Box : TElement;
    Disabled : boolean := false;
  end;

var
  CheckImage: String;

implementation

uses Globals;

{ JW3CheckBox }

constructor JW3CheckBox.Create(parent: TElement);
begin
  inherited Create('div', parent);                //background for checkbox & label

  //create checkbox
  self.Box := TElement.Create('div', self);

  self.Box.SetProperty('border','1px solid silver');
  self.Box.SetProperty('border-radius','5px');
  self.Box.setProperty('background-size', 'cover');
  self.Box.SetProperty('cursor','pointer');
  self.Box.Width  := CheckBoxDimension;
  self.Box.Height := CheckBoxDimension;

  self.Box.OnClick := procedure(sender: TObject)
  begin
    If not Disabled then begin
      Checked := not Checked;
      If Checked
        then self.Box.SetProperty('background-image',CheckImage)
        else self.Box.SetProperty('background-image','none');
      window.postMessage([self.handle.id,'click',checked],'*');
    end else begin
      //window.alert('checkbox cannot be (un)checked');
    end;
  end;

  self.OnClick := self.Box.OnClick;

  //self.Observe;
  self.OnReadyExecute := procedure(sender: TObject)
  begin
    If Checked then
      self.Box.SetProperty('background-image',CheckImage);

    If Disabled then
      self.Label := '<font color="silver">' + Label + '</font>';

    var Label1 := JW3Panel.Create(self);
    Label1.SetinnerHTML(Label);
    Label1.OnClick := self.Box.OnClick;
    Label1.SetProperty('cursor','pointer');
    Label1.SetProperty('font-size', '0.9em');
    Label1.Handle.style.width:='auto';
    Label1.Handle.style.height:='auto';

    self.Box.SetBounds(0,0,CheckBoxDimension,CheckBoxDimension);
    Label1.SetBounds(trunc(CheckBoxDimension*1.5),
                     self.Box.top+trunc(CheckBoxDimension*1.3)-Label1.handle.clientHeight,
                     Label1.handle.clientWidth+2,
                     CheckBoxDimension-CheckBoxDimension+Label1.handle.clientHeight);

  end;

end;

initialization

  CheckImage := 'url(data:image/jpeg;base64,'+
    '/9j/4AAQSkZJRgABAgAAZABkAAD/7AARRHVja3kAAQAEAAAAHgAA/+4ADkFkb2JlAGTAAAAAAf/bAIQ' +
    'AEAsLCwwLEAwMEBcPDQ8XGxQQEBQbHxcXFxcXHx4XGhoaGhceHiMlJyUjHi8vMzMvL0BAQEBAQEBAQEB' +
    'AQEBAQAERDw8RExEVEhIVFBEUERQaFBYWFBomGhocGhomMCMeHh4eIzArLicnJy4rNTUwMDU1QEA/QEB' +
    'AQEBAQEBAQEBA/8AAEQgAMgAyAwEiAAIRAQMRAf/EAH4AAQADAQEBAAAAAAAAAAAAAAABAgMFBAYBAAM' +
    'BAQAAAAAAAAAAAAAAAAABAwIFEAACAgEDAAcHBQAAAAAAAAABAgADBBEhMVFhIjJCMwVBsdESUmITcYG' +
    'hkgYRAAIBAwIGAwAAAAAAAAAAAAACARESAzFRIUFhccEiMhME/9oADAMBAAIRAxEAPwCCzMSzEszbsx3' +
    'JJ5JiQOJM75wBERABE1x8bIyX/Hj1mxwNSB7B1k7TN0et2R1Kup0ZTsQRFWK0rFdh0mlaTTfkV0HREmI' +
    'xEDibLiZTUHJWpjQvesA225mI4nf9B9WrRFwMjRV1Iqc8do6/K37naTzO6Jci30njHTmUwojta7WVjhP' +
    'XkcGb4eHfm3iigasd2Y8KvSZ1/UP865yFbBAFVh7aHYV9Y+3qnvJwvQcLbtO3s8dr/AfxIv8AqWVj6vd' +
    '30XbuWT8rQ0/b6Imrb9gTheg4Wg7TtwPHa/w90+WyL3yb3vs0+ew6nTiWy8u/Mva+9tWPAHCj6V6pjN4' +
    'MNlWabsj/ACnwYz5r6KsW40+MeRERLkCBxJkDgSYAdrA/0b49H4slGuKDStwRr+j6++cvLy78y833tqx' +
    '2AHCj6VmMSa4catLKtJYo2bIywrNMwoiIlCYiIgBe7z7e7328vy+fB9vRKREUaR2CdZEREYCIiAFP7cx' +
    'ERmT/2Q==)';

end.
