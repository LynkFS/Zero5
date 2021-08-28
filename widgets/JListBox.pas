unit JListBox;

interface

uses
  JElement, JPanel, JInput;

type
  JW3ListBox = class(TElement)
  public
    ItemCount : integer;
    constructor Create(parent: TElement); virtual;
    Procedure Add(item: TElement);              //either a TElement
    Procedure Add(text: String); overload;      //or a string
    Procedure Clear;
    Procedure Sort;
    Editable : boolean := false;
    RowHeight : integer := 0;
  end;

implementation

uses
  Globals;

{ JW3ListBox }

constructor JW3ListBox.Create(parent: TElement);
var
  atop, aheight: integer;
begin
  inherited Create('div', parent);

  ItemCount := 0;
  //using GPU
  self.setProperty('will-change', 'transform');   //'scroll-position'

  self.handle.onscroll := procedure
  begin
    var c := self.handle.children;
    for var i := 0 to c.length -1 do begin
      atop    := StrToInt(StrBefore(c[i].style.top, 'px'));
      aheight := StrToInt(StrBefore(c[i].style.height, 'px'));

      c[c.length-1].style.display := 'inline-block';          //set last one visible

      if ((atop + aheight) < self.handle.scrollTop) and       //all previous visible set to none
         (c[i].style.display = 'inline-block') then
        c[i].style.display := 'none';

      if (atop + aheight >= self.handle.scrollTop) and        //if in viewport make visible
         (atop <= self.handle.scrollTop + self.height + 2) then
      begin
        c[i].style.display := 'inline-block';
      end;

      if (atop > self.handle.scrollTop + self.height + 2) and  //if past viewport then set invisible
         (c[i].style.display = 'inline-block') and
         (i < c.length-1) then
        c[i].style.display := 'none';
    end;
  end;

end;

procedure JW3ListBox.Add(item: TElement);
begin
//
  item.SetProperty('padding','0px');
  item.SetProperty('margin','0px');
  item.setProperty('width','calc(100% - 2px)');
  If Item.height = 0 then begin
    If RowHeight = 0 then Item.Height := 20 else Item.Height := RowHeight;
  end;
  item.SetBounds(0, ItemCount * (item.height+2), item.width, item.height+1);

  If editable then begin
    item.SetProperty('cursor','pointer');
    item.SetAttribute('contenteditable','true');
  end else begin
    item.SetAttribute('readonly','true');      //for JW3Input's
  end;

  //the following construct sets all entries which are not visible (outside the viewport)
  //to display-none, except the last entry which always will have display-inlineblock
  //this will render a correctly dimensioned proportional scroller

  //1-set the last entry to display-none if it is not visible
  If (item.Top > (self.Height + item.height)) and (self.height > 0) then
    self.handle.children[self.handle.children.length-1].style.display := 'none';

  //2-append the new item
  self.FElement.appendchild(item.FElement);

  //3-always set the last entry to inline-block.
  self.handle.children[self.handle.children.length-1].style.display := 'inline-block';

  //override border-width to 1px
  item.handle.style['border-width'] := '1px';

  //onfocus = bringtofront
  //onblur = sendtoback
  Item.handle.onfocus := lambda() item.handle.style['z-index'] := 999; end;
  Item.handle.onblur  := lambda() item.handle.style['z-index'] := 1;   end;

  Inc(ItemCount);
end;

procedure JW3ListBox.Add(text: String);
begin
//
  var Item := JW3Input.Create(self);
  Item.handle.value := text;
  //if RowHeight not specified then default 20
  If RowHeight <> 0 then Item.height := RowHeight else Item.Height := 20;
  item.setProperty('border','1px solid silver');

  Add(Item);
end;

procedure JW3ListBox.Clear;
begin
  While assigned(FElement.firstChild) do
    FElement.removeChild(FElement.firstChild);
  ItemCount := 0;
end;

procedure JW3ListBox.Sort;
begin
  var element : array of variant;
  var children := self.handle.children;
  asm
    @element = [].slice.call(@children);
  end;
  element.sort(function(a, b: variant):integer begin
    result := 0;
    if (a.value > b.value) then result := 1;
    if (a.value < b.value) then result := -1;
  end);
  Clear;
  //Element.Reverse;     //sort descending
  for var j := 0 to element.length-1 do begin
    var s : string := element[j].value;
    Add(s);
  end;
  Element.Clear;
  Children.Clear;
end;

end.

