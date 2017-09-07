package bcbg {
  import flash.events.Event;
  public class bcbg_event extends Event{
    public static const CHANGE_DEPTH:String = "onChangeDepth";
    public var params:Object;
    
    public function bcbg_event(type:String, params:Object, bubbles:Boolean = false, cancelable:Boolean = false) {
      super(type, bubbles, cancelable);
			this.params = params;
    }
    
    public override function clone():Event{
      return new bcbg_event(type, this.params, bubbles, cancelable);
    }

    public override function toString():String{
      return formatToString("bcbg_event", "params", "type", "bubbles", "cancelable");
    }
  }
}
