unit form4helper;

interface

uses
  JElement, JPanel, JListBox, JOption, JInput, JLabel, JButton, JDialog, JTextArea;

type
  TZeroLayoutRow = class(JW3Panel)
    constructor CreateRow(parent: JW3Panel);
  end;

  TZeroTitleRow = class(TZeroLayoutRow)
    constructor CreateTitle(parent: JW3Panel; Title: string);
  end;

  TZeroDuoRow = class(TZeroLayoutRow)
    constructor CreateSlider(parent: JW3Panel; x: Variant; Title: string; Px: integer; Perc: float);
  end;

  TZeroScroller = class(JW3Panel)
    constructor CreateScroller(parent: JW3Panel);
    procedure CreateRow(a:string);
  end;

  Procedure TZeroStyleInfoCreation(ParamPanel: JW3Panel; x: variant);

var ace  external 'ace':  variant;
function js_beautify(Text: String): string; external 'js_beautify';
function html_beautify(Text: String): string; external 'html_beautify';
var ComponentBody : string;

var FormOnLoad, FormCode, FormDesign, CurForm: string;

implementation

uses
  Globals;

constructor TZeroScroller.CreateScroller(parent: JW3Panel);
begin
  inherited Create(parent);
  self.handle.style['display'] := 'flex';
  self.handle.style['padding'] := '10px';
  self.handle.style['height']  := '50%';
end;

procedure TZeroScroller.CreateRow(a: string);
begin
  //
end;

constructor TZeroLayoutRow.CreateRow(parent: JW3Panel);
begin
  inherited Create(parent);
  self.handle.style['display'] := 'flex';
  self.handle.style['padding'] := '10px';
end;

constructor TZeroTitleRow.CreateTitle(parent: JW3Panel; Title: String);
begin
  inherited CreateRow(parent);

  handle.style['width']  := '90%';
  handle.style['height'] := '14px';
  handle.innerHTML := Title;
  handle.style['color'] := '#333333';
  handle.style['font-size'] := '12px';
  handle.style['font-weight'] := 'bold';
  handle.style['letter-spacing'] := '1px';
  handle.style['font-family'] := 'Helvetica, Arial, sans-serif';
  handle.style['position'] := 'relative';

end;

constructor TZeroDuoRow.CreateSlider(parent: JW3Panel; x: variant; Title: string; Px: integer; Perc: float);
var
  combobox02 : JW3OptionSelector;
begin
  inherited CreateRow(parent);

  handle.style['padding'] := '5px';
  handle.style['color'] := '#333333';
  handle.style['font-size'] := '12px';
  handle.style['letter-spacing'] := '1px';
  handle.style['font-family'] := 'Helvetica, Arial, sans-serif';
  handle.style['position'] := 'relative';
  handle.style['display'] := 'flex';
  handle.style.removeProperty('height');
  handle.style['width'] := 'calc(100% - 10px)';

  var Text00 := JW3Panel.Create(self);
    Text00.handle.innerHTML := Title;
    Text00.handle.style.width := '18%';
    Text00.handle.style.height := '20px';
    Text00.handle.style['font-size'] := '12px';
    Text00.handle.style['padding'] := '6px';
    Text00.handle.style['padding-left'] := '10px';
    Text00.handle.style['position'] := 'relative';

  var Panel01 : JW3Panel := JW3Panel.Create(self);
    Panel01.handle.style.width := '25%';
    Panel01.handle.style.padding := '3px';
    Panel01.handle.style.left := '3%';
    Panel01.handle.style['background-color'] := '#EEEEEE';
    Panel01.handle.style['position'] := 'relative';
    Panel01.handle.style.height := 'auto';

    //create left panel
    var EditBox01 := JW3Input.Create(Panel01);
      EditBox01.handle.style.width := '60%';
      EditBox01.handle.style.height := '20px';
      EditBox01.handle.style['background-color'] := '#FFFFFF';
      EditBox01.handle.style['font-size'] := '10px';
      EditBox01.handle.style['border'] := '1px inset silver';
      EditBox01.handle.setAttribute('type','number');
      EditBox01.Text := Px.ToString;
      EditBox01.handle.style['text-align'] := 'right';
      EditBox01.handle.style['position'] := 'relative';
      EditBox01.handle.onchange := procedure(e:variant)
      begin
        If Title = 'Left'   then x.style.left   := e.target.value + 'px';
        If Title = 'Top'    then x.style.top    := e.target.value + 'px';
        If Title = 'Width'  then x.style.width  := e.target.value + 'px';
        If Title = 'Height' then x.style.height := e.target.value + 'px';
//
        If Title = 'Left' then
        begin
          x.dataset.percleft :=
            floattostr(StrToInt(e.target.value) * 100 /
            x.parentNode.getBoundingClientRect().width)+'%';
          DisPatchEvent('LayoutChangeEvent',x.id,'click',x.id);
        end;
//
        If Title = 'Top' then
        begin
          x.dataset.perctop :=
            floattostr(StrToInt(e.target.value) * 100 /
            x.parentNode.getBoundingClientRect().height)+'%';
          DisPatchEvent('LayoutChangeEvent',x.id,'click',x.id);
        end;
//
        If Title = 'Width' then
        begin
          x.dataset.percwidth :=
            floattostr(StrToInt(e.target.value) * 100 /
            x.parentNode.getBoundingClientRect().width)+'%';
          DisPatchEvent('LayoutChangeEvent',x.id,'click',x.id);
        end;
//
        If Title = 'Height' then
        begin
          x.dataset.percheight :=
            floattostr(StrToInt(e.target.value) * 100 /
            x.parentNode.getBoundingClientRect().height)+'%';
          DisPatchEvent('LayoutChangeEvent',x.id,'click',x.id);
        end;

      end;

    //create txt panel
    var Text01 := JW3Panel.Create(Panel01);
      Text01.handle.innerHTML := '&nbsp;px';
      Text01.handle.style.width := '30%';
      Text01.handle.style.top := '2px';
      Text01.handle.style['font-size'] := '10px';
      Text01.handle.style['position'] := 'relative';
      Text01.handle.style.height := 'auto';


  var Panel02 : JW3Panel := JW3Panel.Create(self);
    Panel02.handle.style.width := '35%';
    Panel02.handle.style.padding := '3px';
    Panel02.handle.style.left := '6%';
    Panel02.handle.style['background-color'] := '#EEEEEE';
    Panel02.handle.style['position'] := 'relative';
    Panel02.handle.style.height := 'auto';

    //create left panel
    var EditBox02 := JW3Input.Create(Panel02);
      EditBox02.handle.style.width := '50%';
      EditBox02.handle.style.height := '20px';
      EditBox02.handle.style['background-color'] := '#FFFFFF';
      EditBox02.handle.style['font-size'] := '10px';
      EditBox02.handle.style['border'] := '1px inset silver';
      EditBox02.handle.setAttribute('type','number');
      EditBox02.Text := Perc.ToString;
      EditBox02.handle.style['text-align'] := 'right';
      EditBox02.handle.style['position'] := 'relative';
      EditBox02.handle.onchange := procedure(e:variant)
      begin
        If Title = 'Left'  then
          x.dataset.percleft := e.target.value + combobox02.handle.value;
        If Title = 'Top'  then
          x.dataset.perctop := e.target.value + combobox02.handle.value;
        If Title = 'Width'  then
          x.dataset.percwidth := e.target.value + combobox02.handle.value;
        If Title = 'Height'  then
          If x.dataset.name = 'input'
            then x.dataset.percheight := EditBox01.handle.value + 'px'
            else x.dataset.percheight := e.target.value + combobox02.handle.value;

        If (Title = 'Width') and (EditBox02.handle.value = '0') then
        begin
          x.dataset.percwidth := 'initial';
          x.style.width := 'initial';
        end;
        If (Title = 'Height') and (EditBox02.handle.value = '0') then
        begin
          x.dataset.percheight := 'initial';
          x.style.height := 'initial';
        end;

      end;

    combobox02 := JW3OptionSelector.Create(Panel02);
    combobox02.handle.style.width := '40%';
    combobox02.handle.style.height := '23px';
    combobox02.handle.style['font-size'] := '10px';
    combobox02.handle.style['position'] := 'relative';
    combobox02.AddOption('%','%');
    combobox02.AddOption('px','px');
    combobox02.AddOption('vh','vh');
    combobox02.AddOption('vw','vw');
    combobox02.AddOption('auto','auto');

    combobox02.handle.onchange := procedure(e:variant)
    begin
      If Title = 'Left'  then
        x.dataset.percleft := EditBox02.handle.value + e.target.value;
      If Title = 'Top'  then
        x.dataset.perctop := EditBox02.handle.value + e.target.value;
//    If Title = 'Width'  then
//      x.dataset.percwidth := EditBox02.handle.value + e.target.value;
      If Title = 'Width'  then
      begin
        x.dataset.percwidth := EditBox02.handle.value + e.target.value;
        If e.target.value = 'auto' then
          x.dataset.percwidth := 'auto';
      end;
      If Title = 'Height'  then
      begin
        x.dataset.percheight := EditBox02.handle.value + e.target.value;
        If e.target.value = 'auto' then
          x.dataset.percheight := 'auto';
      end;
    end;
end;
//

Procedure TZeroStyleInfoCreation(ParamPanel: JW3Panel; x: variant);
begin

  var ButtonPanel := JW3Panel.Create(ParamPanel);
  ButtonPanel.SetBounds(10, 280, 250, 50);
  ButtonPanel.handle.style['border']  := 'none';  //'1px dotted black';

  //style-attribute properties
  var Button1 := JW3Button.Create(ButtonPanel);
  Button1.Caption := 'Style';
  Button1.SetBounds(10, 10, 70, 30);
  Button1.handle.style['font-size']   := '12px';
  Button1.handle.style['letter-spacing'] := '1px';
  Button1.handle.style['font-family'] := 'Helvetica, Arial, sans-serif';

  //all css properties
  var Button2 := JW3Button.Create(ButtonPanel);
  Button2.Caption := 'All css';
  Button2.SetBounds(90, 10, 70, 30);
  Button2.handle.style['font-size']   := '12px';
  Button2.handle.style['letter-spacing'] := '1px';
  Button2.handle.style['font-family'] := 'Helvetica, Arial, sans-serif';

  //all atttributes
  var Button3 := JW3Button.Create(ButtonPanel);
  Button3.Caption := 'Attributes';
  Button3.SetBounds(170, 10, 70, 30);
  Button3.handle.style['font-size']   := '12px';
  Button3.handle.style['letter-spacing'] := '1px';
  Button3.handle.style['font-family'] := 'Helvetica, Arial, sans-serif';
  Button3.handle.dataset.id := x.id;

  var Scroller : JW3Panel := JW3Panel.Create(ParamPanel);
  Scroller.SetBounds(10, 340, 240, 100);
  Scroller.handle.style['height']  := 'calc(100% - 350px)';
  Scroller.handle.style['width']   := 'calc(100% - 12px)';
  //Scroller.handle.style['border']  := '1px dotted red';  //'none';

  Button1.handle.onclick := procedure(e: variant)
  begin
    //Scroller.Clear;
    While Scroller.handle.firstChild <> nil do
      Scroller.handle.removeChild(Scroller.handle.firstChild);

    var cssarray : Array of string;
    cssarray.Clear;
    cssarray := StrSplit(x.style.cssText, ';');
    for var j := 0 to cssarray.length -2 do
    begin
      var StyleRow1 := JW3Panel.Create(Scroller);
      StyleRow1.SetBounds(0,j*50,250,25);
      StyleRow1.handle.style['width']  := '100%';
      StyleRow1.handle.style['cursor'] := 'pointer';
      StyleRow1.Text := trim(StrBefore(cssarray[j],':')) + ' : ';  // + styles.getPropertyValue(styles[i]);
      StyleRow1.handle.style['font-size'] := '0.85em';
      StyleRow1.handle.dataset.propindex := inttostr(j);

      StyleRow1.handle.onclick := procedure(e: variant)
      begin
        //console.log(e.target.dataset.propindex);
        var x : variant := new JObject;
        var y := trim(StrBefore(cssarray[strtoint(e.target.dataset.propindex)],':'));
        var z := 'https://developer.mozilla.org/en-US/docs/Web/CSS/' + y;
        asm
          @x = window.open(@z,'_blank','menubar=yes,location=yes,resizable=yes,scrollbars=yes,status=yes');
        end;
      end; // of onclick

      var StyleEdit1 := JW3Input.Create(Scroller);
      StyleEdit1.SetBounds(0,(j*50)+18,250,20);
      StyleEdit1.handle.style['width']  := 'calc(100% - 4px)';
      StyleEdit1.handle.style['background-color'] := 'whitesmoke';
      StyleEdit1.handle.style['margin-bottom'] := '10px';
      StyleEdit1.Text := trim(StrAfter(cssarray[j],':'));
      StyleEdit1.handle.style['border'] := 'none'; //'1px inset silver';
      StyleEdit1.handle.style['text-align'] := 'left';
      StyleEdit1.handle.style['font-size'] := '0.8em';
      StyleEdit1.handle.dataset.propindex := inttostr(j);
      StyleEdit1.handle.onchange := procedure(e:variant)
      begin
        //console.log('changed ' + e.target.value);
        var y := strtoint(e.target.dataset.propindex);
        x.style[trim(StrBefore(cssarray[y],':'))] := e.target.value;
        //DisPatchEvent('LayoutChangeEvent',x.id,'click',x.id);
      end;
    end;  // of main styles
  end;  // of button1 onclick

  Button2.handle.onclick := procedure(e: variant)
  begin
    //Scroller.Clear;
    While Scroller.handle.firstChild <> nil do
      Scroller.handle.removeChild(Scroller.handle.firstChild);

    var styles := window.getComputedStyle(x);
    for var i := 0 to styles.length-1 do
    begin
      if StrBeginsWith(styles[i],'-webkit-') = false then
      begin
        var StyleRow2 := JW3Panel.Create(Scroller);
        StyleRow2.SetBounds(0,i*50,250,25);
        StyleRow2.handle.style['width']  := '100%';
        //StyleRow2.handle.style['text-overflow']  := 'ellipsis';
        //StyleRow2.handle.style['overflow-x']  := 'hidden';
        StyleRow2.handle.style['cursor'] := 'pointer';
        StyleRow2.Text := styles[i] + ' : ';  // + styles.getPropertyValue(styles[i]);
        StyleRow2.handle.style['font-size'] := '0.85em';
        StyleRow2.handle.dataset.propindex := inttostr(i);

        StyleRow2.handle.onclick := procedure(e: variant)
        begin
          var x : variant := new JObject;
          var y := styles[strtoint(e.target.dataset.propindex)];
          var z := 'https://developer.mozilla.org/en-US/docs/Web/CSS/' + y;
          asm
            @x = window.open(@z,'_blank','menubar=yes,location=yes,resizable=yes,scrollbars=yes,status=yes');
          end;
        end; // of onclick

        var StyleEdit2 := JW3Input.Create(Scroller);
        StyleEdit2.SetBounds(0,(i*50)+18,250,20);
        StyleEdit2.handle.style['width']  := '100%';
        StyleEdit2.handle.style['background-color'] := 'whitesmoke';
        StyleEdit2.handle.style['margin-bottom'] := '10px';
        StyleEdit2.Text := styles.getPropertyValue(styles[i]);
        StyleEdit2.handle.style['border'] := 'none'; //'1px inset silver';
        StyleEdit2.handle.style['text-align'] := 'left';
        StyleEdit2.handle.style['font-size'] := '0.8em';
        StyleEdit2.handle.dataset.propindex := inttostr(i);
        StyleEdit2.handle.onchange := procedure(e:variant)
        begin
          //console.log('changed ' + e.target.value);
          var y := strtoint(e.target.dataset.propindex);
          x.style[styles[y]] := e.target.value;
          //DisPatchEvent('LayoutChangeEvent',x.id,'click',x.id);
        end;
      end;  // of not -webkit-
    end;  // of detail styles
  end;  // of button2 onclick

  Button3.handle.onclick := procedure(e: variant)
  begin
    //Scroller.Clear;
    While Scroller.handle.firstChild <> nil do
      Scroller.handle.removeChild(Scroller.handle.firstChild);

    if x.hasAttributes()then
    begin
//      if x.hasAttribute('onclick') = true then
//        x.setAttribute('data-click', x.getAttribute('onclick'));
//      if x.hasAttribute('onclick') = true then
//        x.removeAttribute('onclick');
      var attributes : variant := x.attributes;
      //for canvas (PrevBody) create onload attr
      if x.getAttribute('data-name') = 'PrevBody' then
      begin
        var attribute := document.createAttribute('onload');
        attribute.value := FormOnLoad;
        attributes.setNamedItem(attribute);
      end;

      //for containers create resizeable attr
      if x.getAttribute('data-name') = 'container' then
      begin
        var attribute := document.createAttribute('resizeable');
        attribute.value := 'false';
        attributes.setNamedItem(attribute);
      end;
      //for buttons get hover rule
      if x.getAttribute('data-name') = 'button' then
      begin
        var attribute := document.createAttribute('hover');
        for var i := 0 to styleSheet.cssRules.length -1 do
        begin
          //writeln(styleSheet.cssRules[i].selectorText);
          if styleSheet.cssRules[i].selectorText = '#' + x.id + ':hover' then
          begin
            //console.log(styleSheet.cssRules[i].selectorText);
            //console.log(styleSheet.cssRules[i]);
            attribute.value := x.getAttribute('hover');
            if attribute.value = 'null' then
            begin
              attribute.value := styleSheet.cssRules[i].cssText;
              x.setAttribute('hover',attribute.value);
            end;
            attributes.setNamedItem(attribute);
          end;
        end;
      end;
      //
      var k := -1;
      for var j := 0 to attributes.length -1 do
      begin
        //console.log(attributes[j].name);
        //console.log(attributes[j].value);
        if LeftStr(attributes[j].name, 5) <> 'data-' then
        begin
          k := k + 1;
          var StyleRow3 := JW3Panel.Create(Scroller);
          StyleRow3.SetBounds(0,k*50,250,25);
          StyleRow3.handle.style['width']  := '100%';
          StyleRow3.handle.style['cursor'] := 'pointer';
          StyleRow3.Text := attributes[j].name;
          StyleRow3.handle.style['font-size'] := '0.85em';
          StyleRow3.handle.dataset.propindex := inttostr(j);

          StyleRow3.handle.onclick := procedure(e: variant)
          begin
            //console.log(e.target.dataset.propindex);
            var x : variant := new JObject;
            var y := attributes[strtoint(e.target.dataset.propindex)].name;
            if LeftStr(y, 5) <> 'data-' then
            begin
              var z := '';
              if y = 'src' then
                z := 'https://developer.mozilla.org/en-US/docs/Web/API/HTMLIFrameElement/' + y;
              if y = 'addevent' then
                z := 'https://developer.mozilla.org/en-US/docs/Web/API/GlobalEventHandlers/';
              //if LeftStr(y, 3) = 'non' then
              if LeftStr(y, 2) = 'on' then
              begin
//code editor
                //ACE editor parent panel
                var Dialog1 : JW3Panel := JW3Panel.Create(paramPanel.FParent);
                Dialog1.SetBounds(round(window.screen.width/2-200),
                                  round(window.screen.height/2-300),400,350);
                Dialog1.handle.style['color'] := 'black';
                Dialog1.handle.style['padding'] := '5px';
                Dialog1.handle.style.border := '1px solid silver';
                Dialog1.handle.style['background-color'] := 'whitesmoke';
                //
                //ACE editor panel
                var IdeFix : JW3Dialog := JW3Dialog.Create(Dialog1);
                IdeFix.SetBounds(10,10,380,280);
                IdeFix.handle.id := 'IdeFix';
                IdeFix.handle.setAttribute('contenteditable','true');
                IdeFix.handle.style.color := 'black';

                IdeFix.handle := ace.edit("IdeFix");
                IdeFix.handle.setTheme("ace/theme/textmate");
                IdeFix.handle.session.setMode("ace/mode/javascript");

                //if onclick then below, else take it from input value
                if y = 'onclick'
                  then IdeFix.handle.setValue(document.getElementById(Button3.handle.dataset.id).dataset.click+#10)
                  else IdeFix.handle.setValue(document.getElementById(e.target.id).nextElementSibling.value+#10);
                IdeFix.handle.setValue(SubString(IdeFix.handle.getValue(),1,IdeFix.handle.getValue().length+1));

                //beautify
                IdeFix.handle.setValue(js_beautify(IdeFix.handle.getValue()));

                //
                var ButtonExit : JW3Button := JW3Button.Create(Dialog1);
                ButtonExit.SetBounds(150,310,100,35);
                ButtonExit.Caption := 'Save';
                ButtonExit.handle.dataset.id := e.target.id;
                ButtonExit.OnClick := procedure(sender:TObject)
                begin

                  document.getElementById(ButtonExit.handle.dataset.id).nextElementSibling.value :=
                    IdeFix.handle.getValue();
                  if document.getElementById(ButtonExit.handle.dataset.id).innerHTML = 'onclick' then
                    document.getElementById(Button3.handle.dataset.id).dataset.click :=
                      IdeFix.handle.getValue();

                  var event : variant; asm @event = new Event('change'); end;
                  document.getElementById(ButtonExit.handle.dataset.id).nextElementSibling.dispatchEvent(event);
                  Dialog1.Destroy;
                end;
              end //code editor
//end editor
              else if z = '' then z := 'https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/' + y;
              //
              if z <> '' then
                asm
                  @x = window.open(@z,'_blank','menubar=yes,location=yes,resizable=yes,scrollbars=yes,status=yes');
                end;
            end;
          end; // of onclick

          var StyleEdit3 := JW3Input.Create(Scroller);
          StyleEdit3.SetBounds(0,(k*50)+18,250,20);
          StyleEdit3.handle.style['width']  := 'calc(100% - 4px)';
          StyleEdit3.handle.style['background-color'] := 'whitesmoke';
          StyleEdit3.handle.style['margin-bottom'] := '10px';
          if attributes[j].name = 'onclick'
            then StyleEdit3.Text := x.getAttribute('data-click')
            else StyleEdit3.Text := attributes[j].value;
          StyleEdit3.handle.style['border'] := 'none'; //'1px inset silver';
          StyleEdit3.handle.style['text-align'] := 'left';
          StyleEdit3.handle.style['font-size'] := '0.8em';
          StyleEdit3.handle.dataset.propindex := inttostr(j);
          StyleEdit3.handle.onchange := procedure(e:variant)
          begin
            //console.log('changed ' + e.target.value);
            //console.log(e);
            var y := strtoint(e.target.dataset.propindex);

            if x.name = 'JInput' then
              if attributes[strtoint(e.target.dataset.propindex)].name = 'label' then
                x.parentNode.children[0].innerHTML := e.target.value;

            if x.name = 'JButton' then
              if attributes[strtoint(e.target.dataset.propindex)].name = 'hover' then
                stylesheet.insertRule(e.target.value);

            if attributes[strtoint(e.target.dataset.propindex)].name = 'addevent' then
            begin
//              if LeftStr(e.target.value,2) = 'on' then
//                x.setAttribute('n' + e.target.value,'');
              if x.hasAttribute(e.target.value) = false then
              begin
                if e.target.value = 'onclick'
                then begin
                  var z : variant := x.onclick;
                  x.setAttribute(e.target.value,"");
                  x.onclick := z;
                end else
                  x.setAttribute(e.target.value,"");
                Button3.handle.click();
              end;
            end;

            if x.getAttribute('data-name') = 'PrevBody' then
              FormOnLoad := e.target.value;

            if attributes[strtoint(e.target.dataset.propindex)].name = 'onclick'
              then x.setAttribute('data-click',e.target.value)
              else x.setAttribute(attributes[y].name,e.target.value);

          end;
        end;
      end;  // of attributes
    end;  // of has attributes
  end;  // of button3 onclick
end;

end.
