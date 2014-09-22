//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted you to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package com.franklincovey.remote.rest.impl.javascript
{
	import com.franklincovey.remote.rest.api.IRESTClient;
	import com.franklincovey.remote.rest.api.RESTEvent;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
import flash.display.LoaderInfo;
import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.utils.Dictionary;
	

	import org.robotlegs.oil.async.Promise;

	public class JavascriptRESTClient implements IRESTClient
	{
		private static var _singleton:JavascriptRESTClient;
        private static var _appName:String;

		public static function getInstance(appName:String):JavascriptRESTClient {
            JavascriptRESTClient._appName = appName;
            if(!_singleton) {
				_singleton = new JavascriptRESTClient(new JavascriptRESTClientSingletonToken);
			}

			return _singleton;
		}

		public function JavascriptRESTClient(singleton:JavascriptRESTClientSingletonToken)
		{
			initialize();
		}


		private var requestUIDMap:Dictionary = new Dictionary();
		private static var _initialized:Boolean = false;

		public function doGET(url:String, promise:Promise = null):Promise
		{			
			return doAction('GET', url);
		}

		public function doPOST(url:String, data:Object, promise:Promise = null):Promise
		{
			return doAction('POST', url, data, promise);
		}

		public function doPUT(url:String, data:Object, promise:Promise = null):Promise
		{
			return doAction('PUT', url, data, promise);
		}

		public function doDELETE(url:String, data:Object, promise:Promise = null):Promise
		{
			return doAction('DELETE', url, data, promise);
		}

		public function doAction(action:String, url:String, data:Object = null, promise:Promise = null):Promise
		{
			var request:XMLHTTPRequestWrapper = createRequest(promise);
			request.open(action, url, true);
			request.send();

			return request.promise;
		}

		public function createRequest(promise:Promise = null):XMLHTTPRequestWrapper {
			var request:XMLHTTPRequestWrapper = new XMLHTTPRequestWrapper(promise);
			requestUIDMap[request.uid] = request;

			return request;
		}

		public static function get initialized():Boolean {
			return JavascriptRESTClient._initialized;
		}

		private function initialize():void {

            trace("** JS: JavascriptRESTClient._initialized: " + JavascriptRESTClient._initialized )

			if(!JavascriptRESTClient._initialized) {


                trace("** JS:  JavascriptRESTClient._appName: " +  JavascriptRESTClient._appName )

				var javascript:String = "FCREST = {" +
					"	requests: [],																				\n" +
					"	requestsUID: [],																			\n" +
					"	applicationAPI : document.getElementById('" + JavascriptRESTClient._appName + "'),								\n" +
					"	getRequest: function() {																	\n" +
					"		var ref = null;		console.log('window.XMLHttpRequest: ' + window.XMLHttpRequest); console.log('window.ActiveXObject: ' + window.ActiveXObject);																	\n" +
					"		//if (window.XMLHttpRequest) {															\n" +
					"		//	ref = new XMLHttpRequest();															\n" +
					"		//} else if (window.ActiveXObject) {														\n" +
					"		//	ref = new ActiveXObject('MSXML2.XMLHTTP.3.0');										\n" +
					"		//}																						\n" +
					"																								\n" +  
					"																								\n" +  
					"		//ref.onreadystatechange	 = function(event) {											\n" +
					"		//	if (ref.readyState == 4) {															\n" +
					"		//		var uid = FCREST.requestsUID[ref];												\n" +
					"		//		var statusCode = ref.status;													\n" +
					"		//		var response = ref.responseText;												\n" +
					"		//		var readyState = ref.readyState;												\n" +
					"		//																						\n" +
					"		//		FCREST.applicationAPI.handleStateChange(uid, readyState, statusCode, response);	\n" +
					"		//	}																					\n" +
					"		//}																						\n" +
					"					return null;																			\n" +
					"		//return ref;																				\n" +
					"	}																							\n" +
					"																								\n" +
					"}";


                trace("** JS: javascript: " + javascript )
                Security.allowDomain("*");
                Security.allowInsecureDomain("*");

                if(ExternalInterface.available){
                    try {
                        ExternalInterface.call('eval', javascript);
                    } catch (error:Error){
                        trace("** JS: ERROR js1: " + error.message);
                    }


                    try {
                        ExternalInterface.addCallback("handleStateChange", handleStateChange);

                    } catch (error:Error){
                        trace("** JS: ERROR js2: " + error.message);
                    }
                } else {
                    trace("** JS: ERROR NOT ExternalInterface.available");
                }



				JavascriptRESTClient._initialized = true;
			}
		}

		private function handleStateChange(uid:String, readyState:uint, statusCode:uint, response:String):void {
            trace("** JS: handleStateChange uid: " + uid);
            trace("** JS: handleStateChange readyState: " + readyState);
            trace("** JS: handleStateChange statusCode: " + statusCode);
            trace("** JS: handleStateChange response: " + response);
            trace("** JS: handleStateChange requestUIDMap: " + requestUIDMap);


			var request:XMLHTTPRequestWrapper = requestUIDMap[uid] as XMLHTTPRequestWrapper;
            trace("** JS: handleStateChange request: " + request);

            var event:RESTEvent = new RESTEvent(RESTEvent.READY_STATE_CHANGED);
            trace("** JS: handleStateChange event: " + event);

			event.readyState = readyState;
			event.statusCode = statusCode;
			event.response = response;

			request.dispatchEvent(event);


			//Garbage Collect!
            request = null;
            requestUIDMap[uid] = null;

//			delete requestUIDMap[uid];
		}
	}
}

class JavascriptRESTClientSingletonToken {

}

