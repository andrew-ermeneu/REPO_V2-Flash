/**
 * Created by zip on 6/8/14.
 */
package models {
import flash.net.URLRequestMethod;




public class RequestVO {

    public var id:String;
    public var url:String;
    public var type:String;
    public var object:Object;
    public var response_obj:Object;
    public var error_msg:String;
    public var method:String = URLRequestMethod.POST;

    public static const REQUEST_GET_TOKEN:String = "token";
    public static const REQUEST_REGISTER_DEVICE:String = "devices";
    public static const REQUEST_ACTIVATE_DEVICE:String = "activate";
    public static const REQUEST_GET_COMMANDS:String = "commands/next";
    public static const REQUEST_GET_MEDIA:String = "media/next";
    public static const REQUEST_REMOVE_SONG:String = "media_removed";


    public function RequestVO() {
    }
}
}
