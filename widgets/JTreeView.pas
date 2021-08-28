unit JTreeView;

interface

uses
  JElement, JListBox, JPanel;

type
  JW3TreeNode = class
  public
    Node, ParentNode, NodeDescription : String;
    Level : Integer;
    Children : Array of JW3TreeNode;
    Expanded: Boolean;
    Showing: Boolean;
  end;

  JW3TreeView = class(TElement)
  private
    ListBox: JW3ListBox;
    Title : JW3Panel;
    Function  FindNode(ThisNode: string):JW3TreeNode;
    Procedure HideAllChildren(node: JW3TreeNode);
    Procedure Order(node: JW3TreeNode);
    Node : JW3TreeNode;
    Root : JW3TreeNode;
  public
    constructor Create(parent: TElement); virtual;
    Procedure Add(NewNode, ParentNode, NodeDescription: String);
    Procedure ShowTree;
    Subject: String := 'TreeView...';
  end;


implementation

uses Globals;

{ JW3TreeView }

constructor JW3TreeView.Create(parent: TElement);
begin
  inherited Create('div', parent);
  setProperty('background-color', 'white');

  Title := JW3Panel.Create(self);
  Title.SetProperty('background-color','#699BCE');
  Title.SetProperty('color','white');
  Title.SetProperty('border','1px solid white');

  ListBox := JW3ListBox.Create(self);
  ListBox.Top := 25;
  ListBox.handle.style.cursor := 'pointer';

  //self.Observe;
  self.OnReadyExecute := procedure(sender: TObject)
  begin
    Title.SetBounds(0,0,width-2,22);
    Title.handle.value := Subject;
    Title.SetProperty('font-size', '0.95em');
    Title.Text := Subject;
    ListBox.Width := self.Width;
    ListBox.Height := self.Height - 25;

    ShowTree;
  end;

end;

Procedure JW3TreeView.Add(NewNode, ParentNode, NodeDescription: string);
begin
//
  Node := JW3TreeNode.Create;
  Node.Node := NewNode;
  Node.ParentNode := ParentNode;
  Node.NodeDescription := NodeDescription;
  Node.Expanded := false;
  Node.Showing := false;
  If ParentNode = '' then
  begin
    Root := Node;
    Node.Level := 1;
    //Node.Expanded := true;    //only when initially displaying all levels 2
    Node.Showing := True;
  end;
  var Parent := JW3TreeNode.Create;
  Parent := FindNode(ParentNode);
  If assigned(Parent) then
  begin
    var temp := JW3TreeNode.Create;            //  eliminate unwanted double ups
    Temp := FindNode(NewNode);
    If (not assigned(temp)) or (temp.ParentNode <> parent.node) then begin
      Parent.Children.push(Node);
      Node.Level := Parent.Level + 1;
      //If node.level = 2 then node.Showing := true;   //see line 82
    end;
  end;

end;

Function JW3TreeView.FindNode(ThisNode:string):JW3TreeNode;
begin
  var queue: Array of JW3TreeNode = [Root];
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

Procedure JW3TreeView.HideAllChildren(node: JW3TreeNode);
begin

  Node.Showing := false;
  Node.Expanded := false;

  for var i := 0 to node.Children.length -1 do
  begin
    HideAllChildren(node.Children[i]);
  end;
end;

Procedure JW3TreeView.ShowTree;
begin
  ListBox.Clear;
  Order(Root);
end;

Procedure JW3TreeView.Order(node: JW3TreeNode);
begin
  if Node.Showing then begin
    var Item := JW3Panel.Create(Self);
    Item.SetAttribute('type','text');
    Item.setProperty('background-color', 'whitesmoke');
    Item.SetProperty('font-size', '0.85em');
    Item.Height := 21;

    var prefix : string := '';
    If node.children.count > 0
      then prefix := '&#9656;&nbsp;'               //triangle right
      else prefix := '&nbsp;&nbsp;&#9643;&nbsp;';  //white square
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

    Item.OnClick := procedure(Sender:TObject)
    begin
      Subject := (Sender as TElement).tag;
      Title.Text := Subject;

      node.expanded := not node.expanded;
      For var j := 0 to Node.Children.Count -1 do
        Node.Children[j].Showing := Node.Expanded;
      If Node.Expanded = false then
      begin
        HideAllChildren(Node);
        Node.Showing := true;
      end;
      ShowTree;
      window.postMessage([self.handle.id,'click',node.node],'*');
    end;

    Item.handle.ondblclick := procedure
    begin
      window.postMessage([self.handle.id,'dblclick',subject],'*');  //= title.handle.value
    end;

  end;

  for var i := 0 to node.Children.length -1 do
  begin
    Order(node.Children[i]);
  end;
end;

end.
