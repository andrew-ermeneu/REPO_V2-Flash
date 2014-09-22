﻿package ua.ska4ek{import com.adobe.serialization.json.JSON;import flash.events.Event;import flash.events.IOErrorEvent;import flash.net.URLLoader;import flash.net.URLRequest;import flash.net.URLRequestMethod;import flash.net.URLVariables;	public class ServerManager	{				private static var _listeners	: Object = {};		private static var _date        : Date = new Date();		public function ServerManager() : void		{		}        public static function analytics(url : String) : void {            var request:URLRequest = new URLRequest( url );            request.method = URLRequestMethod.GET;            var _loader : URLLoader = new URLLoader( );            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);            _loader.load( request );        }        public static function savePoints(points : Number, listener : Function = null) : void {            _listeners.savePoints = listener;            var request:URLRequest = new URLRequest(Settings.SERVER);            request.method = URLRequestMethod.POST;            var variables : URLVariables = new URLVariables();            variables['score'] = points;            variables['hashcode'] = Settings.HASHCODE;            request.data = variables;            var _loader : URLLoader = new URLLoader( );            _loader.addEventListener( Event.COMPLETE, savePointsHandler );            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);            _loader.load( request );        }        protected static function savePointsHandler(event : Event) : void {            trace("savePoints : " + String(event.target.data));            if(String(event.target.data) != ""){                if(_listeners.savePoints)_listeners.savePoints(JSON.parse(String(event.target.data)));            }else{                trace("SERVER_ERROR");            }        }				private static function ioErrorHandler(event:IOErrorEvent):void		{            if(_listeners.firstRequest){                _listeners.firstRequest();                _listeners.firstRequest = null;            }            Settings.handleTrace("ioErrorHandler: " + event);		}    }}