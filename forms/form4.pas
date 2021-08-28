unit Form4;

interface

uses JElement, JForm, JPanel, JButton, JLabel, JListBox, JInput, JOption,
  JDialog, Header;

type
  TForm4 = class(TW3Form)
  protected
    procedure InitializeForm; override;
    procedure InitializeObject; override;
    procedure Resize; override;
    NavPanel, ParamPanel, Preview, PrevBody, CompoPanel, PrevPreview: JW3Panel;
    Procedure CreateNavPanel;
    Procedure CreatePrevPanel;
    Procedure CreateCompoPanel;
    //procedure PreviewHamburgerIcon;
    procedure PreviewCloseIcon;
    procedure PreviewPreviewIcon;
    IconHover: JW3Panel;
    FResizeObserver: variant;
    x: variant;  //preview window object
    script: variant; //header sceript
  end;


implementation

uses Globals, Types, form4helper;

{ TForm4 }

procedure TForm4.InitializeForm;
begin
  inherited;
  // this is a good place to initialize components
end;

procedure TForm4.InitializeObject;
begin
  inherited;

  var Header := JHeader.Create(self);
  Header.Title := '<center>Forms Editor (' + CurForm + ')';

  //create navigation panel
  NavPanel := JW3Panel.Create(self);
  NavPanel.handle.dataset.name := 'NavPanel';
  NavPanel.handle.style.width := '100%';
  NavPanel.handle.style.top := '40px';         //beneath header
  NavPanel.handle.style.height := '60px';
  NavPanel.handle.style['background-color'] := '#FFFFFF';
  NavPanel.handle.style['border-bottom'] := '1px solid #EEEEEE';

  //create (re)main(der)
  var MainPanel := JW3Panel.Create(self);
  MainPanel.handle.dataset.name := 'MainPanel';
  MainPanel.handle.style.top := '100px';       //beneath header and navpanel
  MainPanel.handle.style.width := '100%';
  MainPanel.handle.style.height := 'calc(100% - 100px)';
  MainPanel.handle.style['background-color'] := '#EEEEEE';

  //create left panel
  CompoPanel := JW3Panel.Create(MainPanel);
  CompoPanel.handle.dataset.name := 'CompoPanel';
  CompoPanel.handle.style.width := '260px';
  CompoPanel.handle.style.height := '100%';
  CompoPanel.handle.style['background-color'] := '#FFFFFF';

  //create right panel
  ParamPanel := JW3Panel.Create(MainPanel);
  ParamPanel.handle.dataset.name := 'ParamPanel';
  ParamPanel.handle.style.left := 'calc(100% - 260px)';
  ParamPanel.handle.style.width := '260px';
  ParamPanel.handle.style.height := 'calc(100% - 4px)';
  ParamPanel.handle.style['background-color'] := '#FFFFFF';
  ParamPanel.handle.style.position := 'relative';

  //create preview panel
  //see https://www.websitedimensions.com/
  //and http://screensiz.es/monitor
  Preview := JW3Panel.Create(MainPanel);
  Preview.handle.dataset.name := 'PreviewPanel';
  //desktop : 1366 * 768
  var x := window.innerWidth - 520 - 100;
  var y := round(x * 0.65);
  Preview.width := x;
  Preview.handle.style.left := '310px';     //260+50
  Preview.handle.style.width := inttostr(x) + 'px';
  Preview.handle.style.height:= inttostr(y) + 'px';
  Preview.handle.style.top := '10%';
  Preview.handle.style['margin-left'] := 'auto';
  Preview.handle.style['margin-right'] := 'auto';
  Preview.handle.style['background-color'] := '#FFFFFF';
  Preview.handle.style['border-radius'] := '5px';
  Preview.handle.style['box-shadow'] :=
    '0 10px 20px rgba(0,0,0,0.19),0 6px 6px rgba(0,0,0,0.23)';
  Preview.handle.dataset.canvas := 'desktop';

  //create PrevBody panel
  PrevBody := JW3Panel.Create(Preview);
  PrevBody.handle.id := 'PrevBody';
  PrevBody.handle.dataset.name := 'PrevBody';
  PrevBody.handle.style.width := inttostr(x-50) + 'px';
  PrevBody.handle.style.height := inttostr(y-80) + 'px';
  PrevBody.handle.style.top := '40px';
  PrevBody.handle.style['margin-left'] := 'auto';
  PrevBody.handle.style['margin-right'] := 'auto';
  PrevBody.handle.style['border'] := '1px dotted blue';
  PrevBody.handle.style['display'] := 'block';
  PrevBody.handle.style['position'] := 'relative';

  CreateNavPanel;
  CreateCompoPanel;
  CreatePrevPanel;
  //PreviewHamburgerIcon;
  PreviewCloseIcon;
  PreviewPreviewIcon;

  PrevBody.handle.style['padding'] := '10px';
  PrevBody.handle.style['color'] := '#333333';
  PrevBody.handle.style['font-size'] := '12px';
  PrevBody.handle.style['letter-spacing'] := '1px';
  PrevBody.handle.style['font-family'] := 'Helvetica, Arial, sans-serif';
  PrevBody.handle.innerHTML := #'
    The form editor<br>
    <ul>
    <li>Drag components from top onto this canvas</li>
    <li>Reposition : drag the component around</li>
    <li>Resize : drag the bottom-right corner</li>
    </ul><br>
    Use preview icon for preview';
  PrevBody.handle.dataset.initclear := 'y';

  PrevBody.handle.style['overflow-x'] := 'hidden';

  //rightclick menu to delete elements
  document.addEventListener("contextmenu", procedure(e: variant)
  begin
    //console.log(e);
    //console.log(e.target.id);
    e.preventDefault();
    var answer := window.prompt('Delete this element ?','N');
    If lowercase(answer) in ['y','yes'] then
    begin
      e.target.remove();
    end;
  end);

  //create content of ParamPanel (uses form4helper)
  document.addEventListener('LayoutChangeEvent', procedure(e: variant)
  begin
    //console.log('received LayoutChangeEvent');
    //console.log(e.detail);
    var msg := JSON.parse(e.detail);
    var x : variant := new JObject;
    asm @x = document.getElementById((@msg).id); end;
    //console.log(msg.id + ' ' + msg.tag);
    if msg.id = msg.tag then
    begin

      //ParamPanel.Clear;
      While ParamPanel.handle.firstChild <> nil do
        ParamPanel.handle.removeChild(ParamPanel.handle.firstChild);

      //dimensions
      TZeroTitleRow.CreateTitle(ParamPanel,msg.id + ' (' + x.name + ')');

      // first title ('Layout');
      var Title01 : TZeroTitleRow  := TZeroTitleRow.CreateTitle(ParamPanel,'Layout');

      TZeroDuoRow.CreateSlider(ParamPanel,x,'Left',
        StrToInt(strBefore(x.style.left,'px')),
        round(StrToFloat(strBefore(x.dataset.percleft,'%'))*100)/100);
      TZeroDuoRow.CreateSlider(ParamPanel,x,'Top',
        StrToInt(strBefore(x.style.top,'px')),
        round(StrToFloat(strBefore(x.dataset.perctop,'%'))*100)/100);
      TZeroDuoRow.CreateSlider(ParamPanel,x,'Width',
        StrToInt(strBefore(x.style.width,'px')),
        round(StrToFloat(strBefore(x.dataset.percwidth,'%'))*100)/100);
      TZeroDuoRow.CreateSlider(ParamPanel,x,'Height',
        StrToInt(strBefore(x.style.height,'px')),
        round(StrToFloat(strBefore(x.dataset.percheight,'%'))*100)/100);

        // second title ('Styling');
        var Title02 : TZeroTitleRow  := TZeroTitleRow.CreateTitle(ParamPanel,'Styling');
        Title02.handle.style['margin-top']  := '15px';

        //buttons and scroller for various styling parameters
        //includes link-through to mozilla pages
        TZeroStyleInfoCreation(ParamPanel,x);

    end;
  end);

  //load ace
  var Script := document.createElement('script');
  Script.src := 'res/src-min-noconflict/ace.js';
  document.head.appendChild(Script);
  Script.onload := procedure
  begin
    console.log('ace loaded');
  end;
  //load beautify
  var Script2 := document.createElement('script');
  Script2.src := 'res/src-min-noconflict/beautify.js';
  document.head.appendChild(Script2);
  Script2.onload := procedure
  begin
    console.log('beautify loaded');
  end;
  //load beautify-html
  var Script3 := document.createElement('script');
  Script3.src := 'res/src-min-noconflict/beautify-html.js';
  document.head.appendChild(Script3);
  Script3.onload := procedure
  begin
    console.log('beautify-html loaded');
  end;

end;

procedure TForm4.CreateNavPanel;
begin
  For var i := 0 to 6 do begin

  //Display draggable components on Navpanel
    var img1 := JW3Panel.Create(NavPanel);
      case i of
        0: begin img1.setinnerHtml('buttons');    img1.handle.dataset.name := 'button'; end;
        1: begin img1.setinnerHtml('images');     img1.handle.dataset.name := 'image'; end;
        2: begin img1.setinnerHtml('containers'); img1.handle.dataset.name := 'container'; end;
        3: begin img1.setinnerHtml('external');   img1.handle.dataset.name := 'iframe'; end;
        4: begin img1.setinnerHtml('input');      img1.handle.dataset.name := 'input'; end;
        5: begin img1.setinnerHtml('text');       img1.handle.dataset.name := 'editor'; end;
        //6: begin img1.setinnerHtml('components'); img1.handle.dataset.name := 'component'; end;
        6:
        begin
          img1.setinnerHtml('components');
          img1.handle.dataset.name := 'component';

          img1.OnClick := procedure(sender: TObject)
          begin
            //load components
            var Dialog1 : JW3Panel := JW3Panel.Create(paramPanel.FParent);
            Dialog1.SetBounds(round(window.screen.width/2-200),
                              round(window.screen.height/2-300),400,350);
            Dialog1.handle.style['color'] := 'black';
            Dialog1.handle.style['padding'] := '5px';
            Dialog1.handle.style.border := '1px solid silver';
            Dialog1.handle.style['background-color'] := 'whitesmoke';
            //
            var IdeFix : JW3Dialog;
            //
            var FileInput1 := JW3Input.Create(Dialog1);
            FileInput1.SetBounds(50,310,200,35);
            FileInput1.SetAttribute('type','file');
            FileInput1.SetAttribute('name','FileInput');
            FileInput1.handle.onchange := procedure(e:variant)
            begin
              var fr : variant;
              asm @fr=new FileReader(); end;
              fr.onload := procedure()
              begin
                //ACE editor panel
                IdeFix := JW3Dialog.Create(Dialog1);
                IdeFix.SetBounds(10,10,380,280);
                IdeFix.handle.id := 'IdeFix';
                IdeFix.handle.setAttribute('contenteditable','true');
                IdeFix.handle.style.color := 'black';

                IdeFix.handle := ace.edit("IdeFix");
                IdeFix.handle.setTheme("ace/theme/textmate");
                IdeFix.handle.session.setMode("ace/mode/html");
                IdeFix.handle.setValue(fr.result);

                //beautify and save
                IdeFix.handle.setValue(html_beautify(IdeFix.handle.getValue()));
                ComponentBody := IdeFix.handle.getValue();
                img1.setInnerHtml(StrBefore(FileInput1.handle.files[0].name,'.')); //(ComponentBody);
              end;
              fr.readAsText(FileInput1.handle.files[0]);
            end; // file select

            var ButtonExit : JW3Button := JW3Button.Create(Dialog1);
            ButtonExit.SetBounds(275,310,100,20);
            ButtonExit.Caption := 'Exit';
            ButtonExit.handle.style.backgroundColor := 'silver';
            ButtonExit.OnClick := procedure(sender:TObject)
            begin
              ComponentBody := IdeFix.handle.getValue();
              Dialog1.Destroy;
            end;

          end; // of img1 onclick

        end; // of 6 : components
      end; // of case

      img1.setBounds(330 + (i*10),10,82,20);          //350
      img1.handle.style.cursor := 'pointer';
      img1.handle.style.border := '1px solid silver';
      img1.handle.style.color := 'white';
      img1.handle.style.textAlign := 'center';
      img1.handle.style['font-size'] := '16px';
      img1.handle.style['border-radius'] := '3px';
      img1.handle.style.padding := '8px';
      img1.handle.style.backgroundColor := '#699BCE';
      img1.handle.style.position := 'relative';

      img1.handle.style['lineHeight'] := 'inherit';
      img1.handle.style['align-items'] := 'center';
      img1.handle.style['justify-content'] := 'center';
      img1.handle.style['overflow'] := 'hidden';

      //make components draggable
      img1.setAttribute('draggable','true');

      //preload drag images
      var ImageButton : variant;
      asm @ImageButton = new Image(); end;
      ImageButton.setAttribute('src','images/dragButton.png');
    //
      img1.handle.ondragstart := procedure(ev: variant)
      begin

        If PrevBody.handle.dataset.initclear = 'y' then
        begin
          PrevBody.handle.style.padding := '0px';
          PrevBody.handle.innerHTML := '';
          PrevBody.handle.dataset.initclear := 'n';
        end;

        //make Canvas droppable
        PrevBody.handle.ondragover := procedure(ev: variant)
        begin
          ev.preventDefault();
        end;
        //
        ev.dataTransfer.setData("text", ev.target.id + ';' +
                               inttostr(0) + ';' +
                               inttostr(0));
        ev.dataTransfer.effectAllowed := "copy";
        ev.dataTransfer.dropEffect    := "copy";
        //set appropriate drag image
//        case ev.target.dataset.name of
//          'button'   : ev.dataTransfer.setDragImage(ImageButton, 0, 0);
//          'image'    : ev.dataTransfer.setDragImage(ImageButton, 0, 0);
//          'container': ev.dataTransfer.setDragImage(ImageButton, 0, 0);
//          'iframe'   : ev.dataTransfer.setDragImage(ImageButton, 0, 0);
//          'input'    : ev.dataTransfer.setDragImage(ImageButton, 0, 0);
//        end;
        ev.dataTransfer.setDragImage(ImageButton, 0, 0);
      end;
  end;
end;

procedure TForm4.CreatePrevPanel;
begin

    //inline proc for ResizeObserver
    procedure x(entries: variant);
    begin
      entries[entries.length-1].target.style.padding := '0px';

      entries[entries.length-1].target.dataset.percwidth :=
        floattostr(entries[entries.length-1].contentRect.width * 100 /
        entries[entries.length-1].target.parentNode.getBoundingClientRect().width)+'%';

      entries[entries.length-1].target.dataset.percheight :=
        floattostr(entries[entries.length-1].contentRect.height * 100 /
        entries[entries.length-1].target.parentNode.getBoundingClientRect().height)+'%';

      if entries[entries.length-1].target.dataset.name = 'input' then
        entries[entries.length-1].target.dataset.percheight :=
          floattostr(entries[entries.length-1].contentRect.height) +'px';
///*
      if entries[entries.length-1].target.dataset.name <> 'component' then
      begin
        for var i := 0 to entries[entries.length-1].target.children.length -1 do
        begin
          var elem := entries[entries.length-1].target.children[i];

          elem.dataset.percwidth :=
            floattostr(StrToInt(strBefore(elem.style.width,'px')) * 100 /
            elem.parentNode.getBoundingClientRect().width)+'%';

          if elem.dataset.name <> 'input' then
          elem.dataset.percheight :=
            floattostr(StrToInt(strBefore(elem.style.height,'px')) * 100 /
            elem.parentNode.getBoundingClientRect().height)+'%';

          //DisPatchEvent('LayoutChangeEvent',elem.id,'click',elem.id);

        end;
      end;
//*/
      DisPatchEvent('LayoutChangeEvent',entries[entries.length-1].target.id,'click',entries[entries.length-1].target.id);
    end;

  //var FResizeObserver : variant := new JObject;
  FResizeObserver := new JObject;
  asm
    (@FResizeObserver) = new ResizeObserver(@x);
  end;

  PrevBody.handle.onclick := procedure(e:variant)
  begin
    e.stopImmediatePropagation();
    //console.log('onclick LayoutChangeEvent');
    //window.alert('click prevbody');
    DisPatchEvent('LayoutChangeEvent',PrevBody.handle.id,'click',PrevBody.handle.id);  //elemBelow.id);
  end;

//handle drops
  PrevBody.handle.ondrop := procedure(ev: variant)
  begin
    ev.preventDefault();

    var data := ev.dataTransfer.getData("text");
    //split payload into image name, mouse-offsetX and mouse-offsetY
    var myarray := StrSplit(data,';');

    var target : variant := document.getElementById(myarray[0]);
    var fragment : variant := new JObject;
    var MyTag : variant;

    if target.parentNode.id = NavPanel.handle.id then    //drag from top
    begin

      asm @fragment = new DocumentFragment(); end;

      //button
      case target.dataset.name of
      'button':
        begin
          MyTag := document.createElement('button');
          MyTag.id := TW3Identifiers.GenerateUniqueObjectId2();
          MyTag.name                  := 'JButton';
          MyTag.dataset.name          := 'button';
          MyTag.style.width           := '82px';
          MyTag.style.height          := '20px';

          MyTag.style.overflow        := 'hidden';
          MyTag.style.cursor          := 'pointer';
          MyTag.style.color           := 'white';
          MyTag.style.backgroundColor := '#2b6cb0';
          MyTag.style.border          := 'none';
          MyTag.style.borderRadius    := '0.5rem';
          MyTag.style.fontSize        := 'x-small';
          //MyTag.style.zoom            := '0.8';

          MyTag.innerHTML := 'Next';
          //MyTag.setAttribute('nonclick','');
          MyTag.setAttribute('onclick','');
          MyTag.setAttribute('contenteditable','true');
          styleSheet.insertRule('#' + MyTag.id + ':hover {background-color: orange !important;}');

          MyTag.setAttribute('addevent','on...');

          fragment.appendChild(MyTag);
        end;

      //image
      'image' :
        begin
          MyTag := document.createElement('div');
          MyTag.id := TW3Identifiers.GenerateUniqueObjectId2();
          MyTag.name                      := 'JImage';
          MyTag.dataset.name              := 'image';
          MyTag.style.width               := '82px';
          MyTag.style.height              := '82px';

          MyTag.style.overflow            := 'hidden';
          MyTag.style.backgroundColor     := 'whitesmoke';
          MyTag.style.border              := 'none';
          MyTag.style.borderRadius        := '0.25rem';
          MyTag.style['background-image'] :=
            "url('https://source.unsplash.com/random?lips')";
          MyTag.style['background-size']  := 'cover';
          MyTag.style['object-position']  := 'center 30%';
          MyTag.style['image-rendering']  := 'high-quality';

          MyTag.innerHTML := '';
          MyTag.setAttribute('addevent','on...');

          fragment.appendChild(MyTag);
        end;

      //container
      'container':
        begin
          MyTag := document.createElement('div');
          MyTag.id := TW3Identifiers.GenerateUniqueObjectId2();
          MyTag.name                  := 'JContainer';
          MyTag.dataset.name          := 'container';
          MyTag.style.width           := '82px';
          MyTag.style.height          := '20px';

          MyTag.style.overflow        := 'hidden auto';
          MyTag.style.color           := 'black';
          MyTag.style.backgroundColor := 'white';
          MyTag.style.border          := '1px solid silver';
          MyTag.style.borderRadius    := '0.25rem';
          MyTag.style['box-shadow']   :=
            '0 10px 20px rgba(0,0,0,0.19),0 6px 6px rgba(0,0,0,0.23)';
          MyTag.style.fontSize        := '16px';

          MyTag.innerHTML := '';
          MyTag.setAttribute('addevent','on...');
          MyTag.setAttribute('contenteditable','false');

          MyTag.onblur := procedure(e:variant)
          begin
            asm
              const regex1 = /&lt;/gi;
              const regex2 = /&gt;/gi;
              var s = (@MyTag).innerHTML;
              var s1 = s.replace(regex1, '<');
              var s2 = s1.replace(regex2, '>');
              (@MyTag).innerHTML = s2;
            end;
          end;

          MyTag.style.display := 'block';
          MyTag.style['padding'] := '10px';

          fragment.appendChild(MyTag);
        end;

      //IFrame
      'iframe':
        begin
          MyTag := document.createElement('div');
          MyTag.id := TW3Identifiers.GenerateUniqueObjectId2();
          MyTag.name                  := 'JIFRame';
          MyTag.dataset.name          := 'iframe';
          MyTag.style.width           := '162px';
          MyTag.style.height          := '162px';

          MyTag.style.overflow        := 'hidden';
          MyTag.style.resize          := 'both';
          MyTag.style.border          := 'none';

          MyTag.innerHTML := '';

          fragment.appendChild(MyTag);
          //
          var MyTag2 : variant;
          MyTag2 := document.createElement('iframe');
          MyTag2.id := TW3Identifiers.GenerateUniqueObjectId2();
          MyTag2.name                  := 'JIFrame';
          MyTag2.style.width           := 'calc(100% - 6px)';
          MyTag2.style.height          := 'calc(100% - 4px)';

          MyTag2.style.overflow        := 'hidden';
          MyTag2.style.border          := 'none';
          MyTag2.style.borderRadius    := '0.5rem';
          MyTag2.src := 'https://lynkfs.design';
          MyTag2.style['pointer-events'] := 'none';

          MyTag2.innerHTML := '';
          MyTag2.setAttribute('addevent','on...');

          fragment.children[0].appendChild(MyTag2);
        end;

      //Input
      'input':
        begin
          //
          MyTag := document.createElement('div');
          MyTag.id := TW3Identifiers.GenerateUniqueObjectId2();
          MyTag.name                  := 'JInput';
          MyTag.dataset.name          := 'input';
          MyTag.style.width           := '162px';
          MyTag.style.height          := '40px';  //'auto';

          MyTag.style.overflow        := 'hidden';
          MyTag.style.resize          := 'both';
          MyTag.style.border          := 'none';

          MyTag.innerHTML := '';

          fragment.appendChild(MyTag);
          //
          var MyTag3 : variant;
          MyTag3 := document.createElement('label');
          MyTag3.id := TW3Identifiers.GenerateUniqueObjectId2();
          MyTag3.name                  := 'JLabel';
          MyTag3.style.overflow        := 'hidden';
          MyTag3.style.color           := 'rgb(86, 88, 105)';
          MyTag3.style.backgroundColor := 'transparent';
          MyTag3.style.fontSize        := 'small';        //'x-small'

          MyTag3.innerHTML := 'label';
          fragment.children[0].appendChild(MyTag3);
          //
          var MyTag2 : variant;
          MyTag2 := document.createElement('input');
          MyTag2.id := TW3Identifiers.GenerateUniqueObjectId2();
          MyTag2.name                  := 'JInput';
          MyTag2.style.width           := 'calc(100% - 6px)';
          MyTag2.style.height          := 'calc(100% - 23px)';

          MyTag2.style.overflow        := 'hidden';
          MyTag2.style.color           := 'rgb(86, 88, 105)';
          MyTag2.style.backgroundColor := 'white';
          MyTag2.style.border          := '1px solid silver';
          MyTag2.style.fontSize        := 'small';
          MyTag2.style.marginTop       := '2px';

          MyTag2.innerHTML := '';
          //MyTag2.setAttribute('nonchange','');
          MyTag2.setAttribute('onchange','');
          MyTag2.setAttribute('placeholder','...');
          MyTag2.setAttribute('label','mylabel');
          MyTag2.setAttribute('type','text');
          MyTag2.setAttribute('required','false');
          MyTag2.setAttribute('addevent','on...');
          fragment.children[0].appendChild(MyTag2);
          //
          MyTag3.setAttribute('for',MyTag2.id);
        end;

      //Editor
      'editor':
        begin
          //
          MyTag := document.createElement('div');
          MyTag.id := TW3Identifiers.GenerateUniqueObjectId2();
          MyTag.name                  := 'JEditor';
          MyTag.dataset.name          := 'editor';
          MyTag.style.width           := '300px';
          MyTag.style.height          := '200px';  //'auto';

          MyTag.style.overflow        := 'hidden auto';
          MyTag.style.resize          := 'both';
          MyTag.style.border          := '1px solid silver';

          MyTag.innerHTML := '';

          MyTag.onblur := procedure(e:variant)
          begin
            asm
              const regex1 = /&lt;/gi;
              const regex2 = /&gt;/gi;
              var s = (@MyTag).innerHTML;
              var s1 = s.replace(regex1, '<');
              var s2 = s1.replace(regex2, '>');
              (@MyTag).innerHTML = s2;
            end;
          end;

          fragment.appendChild(MyTag);

          //
          var MyTag2 : variant;
          MyTag2 := document.createElement('h1');
          MyTag2.id := TW3Identifiers.GenerateUniqueObjectId2();
          MyTag2.name                  := 'JHeader';
          MyTag2.style.overflow        := 'hidden';
          MyTag2.style.color           := 'rgb(32, 33, 35)';
          MyTag2.style.backgroundColor := 'transparent';
          MyTag2.style.lineHeight      := '1.25';
          MyTag2.style.fontSize        := 'small';
          MyTag2.style['font-family']  := 'sans-serif';
          MyTag2.style.padding         := '5px';

          MyTag2.setAttribute('contenteditable','true');
          MyTag2.innerHTML := 'H1 Heading';
          fragment.children[0].appendChild(MyTag2);

//          var newId := TW3Identifiers.GenerateUniqueObjectId2();
//          MyTag.innerHTML :=
//            '<h1 id="' + newId + '" contenteditable="true" style="box-sizing: border-box; ' +
//            'line-height: 1.25; margin: 0px; color: rgb(32, 33, 35); font-family: sans-serif; ' +
//            'letter-spacing: normal; font-size: 34px; padding: 5px; display: block; ' +
//            'margin-bottom: 16px; margin-top: 0px; border-bottom: 0px solid silver; ' +
//            'zoom: ' + '0.5' +
//            '">H1 heading</h1>';
          MyTag2.onclick := procedure(e:variant)
          begin
            e.stopImmediatePropagation();
            DisPatchEvent('LayoutChangeEvent',e.target.id,'click',e.target.id);
          end;

          MyTag.ondblclick := procedure(e: variant)
          begin
            var newId := TW3Identifiers.GenerateUniqueObjectId2();
            MyTag.innerHTML := MyTag.innerHTML +
              '<p id="' + newId + '" contenteditable="true" addevent="on..." style="box-sizing: border-box; ' +
              'line-height: 1.5; margin: 0px; color: #565869; font-family: sans-serif; ' +
              'letter-spacing: 0.3px; font-size: x-small; padding: 5px; display: block; ' +
              'border-bottom: 1px solid silver;' +
              '">new paragraph</p>';
            for var i := 0 to target.children.length -1 do
            begin
              var elem := MyTag.children[i];
              document.getElementById(elem.id).onclick := procedure(e:variant)
              begin
                e.stopImmediatePropagation();
                DisPatchEvent('LayoutChangeEvent',e.target.id,'click',e.target.id);
              end;
            end;  //of editor children
          end;  //of dblclick

          //fragment.appendChild(MyTag);

        end;  //of editor

      //Component
      'component':
        begin
          //
          MyTag := document.createElement('div');
          MyTag.id := TW3Identifiers.GenerateUniqueObjectId2();
          MyTag.name                  := 'JComponent';
          MyTag.dataset.name          := 'component';
          MyTag.style.width           := '100px';
          MyTag.style.height          := '50px';
          MyTag.style.borderRadius    := '0.25rem';

          MyTag.style.overflow        := 'hidden';
          MyTag.style.resize          := 'both';
          MyTag.style.border          := '1px solid silver';

          MyTag.innerHTML := '';

          MyTag.onblur := procedure(e:variant)
          begin
            asm
              const regex1 = /&lt;/gi;
              const regex2 = /&gt;/gi;
              var s = (@MyTag).innerHTML;
              var s1 = s.replace(regex1, '<');
              var s2 = s1.replace(regex2, '>');
              (@MyTag).innerHTML = s2;
            end;
          end;

          var newId := TW3Identifiers.GenerateUniqueObjectId2();

/*
          //ace-editor
          MyTag.innerHTML :=
            '<div id="' + newId + '" data-name="container"' +
            ' style="width: 100%; height: 100%; overflow: hidden; color: black; background-color: white; border: none; border-radius: 0px; font-size: 100%; display: block; padding: 0px; left: 0px; top: 0px; position: relative; resize: both;"' +
            ' oncreate="editor=null; ' +
'var Script = document.createElement(`script`); ' +
'Script.src = `https://cdnjs.cloudflare.com/ajax/libs/ace/1.4.12/ace.min.js`; ' +
//'Script.src=`https://lynkfs.design/zero5/res/src-min-noconflict/ace.js`; ' +
'document.head.appendChild(Script); ' +
'Script.onload = function(e) { ' +
'  console.log(`ace loaded`); ' +
'  ace.config.set(`basePath`, `https://lynkfs.design/zero5/res/src-min-noconflict`); ' +
'  editor = ace.edit(`' + MyTag.id + '`); ' +
'  editor.setTheme(`ace/theme/textmate`); ' +
'  editor.session.setMode(`ace/mode/javascript`); ' +
'  editor.setValue(`var x=''hello world'';\nwindow.alert(x);`); ' +
'};' +
            '"></div>';
*/

/*
          //button
          MyTag.innerHTML :=
            '<button id="' + newId + '" data-name="button"' +
            ' oncreate="' +
            newId + '.parentNode.style[`border`]=`none`;"' +
            ' style="width: 100%; height: 100%; overflow: hidden; cursor: pointer; color: white; background-color: rgb(43, 108, 176); border: none; border-radius: 0.25rem; font-size: 100%; display: block; padding: 0px; left: 0px; top: 0px; position: relative; resize: both;"' +
            ' onclick=""' +
            ' oncreate="">Next</button>';
*/

/*
          //menu
//          MyTag.innerHTML := #'
//<div id="Compo_Menu" data-name="menu" style="width: 100%; height: 100%; overflow: hidden auto; border: none; left: 0px; top: 0px; position: relative; padding: 0px; font-size: 100%; cursor: pointer;" oncreate="Compo_Menu.parentNode.style.width=`auto`; Compo_Menu.parentNode.style.height=`auto`; Compo_Menu.parentNode.style.padding=`10px`;">
//<p id="Compo_Menu_01" contenteditable="true" style="box-sizing: border-box; line-height: 1.5; margin: 0px; color: rgb(86, 88, 105); font-family: sans-serif; letter-spacing: 0.3px; font-size: 100%; padding: 5px; display: block; border: none; background-color: white; user-select: none;" onmouseenter="this.style.backgroundColor=`whitesmoke`;" onmouseleave="this.style.backgroundColor=`white`;" onclick="">menu item 01</p>
//<p id="Compo_Menu_02" contenteditable="true" style="box-sizing: border-box; line-height: 1.5; margin: 0px; color: rgb(86, 88, 105); font-family: sans-serif; letter-spacing: 0.3px; font-size: 100%; padding: 5px; display: block; border: none; background-color: white; user-select: none;" onmouseenter="this.style.backgroundColor=`whitesmoke`;" onmouseleave="this.style.backgroundColor=`white`;" onclick="">menu item 02</p>
//<p id="Compo_Menu_03" contenteditable="true" style="box-sizing: border-box; line-height: 1.5; margin: 0px; color: rgb(86, 88, 105); font-family: sans-serif; letter-spacing: 0.3px; font-size: 100%; padding: 5px; display: block; border: none; background-color: white; user-select: none;" onmouseenter="this.style.backgroundColor=`whitesmoke`;" onmouseleave="this.style.backgroundColor=`white`;" onclick="">menu item 03</p>
//</div>';
          MyTag.innerHTML := #'
<div id="Compo_Menu" data-name="menu" style="width: 100%; height: 100%; overflow: hidden auto; border: none; left: 0px; top: 0px; position: relative; padding: 0px; font-size: 100%; cursor: pointer;" oncreate="Compo_Menu.parentNode.style.width=`auto`; Compo_Menu.parentNode.style.height=`auto`; Compo_Menu.parentNode.style.padding=`10px`;">
</div>';

          for var i := 1 to 3 do begin
            var newId := TW3Identifiers.GenerateUniqueObjectId2();
            MyTag.children[0].innerHTML := MyTag.children[0].innerHTML +
              '<p id="' + newId + '" contenteditable="true" style="box-sizing: border-box; line-height: 1.5; margin: 0px; color: rgb(86, 88, 105); font-family: sans-serif; letter-spacing: 0.3px; font-size: 100%; padding: 5px; display: block; border: none; background-color: white; user-select: none;" onmouseenter="this.style.backgroundColor=`whitesmoke`;" onmouseleave="this.style.backgroundColor=`white`;" onclick="">menu item 0' + inttostr(i) + '</p>' +
              '</div>';
          end;
//
//          MyTag.onclick := procedure(e: variant)
//          begin
//            console.log(i);
//            for var i := 0 to e.target.children.length -1 do
//            begin
//              console.log('dd');
//              var elem := e.target.children[i];
//              if i = 0 then elem.id := 'aaaa';
//              document.getElementById(elem.id).onclick := procedure(e:variant)
//              begin
//                console.log('dbl');
//                e.stopImmediatePropagation();
//                DisPatchEvent('LayoutChangeEvent',e.target.id,'click',e.target.id);
//              end;
//            end;  //of component children
//          end;  //of click
//
          MyTag.ondblclick := procedure(e: variant)
          begin
            var newId := TW3Identifiers.GenerateUniqueObjectId2();
            if e.target.id = MyTag.children[0].id then
              e.target.innerHTML := MyTag.children[0].innerHTML +
                '<p id="' + newId + '" contenteditable="true" style="box-sizing: border-box; line-height: 1.5; margin: 0px; color: rgb(86, 88, 105); font-family: sans-serif; letter-spacing: 0.3px; font-size: 100%; padding: 5px; display: block; border: none; background-color: white; user-select: none;" onmouseenter="this.style.backgroundColor=`whitesmoke`;" onmouseleave="this.style.backgroundColor=`white`;" onclick="">another item</p>' +
                '</div>';
          end;

          fragment.appendChild(MyTag);
        end;  //of component
*/

/*
          //switch
          MyTag.innerHTML := #'
<div id="Compo_36" data-name="container" style="width: 100%; height: 100%; overflow: hidden; color: black; background-color: white; border: none; border-radius: 0px; font-size: 100%; display: block; padding: 0px; left: 0px; top: 0px; position: relative;"
 onclick="if (x===false) {  Switch.style.float=`right`;  Switch.style.backgroundColor=`teal`;  Switch.innerHTML=`On`; } else {  Switch.style.float=`left`;  Switch.style.backgroundColor=`orange`;  Switch.innerHTML=`Off`; } x=!x;"
 oncreate="x=true; Compo_36.parentNode.style.maxHeight=`35px`; Compo_36.parentNode.style.minHeight=`35px`;">
<button id="Switch" name="JButton" data-name="button" style="width: 50%; height: 100%; overflow: hidden; cursor: pointer; color: white; background-color: teal; border: none; border-radius: 0px; font-size: 100%; left: 0%; top: 0%; position: relative; padding: 0px; margin: 0px; float: right;">On</button>
</div>';
*/

/*
          //switch
          var S := #'
<div id="Switch" data-name="container" style="width: 100%; height: 100%; overflow: hidden; color: black; background-color: white; border: none; border-radius: 0px; font-size: 100%; display: block; padding: 0px; left: 0px; top: 0px; position: relative;"
 onclick="if (x===false) {  Button.style.float=`right`;  Button.style.backgroundColor=`teal`;  Button.innerHTML=`On`; } else {  Button.style.float=`left`;  Button.style.backgroundColor=`orange`;  Button.innerHTML=`Off`; } x=!x;"
 oncreate="x=true; Switch.parentNode.style.maxHeight=`30px`; Switch.parentNode.style.minHeight=`30px`;">
<button id="Button" data-name="button" style="width: 50%; height: 100%; overflow: hidden; cursor: pointer; color: white; background-color: teal; border: none; border-radius: 0px; font-size: 100%; left: 0%; top: 0%; position: relative; padding: 0px; margin: 0px; float: right;">On</button>
</div>';
*/

          if ComponentBody = ''
            then window.alert('select a component first');
          var S := ComponentBody;

          //find unique id's
          //-1 parse html string
          var parser : variant := new JObject;
          asm @parser = new DOMParser(); end;
          var doc = parser.parseFromString(S, "text/html");

          //-2 push id's in array
          var nodeIterator :=
            document.createNodeIterator(doc.body,1);
          var currentNode := nodeIterator.nextNode();
          var IDArray : array of string;
          while currentNode <> null do begin      // null = eof
            currentNode.normalize();
            if currentNode.nodeName <> '#text' then
              IDArray.push(currentNode.id);
            currentNode := nodeIterator.nextNode();
          end;

          //-3 replace all array occurences in html string
          for var i := 1 to IDArray.length -1 do    //index[0] = <body> element
          begin
            var newID := TW3Identifiers.GenerateUniqueObjectId2();
            S := StrJoin(StrSplit(S,IDArray[i]),newID);
          end;

          //-4 set string
          MyTag.innerHTML := S;

          //force some attributes
          MyTag.children[0].style.left     := '0px';
          MyTag.children[0].style.top      := '0px';
          MyTag.children[0].style.width    := '100%';
          MyTag.children[0].style.height   := '100%';
          MyTag.children[0].style.position := 'relative';

          //
//          for var i := 0 to MyTag.children[0].children.length -1 do
//          begin
//            MyTag.children[0].children[i].style.position := 'relative';
//          end;

          fragment.appendChild(MyTag);

        end;  //of component

//        MyTag.onclick := procedure(e: variant)
//        begin
//          e.stopImmediatePropagation();
//          DisPatchEvent('LayoutChangeEvent',e.target.id,'click',e.target.id);
//        end;

      end;  //of case target.dataset.name


      ev.target.appendChild(Fragment);
      target := document.getElementById(MyTag.id);
//      target.outerHTML := target.innerHTML;
//      target.innerHTML := '';

/*
      target.onclick := procedure(e: variant)
      begin
        //console.log(i);
        e.stopImmediatePropagation();
        DisPatchEvent('LayoutChangeEvent',e.target.id,'click',e.target.id);
        for var i := 0 to e.target.children.length -1 do
        begin
          console.log('dd');
          var elem := e.target.children[i];
          if i = 0 then elem.id := 'aaaa';
          document.getElementById(elem.id).onclick := procedure(e:variant)
          begin
            console.log('dbl');
            e.stopImmediatePropagation();
            DisPatchEvent('LayoutChangeEvent',e.target.id,'click',e.target.id);
          end;
        end;  //of component children
      end;  //of click
*/
      MyTag.ondragstart := procedure(ev: variant)
      begin
        ev.dataTransfer.setData("text", ev.target.id + ';0;0');
        ev.dataTransfer.effectAllowed := "copy";
        ev.dataTransfer.dropEffect    := "copy";
        ev.dataTransfer.setDragImage(ev.target, 0, 0)
      end;
    end;// of drag from top

    try
      ev.target.appendChild(target);
      asm console.log(target.force.exception); end;
    except
      //console.log(ev);
      if ev.target.getBoundingClientRect().left <> target.getBoundingClientRect().left then begin
        //drop outside target
        target.style.left := inttostr(ev.offsetX - 2) + "px";
        target.style.top  := inttostr(ev.offsetY - 2) + "px";
      end else begin
        //drop within target
        target.style.left := IntToStr(StrToInt(strBefore(target.style.left,'px')) + ev.offsetX) + 'px';        //offsetX
        target.style.top  := IntToStr(StrToInt(strBefore(target.style.top,'px'))  + ev.offsetY) + 'px';
      end;
    end;// of try

    target.onclick := procedure(e:variant)
    begin
      e.stopImmediatePropagation();
      //
      //var elemBelow := document.elementFromPoint(e.clientX, e.clientY);
      DisPatchEvent('LayoutChangeEvent',target.id,'click',target.id);
    end;

    target.dataset.percleft :=
      floattostr(StrToInt(strBefore(target.style.left,'px')) * 100 /
      target.parentNode.getBoundingClientRect().width)+'%';

    target.dataset.perctop :=
      floattostr(StrToInt(strBefore(target.style.top,'px')) * 100 /
      target.parentNode.getBoundingClientRect().height)+'%';

    target.dataset.percwidth :=
      floattostr(StrToInt(strBefore(target.style.width,'px')) * 100 /
      target.parentNode.getBoundingClientRect().width)+'%';

    if target.dataset.name <> 'input' then
      target.dataset.percheight :=
        floattostr(StrToInt(strBefore(target.style.height,'px')) * 100 /
        target.parentNode.getBoundingClientRect().height)+'%';

    DisPatchEvent('LayoutChangeEvent',target.id,'click',target.id);

    target.style.position        := 'absolute';
    target.style.resize          := 'both';
    target.setAttribute('draggable','true');

    FResizeObserver.observe(target);

    for var i := 0 to target.children.length -1 do
    begin
      var elem := target.children[i];

      document.getElementById(elem.id).onclick := procedure(e:variant)
      begin
        e.stopImmediatePropagation();
        DisPatchEvent('LayoutChangeEvent',e.target.id,'click',e.target.id);
      end;
    end;  //of components children

  end;  //of ondrop
end;

procedure TForm4.PreviewPreviewIcon;
begin
  //preview Preview
    PrevPreview := JW3Panel.Create(Preview);
    PrevPreview.SetBounds(Preview.Width - 70,12,20,0);
    PrevPreview.handle.style.height := 'auto';
    PrevPreview.handle.style['cursor'] := 'pointer';
/*
    PrevPreview.handle.innerHTML := #'<svg xmlns="http://www.w3.org/2000/svg" width="10"
      height="12" viewBox="0 0 10 12"><path d="M1.25 2.25a1.5 1.5 0 011.5-1.5h4a1.5
      1.5 0 011.5 1.5v7.5a1.5 1.5 0 01-1.5 1.5h-4a1.5 1.5 0 01-1.5-1.5z" fill="transparent"
      stroke-width="1.5" stroke="#999999"></path><path d="M2 9.5h6V11H2zM2 1h6v1.5H2z"
      fill="#999999"></path></svg>
    ';
*/

    PrevPreview.handle.innerHTML := #'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Layer_1" x="0px" y="0px" viewBox="0 0 502 502" style="enable-background:new 0 0 502 502;" xml:space="preserve">
<g><g><g>
			<path d="M478.482,448.601l-101.6-101.599c8.089-15.262,12.339-32.29,12.339-49.717c0-35.689-18.182-69.164-47.804-88.743V92.53     c0-2.652-1.054-5.196-2.929-7.071l-82.529-82.53C254.083,1.054,251.54,0,248.888,0H24.371c-5.522,0-10,4.477-10,10v427.735     c0,5.523,4.478,10,10,10h307.046c5.522,0,10-4.477,10-10v-37.722l92.825,92.825c5.908,5.908,13.764,9.162,22.119,9.162     c8.356,0,16.212-3.254,22.12-9.162C490.678,480.642,490.678,460.797,478.482,448.601z M307.276,82.53h-48.387V34.143     l24.193,24.193L307.276,82.53z M321.417,396.377v31.358H34.371V20h204.517v72.53c0,5.523,4.478,10,10,10h72.529v95.662     l0.009,0.014c-12.214-4.741-25.275-7.215-38.499-7.215c-58.61,0-106.294,47.683-106.294,106.293s47.684,106.293,106.294,106.293     c13.224,0,26.285-2.474,38.499-7.215L321.417,396.377z M328.948,370.291c-0.848,0.536-1.706,1.057-2.574,1.563     c-13.131,7.67-28.154,11.724-43.446,11.724c-47.583,0-86.294-38.711-86.294-86.293c0-47.582,38.711-86.293,86.294-86.293     c15.291,0,30.315,4.054,43.447,11.724c26.428,15.435,42.846,44.008,42.846,74.569c0,16.35-4.595,32.264-13.289,46.022     C349.097,354.125,339.766,363.455,328.948,370.291z M464.339,478.696c-2.131,2.131-4.964,3.304-7.978,3.304     c-3.014,0-5.847-1.173-7.977-3.304l-98.706-98.706l-0.008-0.001c5.856-4.74,11.221-10.104,15.961-15.96l0.001,0.008     l98.707,98.707C468.737,467.142,468.737,474.298,464.339,478.696z"/>
			<path d="M246.838,238.403c-20.641,12.674-32.964,34.686-32.964,58.882c0,5.523,4.478,10,10,10c5.522,0,10-4.477,10-10     c0-17.19,8.759-32.83,23.429-41.838c4.707-2.89,6.179-9.048,3.289-13.754C257.702,236.986,251.544,235.513,246.838,238.403z"/>
			<path d="M317.708,237.624c-10.52-6.145-22.547-9.392-34.781-9.392c-5.522,0-10,4.477-10,10s4.478,10,10,10     c8.693,0,17.232,2.304,24.693,6.662c1.586,0.926,3.321,1.367,5.034,1.367c3.438,0,6.785-1.775,8.645-4.958     C324.085,246.533,322.477,240.409,317.708,237.624z"/>
</g></g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g></svg>
';

    PrevPreview.handle.onclick := procedure(e: variant)
    begin

      //init window.onload script;
      formOnload := '';
      if document.getElementById('PrevBody').hasAttribute('onload') = true
        then formOnload := document.getElementById('PrevBody').getAttribute('onload');

      //var x : variant := new JObject;
      x := new JObject;
      asm @x = window.open('','preview','menubar=yes,location=yes,resizable=yes,scrollbars=yes,status=yes'); end;

      //set language on html tag
      x.document.documentElement.setAttribute('lang','en');

      //copy stylesheet
      var style := document.createElement("STYLE");
      x.document.head.appendChild(style);
      var styleSheet2 := style.sheet;
      for var i := 0 to styleSheet.cssRules.length -1 do begin
        styleSheet2.insertRule(styleSheet.cssRules[i].cssText);
      end;

      //set meta
      var S :=
        '<meta charset="UTF-8" />' +
        '<meta name="apple-mobile-web-app-capable" content="yes">' +
        '<meta name="mobile-web-app-capable" content="yes">' +
        '<meta name="format-detection" content="telephone=yes">' +
        '<meta name="apple-mobile-web-app-status-bar-style" content="default">';

      //set title
      if trim(CurForm) = ''
        then S := S + '<title>Preview</title>'
        else S := S + '<title>' + CurForm + '</title>';

      //insert copied stylesheet entries for elements on the canvas only
      //ie omit 'body', ':root' and '#component' entries
      //basically all 'Compo_' entries plus the renamed ones
      S := S + '<style>';
      for var j := 0 to styleSheet2.cssRules.length -1 do begin
        If styleSheet2.cssRules[j].cssText.startsWith('body') = false then
          If styleSheet2.cssRules[j].cssText.startsWith(':root') = false then
            If styleSheet2.cssRules[j].cssText.startsWith('#Component') = false then
              s := S + styleSheet2.cssRules[j].cssText;
      end;
      s := s + '</style>';
      x.document.head.innerHTML := s;

      //create script
      script := document.createElement("SCRIPT");
      script.text := 'function load(){';

      x.document.body.innerHTML := PrevBody.handle.innerHTML;

      var nodeIterator :=
        document.createNodeIterator(x.document.body,1);
      var currentNode := nodeIterator.nextNode();
      while currentNode <> null do begin      // null = eof
        currentNode.normalize();

        if currentNode.nodeName <> '#text' then begin

          //create variables
          if currentNode.id <> '' then
          begin
            script.text := script.text +
              'var ' + currentNode.id + '=document.getElementById("' +
              currentNode.id + '"); ';
          end;

          currentNode.removeAttribute('hover');
          currentNode.removeAttribute('label');
          currentNode.removeAttribute('labelstyle');

          if currentNode.hasAttribute('oncreate') then
          begin
            formOnload := formOnload + currentNode.getAttribute('oncreate');
            currentNode.removeAttribute('oncreate');
          end;

          //make containers resizable
          if currentNode.getAttribute('resizeable') <> 'true' then
            currentNode.style.removeProperty('resize');
          currentNode.removeAttribute('resizeable');
          currentNode.removeAttribute('draggable');
          currentNode.style.left   := currentNode.dataset.percleft;
          currentNode.style.top    := currentNode.dataset.perctop;
          if currentNode.style.width <> 'initial' then
            currentNode.style.width  := currentNode.dataset.percwidth;
          if currentNode.style.height not in ['initial','auto'] then
            currentNode.style.height := currentNode.dataset.percheight;
          currentNode.removeAttribute('data-percleft');
          currentNode.removeAttribute('data-perctop');
          currentNode.removeAttribute('data-percwidth');
          currentNode.removeAttribute('data-percheight');

          if currentNode.name = 'JIFrame' then
            currentNode.style['pointer-events'] := 'auto';
          if currentNode.name = 'JInput' then
          begin
            currentNode.style['padding'] := '3px';
            currentNode.style['margin-top'] := '5px';
          end;
          if currentNode.getAttribute('data-name') = 'editor' then
            currentNode.style.border := 'none';

          //slightly bump height of input elements
          if currentNode.getAttribute('data-name') = 'input' then
            currentNode.style['height'] :=
              inttostr(strtoint(strbefore(currentNode.style.height,'px')) + 10) + 'px';

          if currentNode.hasAttribute('data-click') = true
            then currentNode.setAttribute('onclick',currentNode.getAttribute('data-click'));

          currentNode.removeAttribute('data-click');
          currentNode.removeAttribute('addevent');
          currentNode.removeAttribute('contenteditable');
          currentNode.style.fontSize := '100%';

          if currentNode.tagName = 'H1' then
            currentNode.style.fontSize := '200%';
          if currentNode.tagName = 'P' then
            currentNode.style.border := 'none';

          asm
            const regex1 = /&lt;/gi;
            const regex2 = /&gt;/gi;
            var s = (@currentNode).innerHTML;
            var s1 = s.replace(regex1, '<');
            var s2 = s1.replace(regex2, '>');
            (@currentNode).innerHTML = s2;
          end;

        end;
        currentNode := nodeIterator.nextNode();
      end;

      script.text := script.text + FormOnLoad + #10;
      //script.text := script.text + '};';
      //script.text := script.text + '}, false);';
      script.text := script.text + '} window.onload = load;';

      x.document.head.appendChild(script);                //<====close script tag========

      //in preview mode window.onload never happens, so force it.
      x.load();

      FormCode   := x.document.documentElement.innerHTML;  //x.document.body.innerHTML;
      FormDesign := PrevBody.handle.innerHTML;

    end;   // of onclick

    IconHover := JW3Panel.Create(Preview);
    IconHover.handle.style['font-size'] := '12px';
    IconHover.handle.style['color'] := '#333333';
    IconHover.handle.style['background-color'] := 'white';
    IconHover.handle.style['border'] := 'none';
    IconHover.handle.style['letter-spacing'] := '1px';
    IconHover.handle.style['display'] := 'flex';
    IconHover.handle.style['align-items'] := 'center';
    IconHover.handle.style['justify-content'] := 'center';
    IconHover.handle.style['visibility'] := 'hidden';

    PrevPreview.handle.onmouseenter := procedure(e: variant)   //hover hint
    begin
      window.setTimeout(lambda
        IconHover.SetBounds(Preview.Width - 150, 20, 70, 20);
        IconHover.handle.innerHTML := 'Preview';
        IconHover.handle.style['visibility'] := 'visible';
        IconHover.handle.style['border'] := '2px solid #f3f3f3';
        window.setTimeout(lambda
          IconHover.handle.style['visibility'] := 'hidden'; end, 1000);
      end, 100);
    end;   // of mouse enter (hover)

end;

procedure TForm4.PreviewCloseIcon;
begin
  //preview close icon
    var PrevClose := JW3Panel.Create(Preview);
    PrevClose.SetBounds(Preview.width - 30,10,20,0);
    PrevClose.handle.style.height := 'auto';
    //PrevClose.PositionMode := cpAbsolute;
    PrevClose.handle.style['cursor'] := 'pointer';
    PrevClose.handle.innerHTML := #'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Capa_1" x="0px" y="0px" viewBox="0 0 59 59" style="enable-background:new 0 0 59 59;" xml:space="preserve">
<g><path d="M20.187,28.313c-0.391-0.391-1.023-0.391-1.414,0s-0.391,1.023,0,1.414l9.979,9.979C28.938,39.895,29.192,40,29.458,40   c0.007,0,0.014-0.004,0.021-0.004c0.007,0,0.013,0.004,0.021,0.004c0.333,0,0.613-0.173,0.795-0.423l9.891-9.891   c0.391-0.391,0.391-1.023,0-1.414s-1.023-0.391-1.414,0L30.5,36.544V1c0-0.553-0.447-1-1-1s-1,0.447-1,1v35.628L20.187,28.313z"/>
<path d="M36.5,16c-0.553,0-1,0.447-1,1s0.447,1,1,1h13v39h-40V18h13c0.553,0,1-0.447,1-1s-0.447-1-1-1h-15v43h44V16H36.5z"/>
</g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g></svg>';
/*
    PrevClose.handle.innerHTML := #'<svg xmlns="http://www.w3.org/2000/svg" width="10"
      height="10"><path d="M 8.5 1.5 L 1.5 8.5 M 1.5 1.5 L 8.5 8.5" fill="transparent"
      stroke-width="1.5" stroke="#999999" stroke-linecap="round" stroke-linejoin="round">
      </path></svg>
    ';
*/
    PrevClose.handle.onclick := procedure(e: variant)
    begin
      PrevPreview.handle.onclick();         //do a preview

      //these prompts don't work anymore since july 2021 (cross-origin)
      if trim(curForm) = '' then
      begin
        var answer := x.window.prompt('provide formName',curForm);
        curForm := StrBefore(LowerCase(answer),'.');
      end;

      //download html code to download directory : form.html
      x.console.log(x.document.documentElement.innerHTML);
      var z := x.document.documentElement.outerHTML;
      if Uppercase(leftStr(z,14)) <> '<!DOCTYPE HTML>' then
        z := '<!DOCTYPE html>' + z;
      var blob : variant; var url: variant;
      asm @blob = new Blob([@z], { type: 'text/html' }); end;
      asm @url = URL.createObjectURL(@blob); end;
      var a = x.document.createElement('a');
      a.setAttribute( "href", url );
      a.setAttribute( "download", curForm + ".html" );  //"form.html" );
      a.click();
      a.remove();
      asm URL.revokeObjectURL(@url); end;

      //download design code to download directory : myform.design
      console.log(PrevBody.handle.innerHTML);
      var z2 := '';    //PrevBody.handle.innerHTML;
      for var c := 0 to PrevBody.handle.children.length -1 do
      begin
        z2 := z2 + PrevBody.handle.children[c].outerHTML;
      end;
      If FormOnLoad <> '' then
      begin
        //console.log(formOnload);
        z2 := z2 + '=====script=====';
        z2 := z2 + FormOnLoad;  //script.text;
      end;

      var blob2 : variant; var url2: variant;
      asm @blob2 = new Blob([@z2], { type: 'text/html' }); end;
      asm @url2 = URL.createObjectURL(@blob2); end;
      var a2 = document.createElement('a');
      a2.setAttribute( "href", url2 );
      a2.setAttribute( "download", curForm + ".design" );  //"myform.design" );
      a2.click();
      a2.remove();
      asm URL.revokeObjectURL(@url2); end;
    end;

    PrevClose.handle.onmouseenter := procedure(e: variant)   //hover hint
    begin
      window.setTimeout(lambda
        IconHover.SetBounds(Preview.Width - 100, 20, 70, 20);
        IconHover.handle.innerHTML := 'Download';
        IconHover.handle.style['visibility'] := 'visible';
        IconHover.handle.style['border'] := '2px solid #f3f3f3';
        window.setTimeout(lambda
          IconHover.handle.style['visibility'] := 'hidden'; end, 1000);
      end, 100);
    end;   // of mouse enter (hover)
end;

procedure TForm4.CreateCompoPanel;
begin
///*
  var CurrBox1 := JW3Label.Create(CompoPanel);
  CurrBox1.SetBounds(12, 10, 380, 25);
  CurrBox1.Text := 'Current Form : ' + CurForm;

  var OpenBox1 := JW3Label.Create(CompoPanel);
  OpenBox1.SetBounds(12, 50, 380, 25);
  OpenBox1.Text := 'Open Form';

  var ListBox1 := JW3ListBox.Create(CompoPanel);
  ListBox1.SetBounds(10, 80, 240, 180);
  ListBox1.setProperty('background-color', 'white');
  ListBox1.SetProperty('border','1px solid silver');
  ListBox1.RowHeight := 25;

  var NewBox1 := JW3Label.Create(CompoPanel);
  NewBox1.SetBounds(12, 280, 380, 25);
  NewBox1.Text := 'New Form';

  var NewInput1 := JW3Input.Create(CompoPanel);
  NewInput1.SetBounds(12, 310, 240, 25);
  NewInput1.SetAttribute('type','text');
  NewInput1.SetAttribute('placeholder','...name of new form...');

  //delete button (delete form)
  var Button2 := JW3Button.Create(CompoPanel);
  Button2.SetBounds(280, 15, 100, 24);
  Button2.Caption := 'Delete form';
  If CurForm = '' then Button2.Disabled := true;
  Button2.OnClick := procedure(sender: TObject)
  begin
    var answer := window.prompt('Are you sure ?','N');
    If lowercase(answer) in ['y','yes'] then
    begin
      CurForm := '';
      CurrBox1.Text := 'Current Form : ';
    end;
  end;

  //inline proc to make children of PrevBody draggable again
  procedure Reassign;
  begin
    for var j := 0 to PrevBody.handle.children.length-1 do begin

      PrevBody.handle.children[j].ondragstart := procedure(ev: variant)
      begin
        //make Canvas droppable
        PrevBody.handle.ondragover := procedure(ev: variant)
        begin
          ev.preventDefault();
        end;
        //
        ev.dataTransfer.setData("text", ev.target.id + ';' +
                               inttostr(0) + ';' +
                               inttostr(0));
        ev.dataTransfer.effectAllowed := "copy";
        ev.dataTransfer.dropEffect    := "copy";
        //simple drag image
        ev.dataTransfer.setDragImage(document.getElementById(ev.target.id), 0, 0);
      end;

      PrevBody.handle.children[j].onclick := procedure(e:variant)
      begin
        e.stopImmediatePropagation();
        //window.alert(e.target.id);
        var elemBelow := document.elementFromPoint(e.clientX, e.clientY);

        DisPatchEvent('LayoutChangeEvent',e.target.id,'click',elemBelow.id);

        //wing it
        if elemBelow.dataset.name = 'button' then                //<===== delete !!
          styleSheet.insertRule('#' + elemBelow.id + ':hover {background-color: orange !important;}');

        //same code as in ondrop, isolate it
        if elemBelow.dataset.name = 'editor' then
        begin
          elemBelow.ondblclick := procedure(e: variant)
          begin
            var newId := TW3Identifiers.GenerateUniqueObjectId2();
            elemBelow.innerHTML := elemBelow.innerHTML +
              '<p id="' + newId + '" contenteditable="true" style="box-sizing: border-box; ' +
              'line-height: 1.5; margin: 0px; color: rgb(86, 88, 105); font-family: sans-serif; ' +
              'letter-spacing: normal; font-size: 16px; padding: 5px; display: block; ' +
              'border-bottom: 1px solid silver; zoom: ' + '0.5' +
              '">new paragraph</p>';
            for var i := 0 to elemBelow.children.length -1 do
            begin
              var elem := elemBelow.children[i];
              document.getElementById(elem.id).onclick := procedure(e:variant)
              begin
                e.stopImmediatePropagation();
                DisPatchEvent('LayoutChangeEvent',e.target.id,'click',e.target.id);
              end;
            end;  //of editor children
          end;  //of dblclick
        end;  //of editor

      end;

      var target := PrevBody.handle.children[j];
      //target.id := TW3Identifiers.GenerateUniqueObjectId();
      DisPatchEvent('LayoutChangeEvent',target.id,'click',target.id);

      if target.dataset.name = 'button' then begin      //<=== manage stylesheets !!
        window.alert(target.dataset.name);
        styleSheet.insertRule('#' + target.id + ':hover {background-color: orange !important;}');
      end;

      target.dataset.percleft :=
        floattostr(StrToInt(strBefore(target.style.left,'px')) * 100 /
        target.parentNode.getBoundingClientRect().width)+'%';

      target.dataset.perctop :=
        floattostr(StrToInt(strBefore(target.style.top,'px')) * 100 /
        target.parentNode.getBoundingClientRect().height)+'%';

      target.style.resize := 'both';
      target.style.position := 'absolute';

      FResizeObserver.observe(target);

    end;  //all form elements
  end;

  //inline proc to add form to listbox and prepare canvas for when it gets selected
  procedure SelectForm(Item: JW3Panel);
  begin
    Item.setProperty('border', '1px solid silver');
    Item.setProperty('background-color', 'white');

    ListBox1.Add(Item);
    Item.setProperty('padding-top', '5px');

    Item.handle.onmouseenter := lambda(event: variant)
      event.target.style['background-color'] := '#2196f3';
      event.target.style['color'] := 'white';
    end;
    Item.handle.onmouseout := lambda(event: variant)
      event.target.style['background-color'] := 'white';
      event.target.style['color'] := 'black';
    end;

    Item.OnClick := Procedure(sender: TObject)
    begin
      var Selected := (sender as TElement).Tag;

      CurForm := trim(selected);
      CurrBox1.Text := 'Current Form : ' + CurForm;
      Button2.Disabled := false;

      PrevBody.handle.dataset.initclear := 'n';

      FResizeObserver.disconnect();

      //PrevBody.Clear;
      While PrevBody.handle.firstChild <> nil do
        PrevBody.handle.removeChild(PrevBody.handle.firstChild);

      //get saved canvas
      PrevBody.handle.innerHTML := FormDesign;

      Reassign;

    end;  //onclick item (form)
  end;

  //add all forms to listbox and prepare canvas for selected form
  var Item := JW3Panel.Create(ListBox1);
  Item.Text := '&nbsp;&nbsp;Demo';
  Item.Tag  := 'Demo';
  //invoke inline proc above
  SelectForm(Item);

  //new button (new form)
  var Button3 := JW3Button.Create(CompoPanel);
  Button3.SetBounds(12, 350, 100, 24);
  Button3.Caption := 'Create form';
  If NewInput1.Text = '' then Button3.Disabled := true;
  NewInput1.handle.oninput := lambda Button3.Disabled := false; end;
  Button3.OnClick := procedure(sender: TObject)
  begin
/*
    If NewInput1.Text <> '' then
    begin
      //check exist already ?
      var exists : boolean := false;
      For var i := 0 to Domain.Forms.length -1 do
      begin
        If Domain.Forms[i].FormName = NewInput1.Text then exists := true;
      end;
      if exists then begin
        window.alert('Form "' + NewInput1.Text + '" is an existing form');
      end else begin
        var Form01 := new ZForm;
        Form01.FormName := NewInput1.Text;
        //NewInput1.Text := '';
        Button3.Disabled := true;

        PrevBody.handle.dataset.initclear := 'n';
        FResizeObserver.disconnect();

        //add form to domain
        Domain.Forms.add(Form01);
        //add to listbox and prepare canvas for when it gets selected
        var Item := JW3Panel.Create(ListBox1);
        Item.Text := '&nbsp;&nbsp;' + Form01.FormName;
        Item.Tag  := Form01.FormName;
        SelectForm(Item);     //invoke inline proc

        CurForm := NewInput1.Text;
        CurrBox1.Text := 'Current Form : ' + CurForm;
        Button2.Disabled := false;

        //clear canvas
        While PrevBody.handle.firstChild <> nil do
          PrevBody.handle.removeChild(PrevBody.handle.firstChild);

        PrevBody.handle.innerHTML := '';

        console.log(Domain);
        asm @DomainJson = JSON.stringify((@Domain)); end;
        //console.log(DomainJson);
        window.localStorage.setItem('zero',DomainJson);

      end;  //non-existing form
    end;  //non-empty formname
*/
  end;  //button3 onclick
//

  var FileInput1 := JW3Input.Create(CompoPanel);
  FileInput1.SetBounds(12, 410, 240, 25);
  FileInput1.SetAttribute('type','file');
  FileInput1.SetAttribute('name','FileInput');
  FileInput1.handle.onchange := procedure(e:variant)
  begin

    var fr : variant;
    asm @fr=new FileReader(); end;
    fr.onload := procedure()
    begin
      CurForm := StrBefore(FileInput1.handle.files[0].name,'.');
      CurrBox1.Text := 'Current Form : ' + CurForm;
      Button2.Disabled := false;

      PrevBody.handle.dataset.initclear := 'n';

      FResizeObserver.disconnect();

      //PrevBody.Clear;
      While PrevBody.handle.firstChild <> nil do
        PrevBody.handle.removeChild(PrevBody.handle.firstChild);

      if pos('=====script=====',fr.result) = 0
      then begin
        //get saved canvas
        PrevBody.handle.innerHTML := fr.result;
      end else begin
        var resultarray : array of string;
        resultarray := StrSplit(fr.result,'=====script=====');
        PrevBody.handle.innerHTML := resultarray[0];
        FormOnLoad := resultarray[1];
        document.getElementById('PrevBody').setAttribute('onload',FormOnLoad);
      end;

      //make everything draggable again
      Reassign;

    end;
    fr.readAsText(FileInput1.handle.files[0]);
  end;

end;

procedure TForm4.Resize;
begin
  inherited;
end;

end.

