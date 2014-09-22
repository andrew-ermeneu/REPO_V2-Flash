/**
 * Created by ska4ek on 12.08.14.
 */
package models.services {
import events.CustomPlayerEvent;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundLoaderContext;
import flash.media.SoundMixer;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.URLRequest;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import ua.ska4ek.Settings;

public class MP3Track extends EventDispatcher implements IPlayer{

    private var netConn:NetConnection=new NetConnection();
    private var netStrm:NetStream;
    private var urlStr:String;
    private var _trackLength:Number = 1;
    private var intervalId:uint;
    private var _isPreloaded:Boolean = false;
    private var _played:Boolean = false;
    private var _playing:Boolean = false;


    private var sndLoaderContext:SoundLoaderContext = new SoundLoaderContext(1000);
    var sndChannel:SoundChannel;
    var sound:Sound;
    private var snd_position:Number;

    public function MP3Track(url:String) {

        trace("\t\t new MP3 track =  " + url);

        urlStr=url;
        if(urlStr.indexOf("?") > -1){
            urlStr += "&random="+ (new Date().getTime() + Math.random()* 100);
        } else {
            urlStr += "?random="+ (new Date().getTime() + Math.random()* 100);
        }

        sndChannel = new SoundChannel();

        var sreq:URLRequest = new URLRequest(urlStr);

        sound = new Sound();
        sound.addEventListener(Event.COMPLETE, handleSoundLoaded, false, 0, true);
        sound.addEventListener( IOErrorEvent.IO_ERROR, handleErrorLoadingSound, false, 0, true);
        sound.addEventListener( SecurityErrorEvent.SECURITY_ERROR, handleErrorLoadingSound, false, 0, true);
        sound.load(sreq, sndLoaderContext);



    }

    private function handleSoundLoaded(event:Event):void {

        trace("handleSoundLoaded")

        sound.removeEventListener(Event.COMPLETE, handleSoundLoaded);

        _trackLength = (event.target as Sound).length;

        _isPreloaded = true;
        dispatchEvent(new CustomPlayerEvent(CustomPlayerEvent.PRELOADED));
    }



    private function handleErrorLoadingSound(e:*):void {
        sound.removeEventListener(Event.COMPLETE, handleSoundLoaded);
        sound.removeEventListener( IOErrorEvent.IO_ERROR, handleErrorLoadingSound);
        sound.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, handleErrorLoadingSound);

        trace("** ERROR: " + e.text);

        dispatchEvent(new CustomPlayerEvent(CustomPlayerEvent.PLAYER_ERROR, e));
    }


    private function handlePlayingSoundCompleted(event:Event):void {

        trace("SOUND COMPLETE: ");
        trace("\t sndChannel: "  + sndChannel);
        trace("\t sound: " + sound);

        if(sndChannel!=null){
            sndChannel.removeEventListener(Event.SOUND_COMPLETE, handlePlayingSoundCompleted);
        }

        if(sound!=null){
            sound.removeEventListener( IOErrorEvent.IO_ERROR, handleErrorLoadingSound);
            sound.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, handleErrorLoadingSound);
        }

        _played = true;
        dispatchEvent(new CustomPlayerEvent(CustomPlayerEvent.PLAYING_COMPLETED));
    }



    private function enterFrameHandler():void {
        if(!_isPreloaded)
            dispatchEvent(new CustomPlayerEvent(CustomPlayerEvent.LOADING_PROGRESS));
        else if(_playing)
            dispatchEvent(new CustomPlayerEvent(CustomPlayerEvent.PLAYING));
    }



    public function play():void {
        if(snd_position > 0){
            sndChannel = sound.play(snd_position);
        } else {
            sndChannel = sound.play();
        }
        if(!sndChannel.hasEventListener(Event.SOUND_COMPLETE)){
            sndChannel.addEventListener(Event.SOUND_COMPLETE, handlePlayingSoundCompleted, false, 0, true);
        }
        _playing = true;
        if(!intervalId)intervalId = setInterval(enterFrameHandler, 100);
    }


    public function pause():void {
        snd_position = sndChannel.position;
        sndChannel.stop();

        _playing = false;
        if(intervalId){
            clearInterval(intervalId);
            intervalId = null;
        }
    }

    public function get time():String{return Settings.timeToString(sndChannel.position/1000, false);}
    public function get isPreloaded():Boolean{return _isPreloaded;}
    public function get played():Boolean{return _played;}

    public function kill():void {
        _played = true;
        _isPreloaded = true;
        _playing = false;


        if(intervalId){
            clearInterval(intervalId);
            intervalId = null;
        }

        if(sound!=null){
            sound.removeEventListener(Event.COMPLETE, handleSoundLoaded);
        }
        if(sndChannel!=null){
            sndChannel.removeEventListener(Event.SOUND_COMPLETE, handlePlayingSoundCompleted);
        }


        if(sndChannel!=null){
            sndChannel.stop();
        }
//        if (sound.bytesLoaded < sound.bytesTotal)
//        {
//            try{
//                sound.close();
//            }catch(err:Error){}
//        }
        SoundMixer.stopAll();

        sndChannel = null;
        sound = null;


    }



    override public function addEventListener(event_type:String, listener:Function, usecapture:Boolean = false, priority:int = 0, weakReference:Boolean = false):void{
        super.addEventListener(event_type, listener, usecapture, priority, weakReference);
    }

    override public function removeEventListener(event_type:String,listener:Function,useCapture:Boolean = false):void{
        super.removeEventListener(event_type, listener, useCapture);
    }






}
}
