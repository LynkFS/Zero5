unit Types;

interface

type

{ Event management }

  JEvent = class external 'Event'
  public
    procedure stopPropagation;
  end;

  TEventListener  = procedure(Event: JEvent);
  TEventHandler  = function (event: JEvent): Variant;

  JEventTarget = partial class external 'EventTarget'
  public
    procedure addEventListener(&type: String; callback: TEventListener; capture : Boolean = false); overload;
  end;

  JGlobalEventHandlers = class external 'GlobalEventHandlers'
  public
    onload: TEventHandler;
  end;

{ Building blocks }

  JNode = class external 'Node' (JEventTarget)
  public
    parentNode : JNode;
    firstChild : JNode;
    function appendChild(node : JNode) : JNode;
    function removeChild(child : JNode) : JNode;
  end;

  JElement = class external 'Element' (JNode)
  public
    id : String;
    className : String;
    procedure setAttribute(name : String; value : String);
    innerHTML : String;
  end;

  JHTMLElement = partial class external 'HTMLElement' (JElement);

{ Style management }

  JCSSStyleDeclaration = class external 'CSSStyleDeclaration'
  public
    function getPropertyValue(propertyName : String) : String;
    procedure setProperty(propertyName, value : String);
  end;

  JElementCSSInlineStyle = class external 'ElementCSSInlineStyle'
  public
    style : JCSSStyleDeclaration;
  end;

{ Ajax }

  JXMLHttpRequest = class external 'XMLHttpRequest'
  public
    responseText: String;// read only
    constructor Create;
    procedure open(&method: String; url: String); overload;
    procedure setRequestHeader(&name: String; value: String);
    procedure send(data: Variant); overload;
  end;

{ Mutation observer }

  JMutationObserver = class;
  JMutationObserverInit = class;
  JMutationRecord = class;

  JMutationCallback = procedure (mutations : array of JMutationRecord; observer : JMutationObserver);

  JMutationObserver = class external 'MutationObserver'
  public
    constructor Create(callback : JMutationCallback);
    procedure observe(target : JNode; options : JMutationObserverInit);   //JNode
  end;

  JMutationObserverInit = class external 'MutationObserverInit'
  public
    attributes : Boolean;
    attributeOldValue : Boolean;
  end;

  JMutationRecord = class external 'MutationRecord'
  end;

{ JSON }

  MyJSON = class external 'JSON'
  public
    function Parse(Text: String): Variant; overload; external 'parse';
    function Stringify(const Value: Variant): String; overload; external 'stringify';
  end;

var
  JSON external 'JSON': MyJSON;

