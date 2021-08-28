unit JGrid;

interface

uses
  JElement, JListBox, JPanel;

type
  JW3Grid = class(TElement)
  private
    //ListBox: JW3ListBox;
    Item: JW3Panel;
    ItemHeight: integer;
    ColumnCount : integer;
    ColumnWidths : array of integer;
    Columns : array of JW3Panel;
    Procedure HandleColumnResize(columnTitle: JW3Panel);
  public
    ListBox: JW3ListBox;
    constructor Create(parent: TElement); virtual;
    procedure AddColumn(title: string; colwidth: integer);
    procedure AddCell(row, column: integer; cell: TElement);
    CanResize : boolean := false;
  end;

implementation

uses Globals;

{ JW3Grid }

constructor JW3Grid.Create(parent: TElement);
begin
  inherited Create('div', parent);

  ListBox := JW3ListBox.Create(self);
  Item := JW3Panel.Create(ListBox);
  ColumnCount := 0;

  //self.Observe;
  self.OnReadyExecute := procedure(sender: TObject)
  begin
    //set ListBox position relative to Grid dimensions
    ListBox.SetBounds(0,28,self.width-2,self.height-28);
  end;
end;

procedure JW3Grid.AddColumn(title: string; colwidth: integer);
begin

//add columnwidth to array
  ColumnWidths.Add(colwidth);

//create column title
  var columnTitle := JW3Panel.Create(self);
  columnTitle.SetinnerHTML(title);
  columnTitle.SetBounds(0,0,colwidth,24);
  columnTitle.SetProperty('border','1px solid grey');
  columnTitle.SetProperty('background-color','lightgrey');

//compute offset of column title
  var CurLength : integer := 2;
  For var i := 0 to ColumnCount-1 do begin
    CurLength := CurLength + ColumnWidths[i] + 6;
  end;
  columnTitle.Left := CurLength;

//make columns resizeable if required (default = non resizeable)
  if CanResize then HandleColumnResize(columnTitle);

//doubled up, ColumnCount is same as ColumnsWidths.Count
  Inc(ColumnCount);
end;

procedure JW3Grid.AddCell(row, column: integer; cell: TElement);
begin
//
//when inserting the first cell in a row, create the row (a panel) first
  If Column = 1 then begin
    Item := JW3Panel.Create(ListBox);
    Item.SetProperty('border-bottom','none');
    Item.SetProperty('width',inttostr(self.width-2)+'px');
    Item.SetProperty('height',inttostr(cell.height+6)+'px');
    ItemHeight := Cell.Height;
  end;

//keep track of largest height of any cell in a row
  If Cell.Height > ItemHeight then ItemHeight := Cell.Height;

//compute offset for the cell
  var CurLength : integer := 0;
  For var i := 1 to Column-1 do begin
    CurLength := CurLength + ColumnWidths[i-1] + 6;
  end;
  Cell.Left := CurLength;

//set some cell properties and attach cell to the listbox row
  Cell.Top := 0;
  Cell.SetProperty('width',inttostr(ColumnWidths[column-1])+'px');
  Cell.setProperty('border', '1px solid lightgrey');
  Item.FElement.appendchild(Cell.FElement);

//when inserting the last cell in a row,
// - set the height of the row to largest cell height
// - and add row to listbox
  If Column = ColumnCount then
  begin
    var c := Item.handle.children;
    for var i := 0 to c.length -1 do begin
      c[i].style.height  := inttostr(Itemheight+6)+'px';
    end;
    Item.SetProperty('height',inttostr(ItemHeight+10)+'px');
    ListBox.Add(Item);
  end;
end;

procedure JW3Grid.HandleColumnReSize(columnTitle: JW3Panel);
begin
//set column titles & listbox to non-selectable
//as it interferes somewhat visually while dragging
  styleSheet.insertRule('#' + columnTitle.FElement.id + ' { user-select:none}', 0);
  styleSheet.insertRule('#' + columnTitle.FElement.id + ' { -webkit-user-select:none}', 0);
  styleSheet.insertRule('#' + columnTitle.FElement.id + ' { -moz-user-select:none}', 0);
  styleSheet.insertRule('#' + columnTitle.FElement.id + ' { -ms-user-select:none}', 0);

  styleSheet.insertRule('#' + ListBox.FElement.id + ' { user-select:none}', 0);
  styleSheet.insertRule('#' + ListBox.FElement.id + ' { -webkit-user-select:none}', 0);
  styleSheet.insertRule('#' + ListBox.FElement.id + ' { -moz-user-select:none}', 0);
  styleSheet.insertRule('#' + ListBox.FElement.id + ' { -ms-user-select:none}', 0);

//create resizers
  var ReSizer := JW3Panel.Create(columnTitle);
  ReSizer.SetProperty('background-color','gold');
  ReSizer.SetBounds(0,1,4,22);
  ReSizer.Left := columnTitle.Width - 4;
  ReSizer.SetProperty('cursor','w-resize');
  ReSizer.tag := IntToStr(ColumnCount);

  //map touchstart to mousedown, touchend to mouseup and touchmove to mousemove
  ReSizer.handle.ontouchstart := lambda(e: variant) touch2Mouse(e); end;
  ReSizer.handle.ontouchmove  := ReSizer.handle.ontouchstart;
  ReSizer.handle.ontouchend   := ReSizer.handle.ontouchstart;

  //adjust width of columnTitle while dragging
  ReSizer.handle.onmousedown := procedure(e: variant)
  begin
    var saveX := e.clientX;
    self.handle.onmousemove := procedure(e: variant)
    begin
      columnTitle.handle.style.zIndex := '999';     //BringToFront
      columnTitle.Width := columnTitle.Width - (saveX - e.clientX);
      saveX := e.clientX;
      ReSizer.Left := columnTitle.Width - 4;
    end;
  end;

  Columns.Add(columnTitle);

  //mouseUp = end of dragging
  columnTitle.handle.onmouseup := procedure
  begin
    ColumnWidths[ColumnCount] := columnTitle.Width;
    //get all rows
    var c := ListBox.handle.children;
    for var i := 0 to c.length -1 do begin
      //get all cells
      var d := c[i].children;
      for var j := 0 to d.length -1 do begin
        //set new cell widths for the resized column
        if j = StrToInt(ReSizer.Tag) then begin
          d[j].style.width := inttostr(ColumnWidths[ColumnCount]) + 'px';
          var diff : integer := ColumnWidths[j] - columnTitle.Width;
          //shift all columns on the right hand side
          for var k := j+1 to d.length -1 do begin
            d[k].style.left := IntToStr(StrToInt(StrBefore(d[k].style.left, 'px')) - diff) + 'px';
            Columns[k].Left := StrToInt(StrBefore(d[k].style.left, 'px'))+2;
          end;
        end;
      end;
    end;
    ColumnWidths[StrToInt(ReSizer.Tag)] := columnTitle.Width;
    columnTitle.handle.style.zIndex := '0';

    self.handle.onmousemove := procedure begin end;   //nullify mousemove

  end;

end;

end.


/////////////////////////////////////////////////////////////////////////////

unit JGrid;

interface

uses
  JElement, JListBox, JPanel;

type
  JW3Grid = class(TElement)
  private
    ListBox: JW3ListBox;
    Item: JW3Panel;
    ItemHeight: integer;
    ColumnCount : integer;
    ColumnWidths : array of integer;
  public
    constructor Create(parent: TElement); virtual;
    procedure AddColumn(title: string; colwidth: integer);
    procedure AddCell(row, column: integer; cell: TElement);
  end;

implementation

uses Globals;

{ JW3Grid }

constructor JW3Grid.Create(parent: TElement);
begin
  inherited Create('div', parent);

  ListBox := JW3ListBox.Create(self);
  Item := JW3Panel.Create(ListBox);
  ColumnCount := 0;

  //self.Observe;
  self.OnReadyExecute := procedure(sender: TObject)
  begin
    //set ListBox position relative to Grid dimensions
    ListBox.SetBounds(0,26,self.width-2,self.height-28);
  end;
end;

procedure JW3Grid.AddColumn(title: string; colwidth: integer);
begin

//add columnwidth to array
  ColumnWidths.Add(colwidth);

//create column title
  var columnTitle := JW3Panel.Create(self);
  columnTitle.SetinnerHTML(title);
  columnTitle.SetBounds(0,0,colwidth,24);
  columnTitle.SetProperty('border','1px solid grey');
  columnTitle.SetProperty('background-color','lightgrey');

//compute offset of column title
  var CurLength : integer := 2;
  For var i := 0 to ColumnCount-1 do begin
    CurLength := CurLength + ColumnWidths[i] + 6;
  end;
  columnTitle.Left := CurLength;

//doubled up, ColumnCount is same as ColumnsWidths.Count
  Inc(ColumnCount);
end;

procedure JW3Grid.AddCell(row, column: integer; cell: TElement);
begin
//
//when inserting the first cell in a row, create the listbox line-item
  If Column = 1 then begin
    Item := JW3Panel.Create(ListBox);
    Item.SetProperty('border-bottom','none');
    Item.SetProperty('width',inttostr(self.width-2)+'px');
    Item.SetProperty('height',inttostr(cell.height+6)+'px');
    ItemHeight := Cell.Height;
  end;

//keep track of largest height of any cell in a row
  If Cell.Height > ItemHeight then ItemHeight := Cell.Height;

//compute offset for the cell
  var CurLength : integer := 2;
  For var i := 1 to Column-1 do begin
    CurLength := CurLength + ColumnWidths[i-1] + 6;
  end;
  Cell.Left := CurLength;

//set some cell properties and attach cell to the listbox line-item
  Cell.Top := 2;
  Cell.SetProperty('width',inttostr(ColumnWidths[column-1]-4)+'px');
  Cell.setProperty('border', '1px solid lightgrey');
  Item.FElement.appendchild(Cell.FElement);

//when inserting the last cell in a row,
// - set the height of the listbox line-item to largest cell height
// - and add listbox line-item to listbox
  If Column = ColumnCount then
  begin
    var c := Item.handle.children; //document.getElementById(Item.FElement.id).children;
    for var i := 0 to c.length -1 do begin
      c[i].style.height  := inttostr(Itemheight+6)+'px';
    end;
    Item.SetProperty('height',inttostr(ItemHeight+10)+'px');
    ListBox.Add(Item);
  end;
end;

end.

