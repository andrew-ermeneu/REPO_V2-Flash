/**
 * Created by zip on 13/9/14.
 */
package models.services {
import com.adobe.serialization.json.JSON;

import flash.display.Sprite;
import flash.events.Event;
import flash.external.ExternalInterface;

import models.RequestVO;




public class JSPlayerActivator extends Sprite{

    private var _token:String;
    private var _request_vo:RequestVO;
    public var response:String;

    public function JSPlayerActivator(token:String, request_vo:RequestVO) {

        this._token = token;
        this._request_vo = request_vo;


    }



    private function handleReceivedFromJavaScript(response:String):void {
        trace("handleReceivedFromJavaScript: " + response);

        trace("JSON: " + JSON.stringify(response));

        this.response = response;
        dispatchEvent(new Event(Event.COMPLETE, false));
    }




    public function activatePlayer():void {
        if (ExternalInterface.available) {
            try {
                ExternalInterface.addCallback("sendToActionScript", handleReceivedFromJavaScript);
                ExternalInterface.call("jsActivatePlayer", _token);

            } catch(e:Error){
                trace("Error sendToActionScript, " + e.message);
            }
        }
    }




    public function get request_vo():RequestVO {
        return _request_vo;
    }
}
}
