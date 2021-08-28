unit JApplication;

interface

uses
  JElement, JForm;

type
  JW3Application = class(TElement)
  public
    FormNames: Array of String;
    FormsClasses: Array of TFormClass;       //TFormClass = class of JW3Form;
    FormsInstances: Array of TW3Form;
    constructor Create(parent: TElement); virtual;
    procedure CreateForm(FormName: String; aClassType: TFormClass);
    procedure GoToForm(FormName: String);
  end;

implementation

uses Globals;

{ JW3Application }

constructor JW3Application.Create(parent: TElement);
begin
  inherited Create('div', parent);

  setProperty('width','100%');
  setProperty('height','100%');
  setProperty('background-color','white');

end;

procedure JW3Application.CreateForm(FormName: String; aClassType: TFormClass);
begin
//
  FormNames.Add(FormName);
  FormsClasses.Add(aClassType);
  FormsInstances.Add(nil);
end;

procedure JW3Application.GoToForm(FormName: String);
begin
//
  For var i := 0 to FormNames.Count -1 do begin
    If FormsInstances[i] <> nil then
      FormsInstances[i].SetProperty('display','none');
    If FormNames[i] = FormName then begin
      If FormsInstances[i] = nil       //form has never been displayed yet
        then FormsInstances[i] := FormsClasses[i].Create(self)
        else FormsInstances[i].SetProperty('display','inline-block');

      (FormsInstances[i] as FormsClasses[i]).InitializeForm;    //ClearForm;
      (FormsInstances[i] as FormsClasses[i]).InitializeObject;  //ShowForm;
    end;
  end;
end;

end.

