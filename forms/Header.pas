unit Header;

interface

uses
  JElement, JPanel, JMenu, JDialog, JLoader, JListBox, JButton, JInput,
  JLabel;

type
  JHeader = class(TElement)
  private
    procedure SetTitle(Title: string);
  public
    constructor Create(parent: TElement); virtual;
    TitleBox: JW3Panel;
    Hamburger : JW3Panel;
    Menu1 : JW3Menu;
    property Title : string write SetTitle;
  end;

implementation

uses
  Globals, Types;

{ JHeader }

constructor JHeader.Create(parent: TElement);
begin
  inherited Create('div', parent);

  SetBounds(0, 0, screenwidth, 40);
  setProperty('background-color', '#2c2c2c');
  setProperty('color', 'white');

  //title
  TitleBox := JW3Panel.Create(self);
  TitleBox.setProperty('width', '100%');
  TitleBox.setProperty('height','30px');
  TitleBox.setProperty('background-color', '#2c2c2c');
  TitleBox.setProperty('color', 'white');
  TitleBox.setProperty('padding-top', '10px');

  //create the hamburger icon
  Hamburger := JW3Panel.Create(self);
  Hamburger.SetBounds(0,0,40,40);
  Hamburger.handle.style['background-color'] := '#2c2c2c';

  var HamburgerSVG : JW3Panel := JW3Panel.Create(Hamburger);
  HamburgerSVG.SetBounds(11,11,28,28);
  HamburgerSVG.handle.innerHTML := #'
    <svg width="18" height="18" xmlns="http://www.w3.org/2000/svg">
      <path d="M16 13H2v1h14v-1zm0-5H2v1h14V8zm0-5H2v1h14V3z" fill="#fff">
      </path>
    </svg>';

  Hamburger.OnClick := procedure(sender: TObject)
  begin
    If Hamburger.handle.style['background-color'] = 'rgb(44, 44, 44)' then    //#2c2c2c
    begin
      Hamburger.handle.style['background-color'] := 'rgb(24, 160, 251)';      //#18a0fb
      //
      Menu1 := JW3Menu.Create(self.FParent);
      Menu1.SetBounds(10, 50, 150, 200);
      Menu1.Add('zero','','non visible root');

      case self.FParent.ClassName of
      'TForm4' :
        begin
          Menu1.Add('home', 'zero','home');
          Menu1.Add('pro3', 'zero','save project');
          Menu1.Add('docs', 'zero','documentation');
        end;
      end;
    end else
    begin
      Hamburger.handle.style['background-color'] := 'rgb(44, 44, 44)';        //#2c2c2c
      Menu1.Destroy;
    end;
  end;
  HamburgerSVG.OnClick := Hamburger.OnClick;

  self.FParent.onclick := procedure(sender:TObject)
  begin
    //console.log('dd');
    if assigned(Menu1) then
    begin
      Menu1.Destroy;
      If Hamburger.handle.style['background-color'] = 'rgb(24, 160, 251)'
        then Hamburger.OnClick(self);
    end;
  end;

  document.addEventListener('MenuClick', procedure(e: variant)
  begin

    var msg := JSON.parse(e.detail);

    Hamburger.OnClick(self.FParent);

    case msg.tag of
      'home'           : ;

      //editors
      'domain editor'  : ;
      'process editor' : ;
      'forms editor'   : Application.GoToForm('Form4');

      //docs
      'documentation'  : Application.GoToForm('Form5');

      //save project
      'save project' : ;

      //hide/show panel
      'hide/show panel' :
        begin
          window.postMessage([self.handle.id,'click',''],'*');
        end;

    end; // of all possible msg.tag values

    Menu1.Destroy;
  end); // of addEventListener('MenuClick')

end;

Procedure JHeader.SetTitle(Title: string);
begin
  TitleBox.SetinnerHTML(Title);
end;

end.
