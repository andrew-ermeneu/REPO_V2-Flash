package ua.ska4ek {

//import com.google.analytics.AnalyticsTracker;
import flash.external.ExternalInterface;

	
	/**
	 * @author ska4ek
	 */
	
	public class Settings
	{
        public static var SERVER:String = "";
//        public static const ANALYTIC    : String = "UA-52652480-1";
//        public static var TRACKER		: AnalyticsTracker;
        public static var CUR_TRACKER	: String = "";
        public static var HASHCODE      : String = "";

		
		//public static var LOADER_CONTEXT	: LoaderContext = new LoaderContext(true, new ApplicationDomain);

		public function Settings() : void {
			
		}

        public static function analyticURL(value : String = "") : void {
//            if(ExternalInterface.available)
//                ExternalInterface.call('setAnalyticPage', "/" + CUR_TRACKER + value);
//            if(ANALYTIC != "")TRACKER.trackPageview("/" + CUR_TRACKER + value);
        }

        public static function analyticEvent(value : String = "", event:String = "click") : void {
//            if(ExternalInterface.available)
//                ExternalInterface.call('setAnalyticEvent', Settings.CUR_TRACKER+"_"+value);
//            if(ANALYTIC != "")TRACKER.trackEvent("tuborgGreenFest", event, Settings.CUR_TRACKER+"_"+value);
        }


		public static function validateEmail(str:String) : Boolean {
			var pattern:RegExp = /(\w|[_.\-])+@((\w|-)+\.)+\w{2,4}+/;
			var result:Object = pattern.exec(str);
			if(result == null) {
				return false;
			}
			return true;
		}
		
		public static function handleTrace(value : String) : void {
			if(ExternalInterface.available)
                ExternalInterface.call('console.log', value);
		}
		
		
		public static function timeToString(time:Number, addMS:Boolean = true):String{
			  time = Math.abs(   time) ;
			  var seconds:int = Math.floor(time % 60);
			  var minutes:int = Math.floor(time/60);
			  var milliseconds:int = Math.floor((time % 1) * 100);
			  
			  var msstring:String = milliseconds < 10 ? '0'+milliseconds.toString() : milliseconds.toString();
			  var sstring:String = seconds < 10 ? '0'+seconds.toString() : seconds.toString();
			  return minutes + ':' + sstring + ((addMS) ? ':' + msstring : "");
		 }
		
	}
}