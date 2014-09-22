/**
 * Created by zip on 8/9/14.
 */
package models.services {
public interface IPlayer {


    function addEventListener(event_type:String, listener:Function, usecapture:Boolean = false, priority:int = 0, weakReference:Boolean = false):void;
    function removeEventListener(type:String,listener:Function,useCapture:Boolean = false):void;


    function get time():String;




    function get played():Boolean;

    function play():void;
    function kill():void;
    function pause():void;
}
}
