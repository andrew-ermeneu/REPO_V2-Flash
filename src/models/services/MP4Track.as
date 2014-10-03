/**
 * Created by ska4ek on 12.08.14.
 */
package models.services {
import events.CustomPlayerEvent;

import flash.errors.IOError;
import flash.events.AsyncErrorEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.ByteArray;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import ua.ska4ek.Settings;

public class MP4Track extends EventDispatcher implements IPlayer{

    private var netConn:NetConnection=new NetConnection();
    private var netStrm:NetStream;
    private var urlStr:String;
    private var _trackLength:Number = 1;
    private var intervalId:uint;
    private var _isPreloaded:Boolean = false;
    private var _played:Boolean = false;
    private var _playing:Boolean = false;

    public function MP4Track(url:String) {
//        trace("\t\t new MP4 track =  " + url);


        urlStr=url;

        if(urlStr.indexOf("?") > -1){
            urlStr += "&random="+ (new Date().getTime() + Math.random()* 100);
        } else {
            urlStr += "?random="+ (new Date().getTime() + Math.random()* 100);
        }

        connect();
    }

    private function connect():void{
        if(netConn)netConn.close();
        netConn=new NetConnection();
        netConn.addEventListener(NetStatusEvent.NET_STATUS,netStatusHdlr);
        netConn.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handleError);
        netConn.addEventListener(IOErrorEvent.IO_ERROR, handleError);
        netConn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
        netConn.connect(null);
    }

    private function netStatusHdlr(e:NetStatusEvent):void{
//        trace('netStatusHdlr:'+e.info.code);

        switch(e.info.code){
            case 'NetConnection.Connect.Success':
                requestAudio();
                break;
            case "NetStream.Play.Start":
//                    _isPreloaded = true;
//                    dispatchEvent(new CustomPlayerEvent(CustomPlayerEvent.PRELOADED));
                break;
            case "NetStream.Buffer.Flush":
                    _played = true;
                    dispatchEvent(new CustomPlayerEvent(CustomPlayerEvent.PLAYING_COMPLETED));
                break;
            case "NetStream.Play.StreamNotFound":
                    handleError(null);
                break;
            case "NetStream.Buffer.Full":
                     _isPreloaded = true;
                    dispatchEvent(new CustomPlayerEvent(CustomPlayerEvent.PRELOADED));
                break;
        }
    }

    private function requestAudio():void{
        if(netStrm!==null){
            netStrm.seek(0);
            netStrm.close();
        }
        netStrm=new NetStream(netConn);
        netStrm.addEventListener(NetStatusEvent.NET_STATUS,netStatusHdlr);
        netStrm.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handleError);
        netStrm.addEventListener(IOErrorEvent.IO_ERROR, handleError);
        netStrm.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);

        netStrm.checkPolicyFile=false;
        var meta:Object = new Object();
        meta.onMetaData = function(meta:Object){_trackLength = meta.duration;}
        netStrm.client = meta;
        netStrm.bufferTime = 0;
        netStrm.play(urlStr);
        netStrm.pause();
        intervalId = setInterval(enterFrameHandler, 100);
    }

    private function enterFrameHandler():void {
        if(!_isPreloaded)
            dispatchEvent(new CustomPlayerEvent(CustomPlayerEvent.LOADING_PROGRESS));
        else if(_playing)
            dispatchEvent(new CustomPlayerEvent(CustomPlayerEvent.PLAYING));
    }

    private function handleError(e:*):void{

        if(netStrm){
            netStrm.removeEventListener(NetStatusEvent.NET_STATUS,netStatusHdlr);
            netStrm.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, handleError);
            netStrm.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
            netStrm.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
        }

        if(netConn){
            netConn.removeEventListener(NetStatusEvent.NET_STATUS,netStatusHdlr);
            netConn.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, handleError);
            netConn.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
            netConn.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
        }


//        trace('asyncErrorHdlr:'+e);
        dispatchEvent(new CustomPlayerEvent(CustomPlayerEvent.PLAYER_ERROR, e));
    }



    public function play():void {
        netStrm.resume();
        _playing = true;
        if(!intervalId)intervalId = setInterval(enterFrameHandler, 100);
    }
    public function pause():void {
        netStrm.pause();
        _playing = false;
        if(intervalId){
            clearInterval(intervalId);
            intervalId = null;
        }
    }

    public function get time():String{return Settings.timeToString(netStrm.time, false);}
    public function get isPreloaded():Boolean{return _isPreloaded;}
    public function get played():Boolean{return _played;}
    public function get percent():Number{return netStrm.bytesLoaded/netStrm.bytesTotal;}

    public function kill():void {
        _played = true;
        _isPreloaded = true;
        _playing = false;

        if(intervalId){
            clearInterval(intervalId);
            intervalId = null;
        }

        if(netStrm){
            netStrm.removeEventListener(NetStatusEvent.NET_STATUS,netStatusHdlr);
            netStrm.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, handleError);
            netStrm.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
            netStrm.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);

            netStrm.close();
            netStrm = null;
        }

        if(netConn){
            netConn.removeEventListener(NetStatusEvent.NET_STATUS,netStatusHdlr);
            netConn.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, handleError);
            netConn.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
            netConn.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);

            netConn.close();
            netConn = null;
        }
    }



    override public function addEventListener(event_type:String, listener:Function, usecapture:Boolean = false, priority:int = 0, weakReference:Boolean = false):void{
        super.addEventListener(event_type, listener, usecapture, priority, weakReference);
    }

    override public function removeEventListener(event_type:String,listener:Function,useCapture:Boolean = false):void{
        super.removeEventListener(event_type, listener, useCapture);
    }


}
}
