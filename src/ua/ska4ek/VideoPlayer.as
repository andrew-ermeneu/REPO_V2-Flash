package ua.ska4ek
{
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import ua.ska4ek.events.StageEvent;

	public class VideoPlayer extends Video
	{
		public var _path		: String;
		public var _ns			: NetStream;
		private var _pctloaded	: Number;
		public var _clipLength	: Number = 1;
		private var _id			: String;
		
		
		public function VideoPlayer(path:String, uid:String, width:int, height:int)
		{
			if(path != null && path != ""){
				super(width, height);
				
				_clipLength = 0;
				_path = path;
				_id = uid;
				_ns = null;
				var nc:NetConnection = new NetConnection();
				nc.connect(null);
				
				_ns = new NetStream(nc);
				_ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				
				var meta:Object = new Object();
				meta.onMetaData = function(meta:Object)
				{
					trace("!!!!!");
					_clipLength = meta.duration;
				}
				
				_ns.client = meta;
				_ns.bufferTime = 10;
				this.attachNetStream(_ns);	
				
				//connect media, go to first frame
				_ns.play(_path);
				_ns.seek(0);
				_ns.pause();
			}
		}
		
		private function netStatusHandler(e:NetStatusEvent) : void {
			switch(e.info.code){
				case "NetConnection.Connect.Success":
					break;
					trace("connect media");
				case "NetStream.Play.StreamNotFound":
					trace("Unable to locate video: " + _path);
					break;
				case "NetStream.Buffer.Flush":
					//done, stop and reset controls
					//dispatchEvent(new Event("movieDone"));
					//dispatchEvent(new StageEvent(_id));
					trace("FLUSH");
					break;
			}
		}
		
		public function get id() : String {
			return _id;
		}
		
		public function resetMovie():void {
			_ns.seek(0);
		}
		
		public function play() : void {
			_ns.resume();
		}
		
		public function pause() : void {
			_ns.pause();
		}
		
		public function playMovie():void {
			_ns.play(_path);
		}
		
		public function killStream():void {
			_ns.close();
		}
		
		public function seekTo(pct:Number):void {
			var newPctPlayed:Number = pct * _clipLength;
			_ns.seek(newPctPlayed);
		}
		
		public function getPercentLoaded():Number {
			var _pctloaded:Number =  _ns.bytesLoaded / _ns.bytesTotal;
			//var _pctloaded:Number = _ns.bufferTime;//.bufferTime;
			return _pctloaded;
		}
		
		public function getPlayhead():Number {
			var pctPlayed:Number = _ns.time / _clipLength;
			return pctPlayed;
		}
	}
}