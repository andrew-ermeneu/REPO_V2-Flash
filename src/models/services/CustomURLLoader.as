/**
 * Created by zip on 6/8/14.
 */
package models.services {

import com.adobe.serialization.json.JSON;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import models.RequestVO;


public class CustomURLLoader extends URLLoader {

    public var request_vo:RequestVO;

    public function CustomURLLoader() {
        super(null);
    }



    public function makeRequest(request_vo:RequestVO):void {
        this.request_vo = request_vo;

        if(this.request_vo.url.indexOf("?") > -1){
            this.request_vo.url += "&random="+ (new Date().getTime() + Math.random()* 100);
        } else {
            this.request_vo.url += "?random="+ (new Date().getTime() + Math.random()* 100);
        }

        this.request_vo.url += "&frm=flash"

        var request:URLRequest = new URLRequest(request_vo.url);
        request.contentType = 'application/json';
        request.requestHeaders.push(new URLRequestHeader("pragma", "no-cache"));
        request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/json"));
        request.requestHeaders.push(new URLRequestHeader("Accept", "application/json"));

        request.method = request_vo.method;

        if(request_vo.object!=null){
//            request.data = JSON.encode(request_vo.object);
            request.data = JSON.stringify(request_vo.object);
        }
        super.load(request);



    }




}
}
