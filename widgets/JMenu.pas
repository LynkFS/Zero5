unit JMenu;

interface

uses
  JElement, JListBox, JPanel;

type

  JW3MenuNode = class
  public
    Node, ParentNode, NodeDescription : String;
    Level : Integer;
    Children : Array of JW3MenuNode;
    Expanded: Boolean;
    Showing: Boolean;
  end;

  JW3Menu = class(TElement)
  private
    ListBox: JW3ListBox;
    Title : JW3Panel;
    Function  FindNode(ThisNode: string):JW3MenuNode;
    Procedure HideAllChildren(node: JW3MenuNode);
    Procedure Order(node: JW3MenuNode);
    Node : JW3MenuNode;
    Root : JW3MenuNode;
  public
    constructor Create(parent: TElement); virtual;
    Procedure Add(NewNode, ParentNode, NodeDescription: String);
    Procedure ShowTree;
    Subject: String;
  end;


implementation

uses Globals;

{ JW3Menu }

constructor JW3Menu.Create(parent: TElement);
begin
  inherited Create('div', parent);
  setProperty('background-color', 'transparent');

  Title := JW3Panel.Create(self);
  Title.SetProperty('background-color','black');

  ListBox := JW3ListBox.Create(self);
  ListBox.Top := 8;
  ListBox.handle.style.cursor := 'pointer';

  //self.Observe;
  self.OnReadyExecute := procedure(sender: TObject)
  begin
    Title.SetBounds(0,0,width,8);
    Title.setProperty('border-top-left-radius', '0.25em');
    Title.setProperty('border-top-right-radius', '0.25em');

    ListBox.Width := self.Width;
    ListBox.Height := self.Height - 8;

    ListBox.setProperty('background-color', 'black');
    ListBox.setProperty('border-bottom-left-radius', '0.25em');
    ListBox.setProperty('border-bottom-right-radius', '0.25em');
    ShowTree;
  end;

end;

Procedure JW3Menu.Add(NewNode, ParentNode, NodeDescription: string);
begin
//
  Node := JW3MenuNode.Create;
  Node.Node := NewNode;
  Node.ParentNode := ParentNode;
  Node.NodeDescription := NodeDescription;
  Node.Expanded := false;
  Node.Showing := false;
  If ParentNode = '' then
  begin
    Root := Node;
    Node.Level := 1;
    Node.Expanded := true;    //only when initially displaying all levels 2
    //Node.Showing := True;
  end;
  var Parent := JW3MenuNode.Create;
  Parent := FindNode(ParentNode);
  If assigned(Parent) then
  begin
    var temp := JW3MenuNode.Create;            //  eliminate unwanted double ups
    Temp := FindNode(NewNode);
    If (not assigned(temp)) or (temp.ParentNode <> parent.node) then begin
      Parent.Children.push(Node);
      Node.Level := Parent.Level + 1;
      If node.level = 2 then node.Showing := true;   //see line 82
    end;
  end;

end;

Function JW3Menu.FindNode(ThisNode:string):JW3MenuNode;
begin
  var queue: Array of JW3MenuNode = [Root];
  while (queue.length > 0) do
  begin
    var node := queue[0];
    queue.delete(0);
    if node.Node = ThisNode then
      result := node;
    for var i := 0 to node.Children.length - 1 do
    begin
      queue.push(node.Children[i]);
    end;
  end;
end;

Procedure JW3Menu.HideAllChildren(node: JW3MenuNode);
begin

  Node.Showing := false;
  Node.Expanded := false;

  for var i := 0 to node.Children.length -1 do
  begin
    HideAllChildren(node.Children[i]);
  end;
end;

Procedure JW3Menu.ShowTree;
begin
  ListBox.Clear;
  Order(Root);
end;

Procedure JW3Menu.Order(node: JW3MenuNode);
begin
  if Node.Showing then begin
    var Item := JW3Panel.Create(Self);
    Item.SetAttribute('type','text');
    Item.setProperty('background-color', 'black');
    Item.setProperty('color', 'white');
    Item.SetProperty('font-size', '0.95em');
    Item.Height := 21;

    var prefix : string := '';
    If node.children.count > 0
      then prefix := '&#9656;&nbsp;'               //triangle right
      else prefix := '&nbsp;&#9643;&nbsp;&nbsp;';  //white square

    If node.children.count > 0 then
      If node.Children[0].Showing then
        prefix := '&#9662;&nbsp;';                 //triangle down

    var s: string := '';
    For var i := 1 to node.Level do begin
      S := S + '&nbsp;&nbsp;';
    end;
    S := S + prefix;

    Item.SetinnerHTML(S + node.NodeDescription);
    Item.tag := node.NodeDescription;

    ListBox.Add(Item);
    for var i := 0 to ListBox.handle.children.length -1 do
      ListBox.handle.children[i].style['padding-top'] := '2px';
    ListBox.Height := ListBox.ItemCount * 25 + 2;

    Item.OnClick := procedure(Sender:TObject)
    begin
      Subject := (Sender as TElement).tag;

      node.expanded := not node.expanded;
      For var j := 0 to Node.Children.Count -1 do
        Node.Children[j].Showing := Node.Expanded;
      If Node.Expanded = false then
      begin
        HideAllChildren(Node);
        Node.Showing := true;
      end;
      ShowTree;
      If node.children.count = 0 then
      begin
        DisPatchEvent('MenuClick',item.handle.id,'click',Subject);
      end;
    end;

    Item.handle.ondblclick := procedure
    begin
      window.postMessage([self.handle.id,'dblclick',subject],'*');
    end;

    Item.handle.onmouseenter := lambda(event: variant)
      event.target.style['background-color'] := '#2196f3';
    end;
    Item.handle.onmouseout := lambda(event: variant)
      event.target.style['background-color'] := 'black';
    end;

  end;

  for var i := 0 to node.Children.length -1 do
  begin
    Order(node.Children[i]);
  end;
end;

end.
