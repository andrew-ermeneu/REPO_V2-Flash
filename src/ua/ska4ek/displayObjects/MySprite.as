/**
 * Created by ska4ek.
 */
package ua.ska4ek.displayObjects {
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;

public class MySprite extends Sprite implements DisplayInterface{
    private var _handlers:Array;
    public function MySprite() {
        super();
    }

    override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, WeakReference:Boolean = false):void{
        if (!_handlers) _handlers = [];
        _handlers.push({type:type,listener:listener});
        super.addEventListener(type,listener,useCapture,priority,WeakReference);
    }

    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
        if (_handlers) _handlers.splice(_handlers.indexOf({type:type,listener:listener}), 1);
        super.removeEventListener(type, listener, useCapture);
    }

    public function removeFromParent(dispose:Boolean = false):void {
        if (parent) parent.removeChild(this);
        if (dispose) this.dispose(this);
    }

    public function dispose(obj:Object):void {
        if(obj == this) {
//            stopAllMovieClips();
            killAllHandlers();
            graphics.clear();
        }

        if(!obj is DisplayObjectContainer)return;

        while(obj.numChildren != 0){
            var dObj:Object = obj.getChildAt(0) as Object;

            if (dObj is MySprite || dObj is MyMovieClip) {
                dObj.removeFromParent(true);
            }else if (dObj is Sprite || dObj is MovieClip) {
                dObj.graphics.clear();
                obj.removeChild(dObj as DisplayObject);
            }else if(dObj is Bitmap && (dObj as Bitmap).bitmapData) {
                (dObj as Bitmap).bitmapData.dispose();
                obj.removeChild(dObj as DisplayObject);
            }else if(dObj is Shape){
                (dObj as Shape).graphics.clear();
                obj.removeChild(dObj as Shape);
            }else{
                obj.removeChild(dObj as DisplayObject);
            }
			
			if(obj.contains(dObj)){
				trace("dObj : " + dObj);
				obj.removeChild(dObj);
			}
			
            dObj = null;
        }
    }

    private function killAllHandlers():void{
        if(_handlers)
            for each(var _handler:Object in _handlers)
                super.removeEventListener(_handler.type, _handler.listener);
        _handlers = null;
    }

    public function show():void {
    }

    public function hide():void {
    }
}
}
