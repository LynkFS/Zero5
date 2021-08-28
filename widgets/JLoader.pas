unit JLoader;


interface

uses
  JElement;

type
  JW3Loader = class(TElement)
  public
    constructor Create(parent: TElement); virtual;
  end;

implementation

uses Globals;

{ JW3Loader }

constructor JW3Loader.Create(parent: TElement);
begin
  inherited Create('div', parent);
  setProperty('border','6px solid #f3f3f3');
  setProperty('border-radius','50%');
  setProperty('border-top','6px solid #3498db');
  setProperty('-webkit-animation','spin 2s linear infinite');
  setProperty('animation','spin 2s linear infinite');

  var s := #'@-webkit-keyframes spin {
             0% { -webkit-transform: rotate(0deg); }
             100% { -webkit-transform: rotate(360deg); }
             }';

  document.styleSheets[0].insertRule(s, 0);

end;

end.
