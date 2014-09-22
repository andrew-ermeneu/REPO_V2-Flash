/**
 * Created by ska4ek on 12.08.14.
 */
package models.services {
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.NetStreamAppendBytesAction;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.utils.ByteArray;

public class TrackLoader {
    public function TrackLoader() {
    }

    public static function loadTrack(url:String):void{
        var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        configureListeners(loader);

        var request:URLRequest = new URLRequest(url);
        try {
            loader.load(request);
        } catch (error:Error) {
            trace("Unable to load requested document.");
        }
    }

    private static function configureListeners(dispatcher:IEventDispatcher):void {
        dispatcher.addEventListener(Event.COMPLETE, completeHandler);
        dispatcher.addEventListener(Event.OPEN, openHandler);
        dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
    }

    private static function completeHandler(event:Event):void {
//        var loader:URLLoader = URLLoader(event.target);
//        var byte : ByteArray = new ByteArray();
//        byte.writeObject(loader.data);
//        byte.position = 0;
//        trace("completeHandler: " + loader.data);

//        var vars:URLVariables = new URLVariables(loader.data);
//        trace("The answer is " + vars.answer);

//        var my_nc:NetConnection = new NetConnection();
//        my_nc.connect(null);
//        var my_ns:NetStream = new NetStream(my_nc);
//        my_ns.client = customClient;
//        my_ns.play(null);
//        MP4Player.playTrackBytes(event.target.data as ByteArray);

//        my_ns.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
//        my_ns.play(null);
//        my_video.attachNetStream(my_ns);
//        my_ns.play("yourURL");
    }


    private static function openHandler(event:Event):void {
        trace("openHandler: " + event);
    }

    private static function progressHandler(event:ProgressEvent):void {
        trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
    }

    private static function securityErrorHandler(event:SecurityErrorEvent):void {
        trace("securityErrorHandler: " + event);
    }

    private static function httpStatusHandler(event:HTTPStatusEvent):void {
        trace("httpStatusHandler: " + event);
    }

    private static function ioErrorHandler(event:IOErrorEvent):void {
        trace("ioErrorHandler: " + event);
    }
}
}
