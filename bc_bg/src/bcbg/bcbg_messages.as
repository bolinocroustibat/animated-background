package bcbg {
  import flash.events.EventDispatcher;
  public class bcbg_messages {
    private static var event_dispatcher:EventDispatcher;
		private static var allowInstantation:Boolean;
		
		public static function getInstance():EventDispatcher {
			if (event_dispatcher == null) {
				allowInstantation = true;
				event_dispatcher = new EventDispatcher();
				allowInstantation = false;
			}
			return event_dispatcher;
		}
		
		public function bcbg_messages() {
			if (!allowInstantation) {
				throw new Error("Error: Instantiation failed: Use Si_messages.getInstance()");
			}
		}
  }
}