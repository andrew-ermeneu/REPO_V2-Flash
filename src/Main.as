/**
 * Created by zip on 3/10/14.
 */
package {
import com.adobe.serialization.json.JSON;
import com.greensock.loading.ImageLoader;

import events.CustomPlayerEvent;

import flash.display.SimpleButton;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.net.URLRequestMethod;
import flash.system.Security;
import flash.text.TextField;

import models.Config;
import models.ModelMain;
import models.RequestVO;
import models.services.ServiceAPI;
import models.services.Track;




public class Main extends Sprite {

    private const NUM_TRACKS_IN_CACHE: uint = 3;


    private var tracks_pool:Array = [];
    private var modelInst:ModelMain;
    private var service_api:ServiceAPI;
    private var jsFunc:String;
    private var isPlayerActive:String;

    private var playBtn: SimpleButton;
    private var pauseBtn: SimpleButton;
    private var nextBtn: SimpleButton;
    private var removeBtn: SimpleButton;
    private var controlsMc: Sprite;
    private var bufferWheelMc: Sprite;
    private var detailsMc: Sprite;
    private var titleCnt: Sprite;
    private var songNameTxt: TextField;
    private var artistNameTxt: TextField;
    private var albumViewerMc: Sprite;
    private var imgl: ImageLoader;

    private var remove_song_controls: Sprite;
    private var remove_btn_wrong: Sprite;
    private var remove_btn_dislike: Sprite;
    private var remove_btn_cancel: Sprite;
    private var remove_btn_inappropriate: Sprite;



    private var isPaused:Boolean = false;




    public function Main() {


        initAll();

    }




    private function initAll():void {

        var title: String = "\n\n ************************ " + Config.name + " " + Config.version + " ************************ \n\n";
        trace(title);

        var flashvars:Object = loaderInfo.parameters;
        for (var key:String in flashvars) {
            trace("\t * flashvars[" + key + "] = " + flashvars[key]);
        }


        Security.allowDomain('*');
        Security.allowInsecureDomain('*');


        modelInst = ModelMain.getInstance();

        service_api = new ServiceAPI();
        service_api.addEventListener(CustomPlayerEvent.INIT_DATA_ERROR, handleApiRequestError);
        service_api.addEventListener(CustomPlayerEvent.INIT_DATA_GOT_SUCCESS, handleApiRequestSuccess);



        initDisplayObjects();


        if (loaderInfo.parameters["jsFunc"] != null && loaderInfo.parameters["jsFunc"] != "") {
            jsFunc = loaderInfo.parameters["jsFunc"];
        } else {
            jsFunc = Config.DEFAULT_JS_FUNC;
        }


        ServiceAPI.api_url = Config.DEFAULT_API_URL2;
        if (loaderInfo.parameters["api_url"] != null && loaderInfo.parameters["api_url"] != "") {
            ServiceAPI.api_url = loaderInfo.parameters["api_url"];
        }
        trace("ServiceAPI.api_url = " + ServiceAPI.api_url);


        if (loaderInfo.parameters["isActivate"] != null && loaderInfo.parameters["isActivate"] != "") {
            isPlayerActive = loaderInfo.parameters["isActivate"];
        }


        if (loaderInfo.parameters["token"] != null && loaderInfo.parameters["token"] != "") {

            modelInst.token = loaderInfo.parameters["token"];
            handleTokenReceived();

        } else {


            if (loaderInfo.parameters["username"] != null && loaderInfo.parameters["username"] != "") {
                modelInst.username = loaderInfo.parameters["username"];
            }
            if (loaderInfo.parameters["password"] != null && loaderInfo.parameters["password"] != "") {
                modelInst.password = loaderInfo.parameters["password"];
            }

            getToken();
        }

    }




    private function initDisplayObjects(): void {
        //        percentTxt = getChildByName("percent_TXT") as TextField;
        //        percentTxt.text = "loading 0%";

        remove_song_controls = this["remove_song_controls_mc"] as Sprite;
        remove_song_controls.visible = false;

        remove_btn_inappropriate = remove_song_controls["btn_inappropriate"] as Sprite;
        remove_btn_inappropriate.buttonMode = true;
        remove_btn_inappropriate.mouseChildren = false;
        remove_btn_inappropriate.addEventListener(MouseEvent.CLICK, handleRemoveButtonsClick);

        remove_btn_wrong = remove_song_controls["btn_wrong"] as Sprite;
        remove_btn_wrong.buttonMode = true;
        remove_btn_wrong.mouseChildren = false;
        remove_btn_wrong.addEventListener(MouseEvent.CLICK, handleRemoveButtonsClick);

        remove_btn_dislike = remove_song_controls["btn_dislike"] as Sprite;
        remove_btn_dislike.buttonMode = true;
        remove_btn_dislike.mouseChildren = false;
        remove_btn_dislike.addEventListener(MouseEvent.CLICK, handleRemoveButtonsClick);

        remove_btn_cancel = remove_song_controls["btn_cancel"] as Sprite;
        remove_btn_cancel.buttonMode = true;
        remove_btn_cancel.mouseChildren = false;
        remove_btn_cancel.addEventListener(MouseEvent.CLICK, handleRemoveButtonsClick);


        controlsMc = getChildByName("controls") as Sprite;
        //        timeViewTxt = controlsMc.getChildByName("timeView") as TextField;
        playBtn = controlsMc.getChildByName("playbtn") as SimpleButton;
        pauseBtn = controlsMc.getChildByName("pausebtn") as SimpleButton;
        nextBtn = controlsMc.getChildByName("next_button") as SimpleButton;
        removeBtn = controlsMc.getChildByName("remove") as SimpleButton;

        playBtn.visible = controlsMc.visible = false;
        controlsMc.visible = false;

        bufferWheelMc = getChildByName("bufferWheel") as Sprite;
        bufferWheelMc.visible = false;

        detailsMc = getChildByName("details") as Sprite;
        titleCnt = detailsMc.getChildByName("title_mc") as Sprite;
        songNameTxt = titleCnt.getChildByName("scrollbox") as TextField;
        artistNameTxt = titleCnt.getChildByName("songArtist") as TextField;
        albumViewerMc = detailsMc.getChildByName("albumViewer") as Sprite;

        imgl = new ImageLoader("", {
            smoothing: true,
            onComplete: handleImageLoaded
        });
        albumViewerMc.addChild(imgl.content);
        detailsMc.visible = false;

        pauseBtn.addEventListener(MouseEvent.CLICK, pauseClickHandler);
        playBtn.addEventListener(MouseEvent.CLICK, playClickHandler);
        nextBtn.addEventListener(MouseEvent.CLICK, nextClickHandler);

        removeBtn.addEventListener(MouseEvent.CLICK, removeClickHandler);


        bufferWheelMc.visible = true;
        detailsMc.visible = false;


    }




    /*********************************************************
     *
     *  WORKING WITH API
     *
     *********************************************************/
    private function getToken(): void {
        var cur_json_obj: Object = {};
        cur_json_obj.username = modelInst.username;
        cur_json_obj.password = modelInst.password;
        //        cur_json_obj.device_uuid = modelInst.device_udid;

        var request: RequestVO = new RequestVO();
        request.method = URLRequestMethod.POST;
        trace("\t\t ******* getToken, service_api.api_url = " + ServiceAPI.api_url);

        request.url = ServiceAPI.api_url + RequestVO.REQUEST_GET_TOKEN;
        request.type = RequestVO.REQUEST_GET_TOKEN;
        request.object = cur_json_obj;

        service_api.makeRequest(request);
    }



    private function registerDevice(): void {

        var cur_json_obj: Object = {};
        cur_json_obj.name = modelInst.device_name;
        cur_json_obj.description = modelInst.device_description;
        cur_json_obj.uuid = modelInst.device_udid;
        cur_json_obj.type = modelInst.device_type;

        var request: RequestVO = new RequestVO();
        request.method = URLRequestMethod.POST;
        request.url = ServiceAPI.api_url + RequestVO.REQUEST_REGISTER_DEVICE + "?token=" + modelInst.token;
        request.type = RequestVO.REQUEST_REGISTER_DEVICE;
        request.object = cur_json_obj;

        service_api.makeRequest(request);
    }



    private function activateDevice(): void {
        trace("\t\t ******* activateDevice, service_api.api_url = " + ServiceAPI.api_url);

        var request: RequestVO = new RequestVO();
        request.method = URLRequestMethod.PUT;
        request.url = ServiceAPI.api_url + RequestVO.REQUEST_ACTIVATE_DEVICE + "?token=" + modelInst.token;
        request.type = RequestVO.REQUEST_ACTIVATE_DEVICE;

        service_api.makeRequest(request);
    }



    private function getCommands(): void {

        trace("\t\t ******* getCommands, service_api.api_url = " + ServiceAPI.api_url);


        var request: RequestVO = new RequestVO();
        request.method = URLRequestMethod.GET;
        request.url = ServiceAPI.api_url + RequestVO.REQUEST_GET_COMMANDS + "?token=" + modelInst.token;
        request.type = RequestVO.REQUEST_GET_COMMANDS;
        service_api.makeRequest(request);
    }



    private function handleApiRequestError(event: CustomPlayerEvent): void {
        trace("Main: handleApiRequestError: " + (event.body as RequestVO).error_msg);
        //setTimeout(getToken, REQUEST_RETRY_TIMEOUT);
    }


    private function handleApiRequestSuccess(event: CustomPlayerEvent): void {

        trace("Main: handleApiRequestSuccess: " + (event.body as RequestVO).type + " = " + (event.body as RequestVO).response_obj);

        var request_type: String = (event.body as RequestVO).type;
        var request_response: String = JSON.stringify((event.body as RequestVO).response_obj);

        try {
            if (ExternalInterface.available) {
                ExternalInterface.call(jsFunc, request_type, request_response);
            } else {
                trace("Error: ExternalInterface is NOT available");
            }
        } catch (error: Error) {
            trace("Error ExternalInterface: " + error)
        }



        if ((event.body as RequestVO).type == RequestVO.REQUEST_GET_TOKEN) {
            //        if((event.body as RequestVO).response_obj.meta.code == "200")

            modelInst.token = (event.body as RequestVO).response_obj.token;
            modelInst.userid = (event.body as RequestVO).response_obj.userid;
            modelInst.custid = (event.body as RequestVO).response_obj.custid;

            handleTokenReceived()

        } else if ((event.body as RequestVO).type == RequestVO.REQUEST_REGISTER_DEVICE) {

            //            if((event.body as RequestVO).response_obj.meta.code == "200")
            getCommands();

        } else if ((event.body as RequestVO).type == RequestVO.REQUEST_GET_COMMANDS) {


            if ((event.body as RequestVO).response_obj.status == "inactive") {
                activateDevice();
            }


        } else if ((event.body as RequestVO).type == RequestVO.REQUEST_ACTIVATE_DEVICE) {

            playNext();

            //        } else if((event.body as RequestVO).type == RequestVO.REQUEST_REMOVE_SONG){
            //            getMedia();

        }
    }


    private function handleTokenReceived(): void {

        trace("Main handleTokenReceived = " + isPlayerActive);

        if (isPlayerActive == "1") {
            trace("isActivate == 1");

            playNext();

        } else {
            trace("isActivate == 0");
            activateDevice();
        }
    }






    /************************************************************************************
     *
     * IFACE PLAYER BTNS
     *
     ************************************************************************************/

    private function pauseClickHandler(event: MouseEvent): void {

        isPaused  = true;
        (tracks_pool[0] as Track).pause();

        playBtn.visible = true;
        pauseBtn.visible = false;
    }

    private function playClickHandler(event: MouseEvent): void {

        isPaused  = false;
        (tracks_pool[0] as Track).play();

        playBtn.visible = false;
        pauseBtn.visible = true;
    }


    private function nextClickHandler(event: MouseEvent): void {
        nextBtn.mouseEnabled = false;
        playNext();
    }


    private function removeClickHandler(event: MouseEvent): void {
        detailsMc.visible = false;
        controlsMc.visible = false;
        remove_song_controls.visible = true;
    }


    /************************************************************************************
     *
     * HANDLE TRACKS
     *
     ************************************************************************************/

    private function playNext(){

        trace("\t ** playNext");

        trace("\t\t tracks_pool: " + tracks_pool);


        //REMOVE THE 1ST ONE IF EXISTS
        if(tracks_pool.length > 0){

            var cur_track:Track = tracks_pool[0] as Track;
            trace("\t\t remove 1st one: " + cur_track);

            cur_track.signal_preloaded.removeAll();
            cur_track.signal_loading_error.removeAll();
            cur_track.signal_played.removeAll();
            cur_track.kill();
            tracks_pool.shift();
        }


        //FILL POOL IF NEEDED
        checkIfPoolIsFilled();



        //NEXT TRACK
        var next_track:Track = tracks_pool[0] as Track;

        trace("\t\t next_track: " + next_track);

        next_track.signal_played.addOnce(handleTrackPlayed);

        if( next_track.isPreloaded ){
            trace("\t\t\t next_track isPreloaded");

            playFirstTrack();

        } else {

            trace("\t\t\t next_track NOT isPreloaded");

            trace("\t\t bufferWheelMc: " + bufferWheelMc);
            trace("\t\t detailsMc: " + detailsMc);
            trace("\t\t controlsMc: " + controlsMc);

            bufferWheelMc.visible = true;
            detailsMc.visible = false;
            controlsMc.visible = false;


            next_track.signal_preloaded.addOnce(handleTrackPreloaded)
            next_track.signal_loading_error.addOnce(handleTrackError)
        }
    }




    private function checkIfPoolIsFilled():void {
        trace("\t checkIfPoolIsFilled before: " + tracks_pool.length);

        if(tracks_pool.length < NUM_TRACKS_IN_CACHE){

            var num_to_add:int = NUM_TRACKS_IN_CACHE - tracks_pool.length;
            trace("\t\t num_to_add: "+ num_to_add);

            for (var i:int = 0; i < num_to_add; i++) {
                var track:Track = new Track();
                trace("\t\t\t adding: " + track);
                track.signal_loading_error.addOnce(handleTrackError);
                tracks_pool.push(track);
            }
        }

        trace("\t checkIfPoolIsFilled after: " + tracks_pool.length);
    }



    private function handleTrackError(track: Track): void {
        trace("\t handleTrackError: "+ track.meta_song_name);

        if(track == tracks_pool[0]){

            trace("\t\t is 1st track "+ track.meta_song_name);
            playNext();

        } else {
            trace("\t\t NOT 1st track "+ track.meta_song_name);

            tracks_pool.splice(tracks_pool.indexOf(track), 1);
            track.kill();

            checkIfPoolIsFilled();
        }
    }

    private function handleTrackPlayed(track: Track): void {
        trace("\t handleTrackPlayed: "+ track.meta_song_name);
        playNext();
    }


    private function handleTrackPreloaded(track: Track): void {
        trace("\t handleTrackPreloaded: "+ track.meta_song_name);

        nextBtn.mouseEnabled = true;
        playFirstTrack();
    }




    private function playFirstTrack():void {

        nextBtn.mouseEnabled = true;

        var track: Track = tracks_pool[0] as Track;

        bufferWheelMc.visible = false;
        controlsMc.visible = false;
        detailsMc.visible = true;

        songNameTxt.text = track.meta_song_name;
        artistNameTxt.text = "";

        if (imgl != null) {
            imgl.unload();
        }

        if (!track.isMp3) {

            controlsMc.visible = true;
            albumViewerMc.visible = true;
            albumViewerMc.alpha = 1;

            artistNameTxt.text = track.meta_artist;

            imgl.url = track.meta_album_img_src;
            trace("img url  = " + imgl.url);
            imgl.load(false);

            //    //            TweenLite.to(albumViewerMc, 0.5, {alpha:1});
        }

        if(!isPaused){
            track.play();
        }
    }



    /*********************************************************
     *
     *  OTHER
     *
     *********************************************************/



    private function handleImageLoaded(event: Event = null): void {

        imgl.content.width = 190;
        imgl.content.height = 190;

        albumViewerMc.visible = true;
        trace("img WxH = " + imgl.content.width + "x" + imgl.content.height);
    }








    private function handleRemoveButtonsClick(event: MouseEvent): void {

        detailsMc.visible = true;
        controlsMc.visible = true;
        remove_song_controls.visible = false;


        if (event.target != remove_btn_cancel) {

            var cur_json_obj: Object = {};
            cur_json_obj.mediaid = (tracks_pool[0] as Track).meta_id;

            if (event.target == remove_btn_inappropriate) {
                cur_json_obj.reason = "BadLanguage";
            } else if (event.target == remove_btn_dislike) {
                cur_json_obj.reason = "DontLikeSong";
            } else if (event.target == remove_btn_wrong) {
                cur_json_obj.reason = "WrongPlaylist";
            }
            var request: RequestVO = new RequestVO();
            request.method = URLRequestMethod.POST;
            request.url = ServiceAPI.api_url + RequestVO.REQUEST_REMOVE_SONG + "?token=" + modelInst.token;
            request.type = RequestVO.REQUEST_REMOVE_SONG;
            request.object = cur_json_obj;
            service_api.makeRequest(request);

            playNext();

        }
    }
    //

}
}
