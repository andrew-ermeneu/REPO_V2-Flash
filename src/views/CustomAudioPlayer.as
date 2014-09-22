/**
 * Created by zip on 7/8/14.
 */
package views {
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.media.ID3Info;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundLoaderContext;
import flash.media.SoundTransform;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.ObjectEncoding;
import flash.net.URLRequest;




public class CustomAudioPlayer {

    private var soundObject:Sound;
    private var req:URLRequest;
    private var soundControl:SoundTransform;
    private var soundChannel:SoundChannel;

    private var sound_url:String;

    var nc:NetConnection = new NetConnection();
    var ns:NetStream;
    var id3_ns:NetStream;
    var nsClient:Object = new Object();
    var id3Client:Object = new Object();
    var isConnected:Boolean = false;
    var currentSong:Number = 0;
    var soundXForm:SoundTransform = new SoundTransform();


    public function CustomAudioPlayer(sound_url:String) {
        this.sound_url = sound_url;

//        req = new URLRequest(sound_url);
//        soundObject = new Sound();
//
//        soundObject.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
//        soundObject.addEventListener(HTTPStatusEvent.HTTP_STATUS, statusHandler);
//        soundObject.addEventListener(ProgressEvent.PROGRESS, progressHandler);
//        soundObject.addEventListener(Event.ID3, id3Handler);
//
//        soundObject.load(req);
//
//
//        soundControl = new SoundTransform();
//        soundControl.volume = 1;



        NetConnection.defaultObjectEncoding = ObjectEncoding.AMF0;

        soundXForm.volume = 1;


        NetConnection.prototype.onBWDone = function(info) {}
        NetConnection.prototype.onBWCheck = function() {}

        nsClient.onPlayStatus	= function( obj:Object ):void{
            switch ( obj.code ){
                case "NetStream.Play.Switch":
                    break;
                case "NetStream.Play.Complete":
                    soundCompleteHandler();
                    break;
                default:
                    for( var a:String in obj ){ trace(a + " " + obj[ a ]); }
                    break;
            }
        }
        id3Client.onId3 = function( obj:Object ):void{
            if(obj["artist"] != undefined){
//            text_txt.text = "Artist: " + obj["artist"].toString();
            }
            if(obj["songtitle"] != undefined){
//            text_txt.text += "\nTitle: " + obj["songtitle"].toString()
            }
            for( var b:String in obj ) {
                //trace(b + ": " + obj[ b ]);
            }
        }



        playSong(0);

    }

    function securityErrorHandler( e ):void{
        trace("SecurityError: " + e);
    }
    function netStatusHandler( e:NetStatusEvent ):void {
        switch( e.info.code ) {
            case "NetConnection.Connect.Success":
                connectionSuccess( new Event( "success" ) );
                break;
            case "NetConnection.Connect.Failed":
                connectionFailed( new Event( "failed" ) );
                break;
            case "NetStream.Play.Stop":
//			trace("netStatusHandler:code: " + e.info.code);
                break;
            default:
                //trace( "netStatusHandler:code: " + e.info.code );
                break;
        }
    }


    function connectionSuccess( e:Event ):void {

        if( ns == null ){
            ns = new NetStream(nc);
            ns.addEventListener( AsyncErrorEvent.ASYNC_ERROR, catchAll );
            ns.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
            ns.addEventListener( IOErrorEvent.IO_ERROR, catchAll );
        }
        //C. Assign a new ID3 Netstream Connection
        if( id3_ns == null ) {
            id3_ns = new NetStream(nc);
            id3_ns.addEventListener( AsyncErrorEvent.ASYNC_ERROR, catchAll );
            id3_ns.addEventListener( IOErrorEvent.IO_ERROR, catchAll );
            id3_ns.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
        }
        playSong(0);
    }

    function createConnection(appURL:String):void {
        if( !nc.connected){
            nc.connect(appURL);
            nc.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
            nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }else{
            nc.close();
            isConnected = false;
        }
    }

    function playSong(position:Number):void {
        if (!isConnected) { createConnection(sound_url); }
        id3_ns.play(sound_url);
        id3_ns.client = id3Client;
        ns.play(sound_url, 0);
        ns.client = nsClient;
        ns.soundTransform = soundXForm;
    }



    function connectionFailed( e:Event ):void {
        isConnected = false;
    }
    function catchAll( e:Event ){
        trace("\n\n\n\nCatch All: " + e + "\n\n\n\n");
    }




    function soundCompleteHandler():void {
        trace("soundCompleteHandler");
    }



//
//    private function statusHandler(event:HTTPStatusEvent):void {
//        trace("sound status: " + event.status);
//    }
//
//
//
//
//    private function id3Handler(event:Event):void {
//        var id3:ID3Info = soundObject.id3;
//        trace("sound id3: " + id3.artist);
//    }
//
//
//    function progressHandler(event:ProgressEvent):void
//    {
//        var percentLoaded = Math.round(100 * (event.bytesLoaded / event.bytesTotal));
//
//        var currTime = new Date().time;
//
//        if (percentLoaded == 100) {
////            soundObject.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
//            playSong();
//        }
//    }
//
//
//    private function playSong():void {
//
//        trace("sound playSong");
//
//        soundChannel = soundObject.play(0);
//        soundChannel.soundTransform = soundControl;
//        soundChannel.addEventListener(Event.SOUND_COMPLETE, songComplete);
//    }
//
//
//
//    private function songComplete(event:Event):void {
//        trace("sound songComplete");
//    }
//
//
//    private function errorHandler(errorEvent:IOErrorEvent):void {
//        trace("sound ERROR: " + errorEvent.text + ' on ' + sound_url);
//
//    }
//


}
}
