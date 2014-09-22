/**
 * @author ska4ek
 */
package ua.ska4ek.events {
import flash.events.Event;


public class StageEvent extends Event
{
    public static const TO_REGISTRATION				: String = "to_registration";
    public static const TO_ERROR					: String = "to_error";
    public static const TO_FORMULA					: String = "to_formula";
    public static const TO_RATING					: String = "to_rating";
    public static const TO_POSITION					: String = "to_position";
    public static const TO_CLOSE					: String = "to_close";
    public static const TO_HOME					    : String = "to_home";
    public static const TO_HELP                     : String = "to_help";
    public static const TO_RECORD                   : String = "to_record";
    public static const TO_LOAD                     : String = "to_load";

    public static const TIME_UP						: String = "time_up";

    public static const VK							: String = "vk";
    public static const FB							: String = "fb";

    public static const FULLSCREEN					: String = "fullScreen";
    public static const BUTTON_CLICK	 			: String = "button_click";

    public static const KEY_DOWN					: String = "key_down";
    public static const KEY_UP						: String = "key_up";

    public static const MENU						: String = "menu";
    public static const START						: String = "start";
    public static const STOP						: String = "stop";
    public static const FINISH						: String = "finish";
    public static const FAIL						: String = "fail";
    public static const CHOICE						: String = "choice_some";
    public static const CHANGE						: String = "change_some";
    public static const EDIT						: String = "edit";
    public static const PROGRESS					: String = "progress";
    public static const LOADED						: String = "loaded";
    public static const LOADING						: String = "loading";
    public static const COMPLETE					: String = "complete";
    public static const ERROR						: String = "error";
    public static const CLOSE						: String = "close";
    public static const HELP						: String = "help";
    public static const OK							: String = "ok";
    public static const NO							: String = "no";
    public static const RIGHT						: String = "right";
    public static const WRONG						: String = "wrong";
    public static const ON							: String = "on";
    public static const OFF							: String = "off";
    public static const YES							: String = "yes";
    public static const SAVE						: String = "save";
    public static const NEXT						: String = "next";
    public static const BACK						: String = "back";
    public static const MOVE						: String = "move";
    public static const UPDATE						: String = "update";
    public static const REPLAY						: String = "replay";
    public static const END							: String = "end";
    public static const MORE						: String = "more";
    public static const PAUSE						: String = "pause";
    public static const HIDE						: String = "hide";
    public static const AGAIN                       : String = "again";
    public static const EXIT                        : String = "exit";
    public static const CLEAR                       : String = "clear";
    public static const REMOVE                      : String = "remove";
    public static const OVER                        : String = "over";
    public static const OUT                         : String = "out";
    public static const WITH                        : String = "with";
    public static const WITHOUT                     : String = "without";
    public static const RESIZE                      : String = "change_size";
    public static const OPEN                        : String = "open";
    public static const TAKE                        : String = "take";
    public static const PUT                         : String = "put";
    public static const PLUS                        : String = "plus";
    public static const MINUS                       : String = "minus";
    public static const ADD                         : String = "add_to_some";
    public static const CREATE                      : String = "create_some";
    public static const SHARE                       : String = "share_some";
    public static const UPLOAD                      : String = "upload_some";
    public static const PUBLISH                     : String = "publish_some";
    public static const LOSE                        : String = "lose_some";

    public static const STOP_MOVE                   : String = "stop_move";
    public static const START_MOVE                  : String = "start_move";

    protected var _target	: Object;
    protected var _ready	: Boolean;
    public static const FROM_FB:String = "from_fb";
    public static const FROM_PC:String = "from_pc";









		
		
        public function StageEvent(type:String, target:Object = null) {
			super(type, false, true);
			_target = target;
        }
		
		override public function get target():Object {
			if (_ready) {
				return _target;
			} else {
				_ready = true;
			}
			return null;
		}

    }

}