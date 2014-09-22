package ua.ska4ek
{
import com.greensock.TweenMax;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.ImageLoader;
import com.greensock.loading.LoaderMax;
import com.greensock.loading.display.ContentDisplay;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.DisplayObject;

import flash.events.Event;
import flash.events.IOErrorEvent;


import ua.ska4ek.displayObjects.MySprite;
import ua.ska4ek.events.StageEvent;

//ua.ska4ek.ImageContainer
	public class ImageContainer extends MySprite
	{
//		private var mask_mc		: DisplayObject;
		private var imgl		: ImageLoader;
		private var img_crop	: Boolean = true;
		private var offset_y	: Number = 0;
//        private var _imgH:Number = 0;
//        private var _imgW:Number = 0;
        private var _id:String;
        private var _images:Array;
        private var curImage:ContentDisplay;
        private var _curImageId:int;
        private var _queue:LoaderMax;
		

		public function ImageContainer(_w:Number = 0, _h:Number=0) : void {
//            mask_mc = getChildByName("mask_MC") as DisplayObject;
//			if(mask_mc){
//                _imgH = mask_mc.height;
//                _imgW = mask_mc.width;
//            }else{
//                _imgH = _h;
//                _imgW = _w;
//            }
		}


        public function set id(value : String): void { _id = value; }
        public function get id(): String { return _id; }

//		public function set crop(value : Boolean): void {img_crop = value;}
//        public function get crop(): Boolean {return img_crop;}

//        public function get contentWidth(): Number {return _imgW;}
//        public function get contentHeight(): Number {return _imgH;}

		public function set urls(value : Array): void {
            _queue = new LoaderMax({name:"mainQueue", onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler});
            _images = [];
            for(var i:int=0; i<value.length; i++) {
                _images.push("img"+i.toString());
//                _queue.append(new ImageLoader(Settings.SERVER+value[i], {name: _images[i], width: _imgW, height: _imgH, scaleMode: "proportionalOutside"}));
                _queue.append(new ImageLoader(Settings.SERVER+value[i], {name: _images[i]}));
            }
            _queue.unload();
            _queue.load();
		}


        private function progressHandler(event:LoaderEvent):void {
            trace("progress: " + event.target.progress);
        }

        private function completeHandler(event:LoaderEvent):void {
            _curImageId = 0;
            curImage = LoaderMax.getContent(_images[_curImageId]);
//            _imgH = curImage.height;
//            _imgW = curImage.width;
            curImage.alpha = 0;
            addChild(curImage);
            TweenMax.to(curImage, .5, {alpha: 1});

            if(_images.length > 1)TweenMax.delayedCall(1, changeToNext);

            dispatchEvent(new StageEvent(StageEvent.COMPLETE, this));
        }

        private function changeToNext():void {
            _curImageId = (_curImageId == _images.length - 1) ? 0 : _curImageId+1;
            var _image:ContentDisplay = LoaderMax.getContent(_images[_curImageId]);
            _image.alpha = 0;

//            if(mask_mc){
//                _image.y = mask_mc.y;
//                _image.x = mask_mc.x;
//
//                addChildAt(_image, getChildIndex(mask_mc));
//                _image.mask = mask_mc;
//            }else{
                addChild(_image);
//            }

            TweenMax.to(_image, 1, {alpha: 1, onComplete:function(img:ContentDisplay):void{
                if(img && contains(img)){
                    removeChild(img);
                }
            }, onCompleteParams:[curImage]});
            curImage = _image;
            TweenMax.delayedCall(1, changeToNext);
        }



		
		public function set url(value : String): void {
            remove();
            if(value == "" || value == "null")return;
//			imgl = new ImageLoader(value, {width:_imgW, height:_imgH, smoothing:true, crop:img_crop, scaleMode:"proportionalOutside", onComplete:handleLoaded});
			imgl = new ImageLoader(value, {smoothing:true, onComplete:handleLoaded});
			imgl.load();
		}

        public function get urlContent():ContentDisplay{return (imgl) ? imgl.content : null};

		private function handleLoaded(event : Event = null) : void {
            trace("img WxH = " + imgl.content.width + "x" + imgl.content.height);
            imgl.content.alpha = 0;
//			if(mask_mc) {
//                imgl.content.y = mask_mc.y;
//                imgl.content.x = mask_mc.x;
//                addChildAt(imgl.content, getChildIndex(mask_mc));
//                imgl.content.mask = mask_mc;
//            }else{
                addChild(imgl.content);
//            }
            TweenMax.to(imgl.content, .5, {alpha:1});
//            if(!_imgH && !_imgW) {
//                _imgH = imgl.content.height;
//                _imgW = imgl.content.width;
//            }
			
			dispatchEvent(new StageEvent(StageEvent.COMPLETE, this));
		}



//        public function get bitmap():Bitmap{
//            var _bmd:BitmapData = new BitmapData(_imgW, _imgH, true, 0x00000000);
//            _bmd.draw(imgl.content);
//            return new Bitmap(_bmd);
//        }



        public function remove() : void {
            if(imgl){
                if(imgl.content){
                    TweenMax.killTweensOf(imgl.content);
                    imgl.content.mask = null;
                    if(contains(imgl.content))removeChild(imgl.content);
                }
                imgl.cancel();
                imgl.unload();
                imgl = null;
            }
            if(_queue){
                if(curImage){
                    TweenMax.killTweensOf(curImage);
                    curImage.mask = null;
                    if(contains(curImage))removeChild(curImage);
                }
                _queue.cancel();
                _queue.unload();
                _queue = null;
            }
        }

        override public function dispose(obj : Object):void{
            remove();
            super.dispose(obj);
        }


		
		protected function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
		}

        protected function errorHandler(event:LoaderEvent):void {
            trace("error occured with " + event.target + ": " + event.text);
        }
	}
}