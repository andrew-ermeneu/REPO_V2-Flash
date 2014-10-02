/**
 * Created by zip on 22/9/14.
 */
package models.services {

import events.CustomPlayerEvent;
import flash.display.Sprite;
import flash.net.URLRequestMethod;
import models.ModelMain;
import models.RequestVO;
import org.osflash.signals.Signal;




public class Track extends Sprite{

    public var signal_preloaded:Signal = new Signal(Track);
    public var signal_loading_error:Signal = new Signal(Track);
    public var signal_played:Signal = new Signal(Track);

    private var modelInst:ModelMain;
    private var service_api:ServiceAPI;

    private var id:String;

    public var isMp3:Boolean;
    public var meta_id:String;
    public var meta_song_name:String;
    public var meta_artist:String;
    public var meta_album_img_src:String;

    public var isPreloaded:Boolean = false;

    private var player:IPlayer;



    public function Track() {

        id = new Date().getTime() + "_" + Math.random();
        trace("\n \t ** add new Track: " + id);

        modelInst = ModelMain.getInstance();

        service_api = new ServiceAPI();
        service_api.addEventListener(CustomPlayerEvent.INIT_DATA_ERROR, handleApiRequestError);
        service_api.addEventListener(CustomPlayerEvent.INIT_DATA_GOT_SUCCESS, handleApiRequestSuccess);

        getTrackJson();
    }



    private function getTrackJson():void {

        trace("\t\t ******* getTrackJson, service_api.api_url = " + ServiceAPI.api_url);

        var request:RequestVO = new RequestVO();
        request.id = id;
        request.method = URLRequestMethod.GET;
        request.url = ServiceAPI.api_url + RequestVO.REQUEST_GET_MEDIA + "?token=" + modelInst.token;
        request.type = RequestVO.REQUEST_GET_MEDIA;
        service_api.makeRequest(request);
    }





    private function handleApiRequestError(event:CustomPlayerEvent):void {
        trace("** ERRROR: handleApiRequestError: " + (event.body as RequestVO).error_msg);
        service_api.removeEventListener(CustomPlayerEvent.INIT_DATA_ERROR, handleApiRequestError);
        service_api.removeEventListener(CustomPlayerEvent.INIT_DATA_GOT_SUCCESS, handleApiRequestSuccess);

//        setTimeout(getTrackJson, Config.REQUEST_RETRY_TIMEOUT);

        signal_loading_error.dispatch(this);
    }




    private function handleApiRequestSuccess(event:CustomPlayerEvent):void {


        service_api.removeEventListener(CustomPlayerEvent.INIT_DATA_ERROR, handleApiRequestError);
        service_api.removeEventListener(CustomPlayerEvent.INIT_DATA_GOT_SUCCESS, handleApiRequestSuccess);

        var request_vo:RequestVO = event.body as RequestVO;

        trace("Track handleApiRequestSuccess, ( "+id+" == "+request_vo.id+")");



        if ((event.body as RequestVO).type == RequestVO.REQUEST_GET_MEDIA  && id == request_vo.id) {

            var response_obj:Object = request_vo.response_obj;
            trace("response_obj: " + response_obj);

            if (response_obj.song != null && response_obj.song.uri != null) {

                var img_src:String = (response_obj.album.thumb_url == "" || response_obj.album.thumb_url == "null") ? "" : response_obj.album.thumb_url + "?token=" + modelInst.token;
                if (img_src.indexOf("?") > -1) {
                    img_src += "&random=" + (new Date().getTime() + Math.random() * 100);
                } else {
                    img_src += "?random=" + (new Date().getTime() + Math.random() * 100);
                }

                isMp3 = false;
                meta_id = response_obj.song.mediaid;
                meta_song_name = response_obj.song.name;
                meta_artist = response_obj.artist.name;
                meta_album_img_src = img_src;

                var audio_url:String = response_obj.song.uri.mp4 + "?token=" + modelInst.token;
                player = new MP4Track(audio_url);
                player.addEventListener(CustomPlayerEvent.PRELOADED, handlePreloaded);
                player.addEventListener(CustomPlayerEvent.PLAYER_ERROR, handlePlayerError);


            } else if (response_obj.message != null && response_obj.message.uri != null) {

                isMp3 = true;
                meta_id = null;
                meta_song_name = response_obj.message.message_name;
                meta_artist = null;
                meta_album_img_src = null;


                var audio_url:String = response_obj.message.uri.mp3 + "?token=" + modelInst.token;
                player = new MP3Track(audio_url);
                player.addEventListener(CustomPlayerEvent.PLAYER_ERROR, handlePlayerError);
                player.addEventListener(CustomPlayerEvent.PRELOADED, handlePreloaded);
                player.addEventListener(CustomPlayerEvent.PLAYING_COMPLETED, handlePlayed);

            } else {
                trace("** ERRROR: response error:  " + response_obj.meta.error);

//                setTimeout(getTrackJson, Config.REQUEST_RETRY_TIMEOUT);

                signal_loading_error.dispatch(this);
            }
        }

    }




    private function handlePlayerError(event:CustomPlayerEvent):void {
        trace("** ERRROR: handlePlayerError error:  " + event.body);
//        setTimeout(getTrackJson, Config.REQUEST_RETRY_TIMEOUT);
        signal_loading_error.dispatch(this);
    }




    private function handlePreloaded(event:CustomPlayerEvent):void {

        trace("\t Track handlePreloaded");

        isPreloaded = true;

        signal_preloaded.dispatch(this);

        player.removeEventListener(CustomPlayerEvent.PRELOADED, handlePreloaded);
        player.removeEventListener(CustomPlayerEvent.PLAYER_ERROR, handlePlayerError);

    }




    public function play():void {
        trace("\t Track play, isPreloaded("+isPreloaded+") player = " + player);
        if(player != null ){
            player.play();
        }
    }
    public function pause():void {
        trace("\t Track pause,  isPreloaded("+isPreloaded+") player = " + player);
        if(player != null ){
            player.pause();
        }
    }



    private function handlePlayed(event:CustomPlayerEvent):void {
        trace("\t Track handlePlayed");

        signal_played.dispatch(this);
    }


    public function kill():void{

        trace("\t Track kill");
        isPreloaded = false;

        service_api.removeEventListener(CustomPlayerEvent.INIT_DATA_ERROR, handleApiRequestError);
        service_api.removeEventListener(CustomPlayerEvent.INIT_DATA_GOT_SUCCESS, handleApiRequestSuccess);

        signal_loading_error.removeAll();
        signal_played.removeAll();
        signal_preloaded.removeAll();

        if(player != null ){
            player.removeEventListener(CustomPlayerEvent.PRELOADED, handlePreloaded);
            player.removeEventListener(CustomPlayerEvent.PLAYER_ERROR, handlePlayerError);
            player.removeEventListener(CustomPlayerEvent.PLAYING_COMPLETED, handlePlayed);

//        track.removeEventListener(MP4Player.LOADING_PROGRESS, loadingProgressHandler);
//        track.removeEventListener(PlayerEvents.TRACK_PLAYING, trackPlayingHandler);
            player.kill();
        }
        player = null;
    }




}
}
