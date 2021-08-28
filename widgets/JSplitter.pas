unit JSplitter;

interface

uses
  JElement, JPanel;

type
  JW3Splitter = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
    PanelLeft, PanelRight, ReSizer: JW3Panel;
  end;

implementation

uses Globals;

{ JW3Splitter }

constructor JW3Splitter.Create(parent: TElement);
begin
  inherited Create('div', parent);

  PanelLeft := JW3Panel.Create(self);
  PanelRight := JW3Panel.Create(self);

  ReSizer := JW3Panel.Create(PanelRight);
  ReSizer.SetProperty('background-color','#ccc');
  ReSizer.SetProperty('cursor','w-resize');
  ReSizer.width := 4;

  //self.Observe;
  self.OnReadyExecute := procedure(sender: TObject)
  begin

    PanelLeft.SetProperty('height','100%');
    PanelLeft.SetProperty('width','100%');

    PanelRight.SetProperty('height','100%');
    PanelRight.Width := trunc(self.width/2);
    PanelRight.Left  := trunc(self.width/2);

    ReSizer.SetProperty('height','100%');

//
// event handling splitter movement
//
    //mapping touchstart to mousedown, touchend to mouseup and touchmove to mousemove
    //see touch2Mouse in JElement.
    ReSizer.handle.ontouchstart := lambda(e: variant) touch2Mouse(e); end;
    ReSizer.handle.ontouchmove  := ReSizer.handle.ontouchstart;
    ReSizer.handle.ontouchend   := ReSizer.handle.ontouchstart;

    ReSizer.handle.onmousedown := procedure(e: variant)
    begin
      var saveX := e.clientX;
      self.handle.onmousemove := procedure(e: variant)
      begin
        PanelRight.left := PanelRight.Left - (saveX - e.clientX);
        saveX := e.clientX;
        PanelRight.width := self.Width - PanelRight.Left;
        PanelLeft.SetProperty ('cursor','w-resize');
        PanelRight.SetProperty('cursor','w-resize');
      end;
    end;
    self.handle.onmouseup := procedure
    begin
      PanelLeft.SetProperty ('cursor','default');
      PanelRight.SetProperty('cursor','default');
      self.handle.onmousemove := procedure begin end;   //nullify mousemove
    end;
  end;
end;

end.

