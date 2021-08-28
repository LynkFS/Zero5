unit JToolBar;

interface

uses
  JElement, JPanel;

type
  JW3ToolBar = class(TElement)
  private
    ToolBarItems: Array of JW3Panel;
  public
    constructor Create(parent: TElement); virtual;
    Procedure AddMenu(menuText, GotoForm, color: string);
    Procedure SetActiveMenu(formname: string);
  end;

implementation

uses Globals;

{ JW3MenuBar }

constructor JW3ToolBar.Create(parent: TElement);
begin
  inherited Create('div', parent);
end;

procedure JW3ToolBar.AddMenu(menuText, GotoForm, color: string);
begin
//
  var Panel0 := JW3Panel.Create(self);
  Panel0.SetBounds(20 + ((ToolBarItems.Count) * 100), 14, 90, 26);
  Panel0.SetinnerHtml(menuText);
  Panel0.setProperty('color', color);
  Panel0.setProperty('cursor','pointer');
  Panel0.SetProperty('font-size', '0.9em');

  ToolBarItems.Add(Panel0);
  Panel0.Tag := GotoForm;
  Panel0.OnClick := procedure(Sender:TObject)
    begin
      if Application.FormNames.IndexOf((Sender as JW3Panel).tag) > -1     //if form
        then Application.GoToForm((Sender as JW3Panel).tag)               //then gotoform
        else window.postMessage([self.handle.id,'click',GoToForm],'*');   //else send message
    end;
end;

procedure JW3ToolBar.SetActiveMenu(FormName: String);
begin
//
  For var i := 0 to ToolBarItems.Count -1 do begin
    ToolBarItems[i].setProperty('font-weight', 'normal');
    ToolBarItems[i].setProperty('text-decoration', 'none');
    If ToolBarItems[i].Tag = FormName then
    begin
      ToolBarItems[i].setProperty('font-weight', 'bold');
      ToolBarItems[i].setProperty('text-decoration', 'underline');
    end;
  end;
end;

end.
