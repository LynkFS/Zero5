unit JDBGrid;

interface

uses
  JElement, Types, JGrid, JPanel, JSpinner;

type
  JW3DBGrid = class(TElement)
  private
    procedure LoadCells(row,column: integer);
    procedure LoadGrid;
    Grid : JW3Grid;
    FHttp : JXMLHttpRequest;
    DBRows : Integer;
    Spinner1 : JW3Spinner;
  public
    constructor Create(parent: TElement); virtual;
    Server: string;
    Query : string;
    RowHeight : integer;
    ColumnWidths : array of integer;
  end;

implementation

uses
  Globals;

{ JW3DB }

constructor JW3DBGrid.Create(parent: TElement);
var
  sql_statement : String;
  encodedstr1 : String;
begin
  inherited Create('div', parent);
  setProperty('background-color', 'white');
  RowHeight := 14;   //default

  Grid := JW3Grid.Create(self);    //ordinary grid
  Grid.CanResize := true;

  self.OnReadyExecute := procedure(sender: TObject)
  begin
    Grid.SetBounds(0, 0, self.width, self.height);
    Spinner1 := JW3Spinner.Create(self);
    Spinner1.SetBounds(10, 10, 40, 40);
//
    FHttp := JXMLHttpRequest.Create;
    FHttp.open("POST",Server);
    FHttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    encodedstr1 := window.encodeURIComponent(Query);
    sql_statement := 'sql_statement=' + encodedstr1;
    FHttp.send(sql_statement);

    JGlobalEventHandlers(FHttp).onLoad := lambda(e:JEvent)
      self.handle.removeChild(Spinner1.handle);     //or set 'display' to 'none'
      smscursor := JSON.parse(FHttp.ResponseText);  //smscursor defined in Globals unit
      LoadGrid;
      var sum : integer := 0;
      for var i := 1 to ColumnWidths.Count -1 do begin
        sum += ColumnWidths[i] + 35;       //30 padding + 5 gap
      end;
      self.SetProperty('width',inttostr(sum+30) + 'px');
      Grid.SetProperty('width',inttostr(sum+30) + 'px');
      Grid.ListBox.SetProperty('width',inttostr(sum+24) + 'px');
      result := true;    //dummy statement to avoid compiler warning
    end;
  end;
end;

procedure JW3DBGrid.LoadGrid;                        //called on return of ajax call
var
  colProps, colSize : variant;
begin
  DBRows := smscursor.rows.length;
  if DBRows > 0 then begin
    var v : variant := new JObject;
    v := smscursor.rows[0];                          //get first row
    asm @colProps = Object.keys(@v); end;            //array of field names
    asm @colSize  = Object.keys(@v); end;            //will become array of column widths

    //compute column headers
    for var i := 0 to colProps.length -1 do begin    //initial width = header text width
      colSize[i] := MeasureSize(colProps[i]);        //MeasureSize in Globals unit
    end;
    for var j := 1 to DBRows do begin                //check actual widths in all rows
      for var k := 1 to colProps.length do begin
        v := smscursor.rows[DBRows-1];
        var content : string;
        asm @content = (@v)[Object.keys(@v)[@k-1]]; end;
        if (MeasureSize(content)) > colSize[k-1]
          then colSize[k-1] := MeasureSize(content);  //keep largest column width
      end;
    end;

    //set headers
    for var i := 0 to colProps.length -1 do begin
      If ColumnWidths[i+1] > 0                       //width overrides ?
        then colSize[i] := ColumnWidths[i+1]
        else ColumnWidths[i+1] := Integer(colSize[i]);
      Grid.AddColumn(colProps[i],colSize[i]+30);     //extra padding :(
    end;

    //fill rows and columns
    for var j := 1 to DBRows do begin
      for var k := 1 to colProps.length do begin
        LoadCells(j, k);
      end
    end;
  end else begin
    window.alert('no data');
  end;
end;

procedure JW3DBGrid.LoadCells(row,column: integer);  //called from LoadGrid
begin
  var v : variant := new JObject;
  v := smscursor.rows[row-1];
  var content : string;
  asm @content = (@v)[Object.keys(@v)[@column-1]]; end;

  var Cell := JW3Panel.Create(Grid);
  Cell.Height := RowHeight;    //default = 14
  Cell.SetProperty('font-size', '0.85em');
  Cell.Text := content;
  Cell.OnClick := procedure(sender:TObject) begin window.alert(Cell.Text); end;
  Grid.AddCell(row,column,Cell);
end;

end.


