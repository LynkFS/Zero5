unit JSelect;

interface

uses
  JElement, JListBox, JPanel, JImage;

type
  JW3Select = class(TElement)
  private
    ListBox: JW3ListBox;
    Panel : JW3Panel;
    Chevron : JW3Image;
  public
    constructor Create(parent: TElement); virtual;
    Procedure Add(item: TElement);
    Value : String;
  end;


implementation

uses Globals;

{ JW3Select }

constructor JW3Select.Create(parent: TElement);
begin
  inherited Create('div', parent);

  Panel := JW3Panel.Create(self);
  Panel.OnClick := procedure(sender:TObject)
    begin
      ListBox.SetProperty('display','inline-block');
    end;
  Panel.SetProperty('border','1px solid silver');
  Panel.SetinnerHTML('select...');

  Chevron := JW3Image.Create(self);
  Chevron.SetAttribute('src','images/chevron-down.png');
  Chevron.OnClick := Panel.OnClick;

  ListBox := JW3ListBox.Create(self);
  Listbox.SetProperty('display','none');
  ListBox.Top := 22;

  //self.Observe;
  self.OnReadyExecute := procedure(sender: TObject)
  begin
    Panel.SetBounds(0,0,width-2,20);
    Chevron.SetBounds(width-22,2,16,16);
    Chevron.SetProperty('max-height','16px');
    Chevron.SetProperty('max-width','16px');
    ListBox.Width := self.Width;
    ListBox.Height := self.Height - 22;
  end;
end;

procedure JW3Select.Add(item: TElement);
begin
//
  item.SetProperty('cursor','pointer');
  ListBox.Add(item);
  Item.OnClick := procedure(Sender:TObject)
    begin
      Panel.SetInnerHTML((Sender as TElement).tag);
      Value := (Sender as TElement).tag;
      window.postMessage([self.handle.id,'click',value],'*');
      Listbox.SetProperty('display','none');
    end;

end;

end.

