package events
{
	import flash.events.Event;

	/**
	 * ...
	 * @author Andrew Ermeneu
	 */
	public class CustomPlayerEvent extends Event
	{


        public static const PRELOADED:String = "PRELOADED";
        public static const LOADING_PROGRESS:String = "LOADING_PROGRESS";
        public static const PLAYING_COMPLETED:String = "PLAYING_COMPLETED";
        public static const PLAYING:String = "PLAYING";

		public static const INIT_DATA_GOT_SUCCESS : String = "TRACKING_SENT";
		public static const INIT_DATA_ERROR : String = "INIT_DATA_GOT_ERROR";

        public static const PLAYER_ERROR:String = "PLAYER_ERROR";

        public var body:Object;

		public function CustomPlayerEvent(type:String, body:Object = null)
		{
			super(type, false, true);

			this.body = body;

		}

		public override function clone():Event
		{
			return new CustomPlayerEvent(type, body);
		}
	}

}
