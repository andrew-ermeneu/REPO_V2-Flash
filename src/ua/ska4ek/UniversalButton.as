/**
 * Created by ska4ek.
 */
package ua.ska4ek {
	
import com.greensock.TweenMax;
import com.greensock.easing.*;

import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TouchEvent;


import ua.ska4ek.displayObjects.MyMovieClip;
import ua.ska4ek.events.StageEvent;

//ua.ska4ek.UniversalButton
	public class UniversalButton extends MyMovieClip
	{
        public static const	TYPE_ANIMATED	: String = "type_animated";
        public static const	TYPE_SIMPLE		: String = "type_simple";

        public static const	BUTTON_RELAY	: String = "button_relay";
        public static const	BUTTON_CLICK	: String = "button_click";

        public static const VIEW_LIGHT		: String = "view_light";
        public static const VIEW_GLOW		: String = "view_glow";
        public static const VIEW_COLOR		: String = "view_color";
        public static const VIEW_ALPHA		: String = "view_alpha";


        private var area_mc			: MovieClip;
        private var _over_mc		: Sprite;
        private var _out_mc			: Sprite;

        private var disabled		: Boolean = true;
        private var off_mode		: Boolean = true;

        private var name_id			: String = BUTTON_CLICK;
        private var cur_label		: String;

        private var animation_type	: String = TYPE_SIMPLE;
        private var button_type		: String = BUTTON_CLICK;
        private var animation_view	: String = VIEW_COLOR;

        private var over_color		: int = 0x8ac544;

        private var easing_over		: Linear = Linear.easeIn;//Linear.easeIn;
        private var easing_out		: Linear = Linear.easeOut;//Linear.easeOut;

        private var overed			: Boolean = false;
		public function UniversalButton() : void {
            for(var i : int = 0; i < this.numChildren; i++){
                if(this.getChildAt(i) is DisplayObjectContainer){
                    var obj : DisplayObjectContainer = this.getChildAt(i) as DisplayObjectContainer;
                    obj.mouseChildren = false;
                    obj.mouseEnabled = false;
                }
            }


            if(this.getChildByName("over_MC") ){//&& this.getChildByName("out_MC") || this.getChildByName("over_MC") && this.getChildByName("normal_MC")){
                animation_view = VIEW_ALPHA;
                _over_mc = this.getChildByName("over_MC") as Sprite;
                _over_mc.alpha = 0;
                _out_mc = (this.getChildByName("out_MC")) ? this.getChildByName("out_MC") as Sprite : this.getChildByName("normal_MC") as Sprite;
            }


            if(this.getChildByName("area_MC")){
                area_mc	= this.getChildByName("area_MC") as MovieClip;
            }else{
                mouseChildren = false;
                area_mc = this;
            }

            if(!_over_mc)_over_mc = area_mc;


            if(this.framesLoaded >= 3){
                animation_type = TYPE_ANIMATED;
            }

            area_mc.mouseChildren = false;
            area_mc.mouseEnabled = true;

            if(framesLoaded > 1)gotoAndStop(1);

            init();
		}


        public function init() : void {
            initListeners();
        }



        public function set easingOver(value : Linear) : void {
            easing_over = value;
        }

        public function set easingOut(value : Linear) : void {
            easing_out = value;
        }


        public function set id(value : String) : void {
            name_id = value;
        }

        public function get id() : String {
            return name_id;
        }


        public function set label(value : String) : void {
            cur_label = value;
        }

        public function get label() : String {
            return cur_label;
        }


        public function set animationType(value : String) : void {
            animation_type = value;
        }

        public function get animationType() : String {
            return animation_type;
        }



        public function set buttonType(value : String) : void {
            button_type = value;
            if(value == BUTTON_RELAY){
                area_mc.removeEventListener(TouchEvent.TOUCH_BEGIN, handleMouseOver);
                area_mc.removeEventListener(TouchEvent.TOUCH_OVER, handleMouseOver);
                area_mc.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseOver);
                area_mc.removeEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
                area_mc.removeEventListener(TouchEvent.TOUCH_END, handleMouseOut);
                area_mc.removeEventListener(TouchEvent.TOUCH_ROLL_OUT, handleMouseOut);
                area_mc.removeEventListener(MouseEvent.MOUSE_UP, handleMouseOut);
                area_mc.removeEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
            }else{
                area_mc.addEventListener(TouchEvent.TOUCH_BEGIN, handleMouseOver);
                area_mc.addEventListener(TouchEvent.TOUCH_OVER, handleMouseOver);
                area_mc.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseOver);
                area_mc.addEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
                area_mc.addEventListener(TouchEvent.TOUCH_END, handleMouseOut);
                area_mc.addEventListener(TouchEvent.TOUCH_ROLL_OUT, handleMouseOut);
                area_mc.addEventListener(MouseEvent.MOUSE_UP, handleMouseOut);
                area_mc.addEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
            }
        }

        public function get buttonType() : String {
            return button_type;
        }



        public function set viewType(value : String) : void {
            animation_view = value;
        }

        public function get viewType() : String {
            return animation_view;
        }



        public function set colorOver(value : int) : void {
            over_color = value;
        }

        public function get colorOver() : int {
            return over_color;
        }




        public function get off() : Boolean {
            return off_mode;
        }

        public function set off(value : Boolean) : void {
            if(button_type == BUTTON_RELAY){
                off_mode = value;
                if(!overed || value)
                    handleMouseOut();
                else
                    handleMouseOver();
            }else{
                disabled = value;

            }
        }
		
		
		private function initListeners() : void {
            disabled = false;
            area_mc.buttonMode = true;
            if(buttonType != BUTTON_RELAY){
                area_mc.addEventListener(TouchEvent.TOUCH_BEGIN, handleMouseOver);
                area_mc.addEventListener(TouchEvent.TOUCH_OVER, handleMouseOver);
                area_mc.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseOver);
                area_mc.addEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
                area_mc.addEventListener(TouchEvent.TOUCH_END, handleMouseOut);
                area_mc.addEventListener(TouchEvent.TOUCH_ROLL_OUT, handleMouseOut);
                area_mc.addEventListener(MouseEvent.MOUSE_UP, handleMouseOut);
                area_mc.addEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
            }
            area_mc.addEventListener(MouseEvent.CLICK, handleMouseClick);
            area_mc.addEventListener(TouchEvent.TOUCH_TAP, handleMouseClick);
			//TweenMax.to(this, .2, {alpha:1});
//			handleMouseOut();
		}
		
			
		
		private function removeListeners() : void {
            disabled = true;
            area_mc.buttonMode = false;
            if(buttonType != BUTTON_RELAY){
                area_mc.removeEventListener(TouchEvent.TOUCH_BEGIN, handleMouseOver);
                area_mc.removeEventListener(TouchEvent.TOUCH_OVER, handleMouseOver);
                area_mc.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseOver);
                area_mc.removeEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
                area_mc.removeEventListener(TouchEvent.TOUCH_END, handleMouseOut);
                area_mc.removeEventListener(TouchEvent.TOUCH_ROLL_OUT, handleMouseOut);
                area_mc.removeEventListener(MouseEvent.MOUSE_UP, handleMouseOut);
                area_mc.removeEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
            }
            area_mc.removeEventListener(MouseEvent.CLICK, handleMouseClick);
            area_mc.removeEventListener(TouchEvent.TOUCH_TAP, handleMouseClick);
			//TweenMax.to(this, .2, {alpha:.5});
//			handleMouseOver();
		}


        protected function handleMouseClick(event:*):void
        {
            if(name_id) dispatchEvent(new StageEvent(name_id, this));
            if(button_type == BUTTON_RELAY) off = (off) ? false : true;
            //handleMouseOut();
        }


        private function handleMouseOver(event : * = null) : void {
            if(!disabled){
                overed = true;
                if((button_type == BUTTON_RELAY && off_mode) || button_type != BUTTON_RELAY){
                    over();
                }else{
                    out();
                }
            }
        }

        private function handleMouseOut(event : * = null) : void {
            if(!disabled){
                overed = false;
                if((button_type == BUTTON_RELAY && off_mode) || button_type != BUTTON_RELAY){
                    out();
                }else{
                    over();
                }
            }
        }


        public function over() : void {
            if(animationType == TYPE_ANIMATED){
                TweenMax.to(this, (this.framesLoaded - this.currentFrame) * .0225, {ease:Linear.easeNone, frame:this.framesLoaded});
            }else{
                if(animation_view == VIEW_GLOW){
                    TweenMax.to(this, .3, {ease:easing_out, glowFilter:{color:over_color, alpha:1, blurX:10, blurY:10, quality:3}});
                }else if(animation_view == VIEW_LIGHT){
                    TweenMax.to(this, .3, {ease:easing_over, colorTransform:{exposure:1.15}});
                }else if(animation_view == VIEW_ALPHA){
                    TweenMax.to(_over_mc, .3, {ease:easing_over, alpha:1});
                    if(_out_mc)TweenMax.to(_out_mc, .3, {ease:easing_over, alpha:0});
                }else{
                    TweenMax.to(this, .3, {colorMatrixFilter:{colorize:over_color}});
//                    TweenMax.to(this, .3, {ease:easing_over, colorTransform:{tint:over_color, tintAmount:1}});
                }
            }
        }

        public function out() : void {
            if(animationType == TYPE_ANIMATED){
                TweenMax.to(this, this.currentFrame * .0225, {ease:Linear.easeNone, frame:1});
            }else{
                if(animation_view == VIEW_GLOW){
                    TweenMax.to(this, .3, {ease:easing_out, glowFilter:{color:over_color, alpha:1, blurX:0, blurY:0, quality:1, remove:true}});
                }else if(animation_view == VIEW_LIGHT){
                    TweenMax.to(this, .3, {ease:easing_out, colorTransform:{exposure:1}});
                }else if(animation_view == VIEW_ALPHA){
                    TweenMax.to(_over_mc, .3, {ease:easing_over, alpha:0});
                    if(_out_mc)TweenMax.to(_out_mc, .3, {ease:easing_over, alpha:1});
                }else{
                    TweenMax.to(this, .3, {colorMatrixFilter:{amount:0}});
//                    TweenMax.to(this, .3, {ease:easing_over, colorTransform:{tint:over_color, tintAmount:0}});
                }
            }
        }



        public function set disable(_set : Boolean) : void {
            if(!_set){
                initListeners();
                alpha = 1;
            } else{
                removeListeners();
                alpha = .5;
            }
        }

        public function get disable() : Boolean {
            return disabled;
        }


        public function remove() : void {
            removeListeners();
        }

        override public function dispose(obj:Object):void{
            remove();
            super.dispose(obj);
        }
		
	}
}
