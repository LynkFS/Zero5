unit JLabel;

interface

uses
  JElement, JPanel;

type
  JW3Label = class(TElement)
  private
    procedure SetTitle(Title: string);
  public
    constructor Create(parent: TElement); virtual;
    property Text : string write SetTitle;
    TitleBox: JW3Panel;
  end;

implementation

{ JW3Label }

constructor JW3Label.Create(parent: TElement);
begin
  inherited Create('div', parent);

  setProperty('background-color', 'transparent');
  setProperty('color', 'black');
  setProperty('border', 'none');
  setProperty('overflow', 'hidden');

  //title
  TitleBox := JW3Panel.Create(self);
  TitleBox.setProperty('width', '100%');
  TitleBox.setProperty('height','100%');
  TitleBox.setProperty('background-color', 'transparent');
  TitleBox.setProperty('color', 'black');
  TitleBox.setProperty('padding-top', '5px');
  TitleBox.setProperty('border', 'none');
end;

Procedure JW3Label.SetTitle(Title: string);
begin
  TitleBox.SetinnerHTML(Title);
end;

end.


