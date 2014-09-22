package ua.ska4ek {
	
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;

import ua.ska4ek.displayObjects.MySprite;


public class HorizontalScroller extends MySprite {
		
		private var scroll_mc		: DisplayObject;
		
		private var mask_rectangle	: Rectangle;
		
		
		private var dragger_mc		: Sprite;
		private var scroll_bg		: Sprite;
		
		private var top_mc			: Sprite;
		private var bottom_mc		: Sprite;
		
		private var drag_c_mc		: Sprite;
		private var drag_t_mc		: Sprite;
		private var drag_b_mc		: Sprite;
		private var drag_l_mc		: Sprite;
		
		
		private var disable			: Boolean = false;
		private var scroll_pressed	: Boolean;
		
		private var scroll_width	: Number;
		private var mask_width		: Number;
		private var mc_width		: Number;
		
		
		private var vwing 			: Number;
		private var xrate			: Number;
		private var targetx			: Number;
		private var oldscroll_w		: Number;
		private var olddragger_w	: Number;
		
		
		
		
		public function HorizontalScroller () : void {
			dragger_mc		= getChildByName("dragger_MC") as MovieClip;
			scroll_bg		= getChildByName("scroll_BG") as Sprite;
			
			top_mc			= getChildByName("top_MC") as Sprite;
			bottom_mc		= getChildByName("bottom_MC") as Sprite;
			
			drag_c_mc		= dragger_mc.getChildByName("center_MC") as Sprite;
			drag_t_mc		= dragger_mc.getChildByName("top_MC") as Sprite;
			drag_b_mc		= dragger_mc.getChildByName("bottom_MC") as Sprite;
			drag_l_mc		= dragger_mc.getChildByName("lines_MC") as Sprite;
			
			xrate			= 6;
			scroll_pressed	= false;
			
			scroll_bg.x = (top_mc) ? top_mc.x + top_mc.width : 0;
		}
		
		
		
		public function start() : void {
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		
		public function pause() : void {
			targetx			= 0;
			dragger_mc.x	= scroll_bg.x;
			mask_rectangle.x = 0;
			scroll_mc.scrollRect = mask_rectangle;
			removeEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public function goTop() : void {
			dragger_mc.x = scroll_bg.x;
			
			xrate = 1;
			onFrame();
			xrate = 6;
		}
		
		public function goBottom() : void {
			dragger_mc.x = scroll_bg.x + scroll_bg.width - dragger_mc.width;
			
			xrate = 1;
			onFrame();
			xrate = 6;
		}
		
		
		public function init(_movie : DisplayObject, _scroll_width : Number = 0, _mask_width : Number = 0, _mc_width : Number = 0) : void {
			scroll_mc			= _movie;
			scroll_width		= (_scroll_width == 0) ? width : _scroll_width;
			mask_width			= (_mask_width == 0) ? width : _mask_width;
			mc_width			= (_mc_width == 0) ? scroll_mc.width : _mc_width;
			
			
			
			scroll_bg.width	= oldscroll_w = scroll_width - ((top_mc && bottom_mc) ? top_mc.width - bottom_mc.width : 0);
			if(bottom_mc)bottom_mc.x	= scroll_bg.x + scroll_bg.width;
			dragger_mc.x 		= scroll_bg.x;
			
			
			vwing 				= mc_width - mask_width;
			targetx				= 0;
			
			
			
			mask_rectangle		= new Rectangle(0, 0, mask_width, y - scroll_mc.y);
			scroll_mc.scrollRect = mask_rectangle;
			
			resizeDragger();
			olddragger_w = dragger_mc.width;
			
			if(mc_width <= mask_width){
				disableScroller();
			}else{
				enableScroller();
			}
		}
		
		
		public function update(_scroll_width : Number = 0, _mask_width : Number = 0, _mc_width : Number = 0) : void {
			
			scroll_width		= (_scroll_width == 0) ? scroll_width : _scroll_width;
			mask_width			= (_mask_width == 0) ? mask_width : _mask_width;
			mc_width			= (_mc_width == 0) ? scroll_mc.height : _mc_width;
			
			scroll_bg.width	= scroll_width - ((top_mc && bottom_mc) ? top_mc.width - bottom_mc.width : 0);
			if(bottom_mc)bottom_mc.x	= scroll_bg.x + scroll_bg.width;
			
			
			//if(_mc_width != 0) mc_width			= _mc_width;
			vwing 				= mc_width - mask_width;
			
			
			mask_rectangle.height = y - scroll_mc.y;
			mask_rectangle.width = mask_width;
			scroll_mc.scrollRect = mask_rectangle;
			
			resizeDragger();
			updateDrager();
			
			
			if(mc_width <= mask_width){
				if(!disable) disableScroller();
			}else if(mc_width > mask_width){
				if(disable) enableScroller();
			}
			
		}
		
		
		
		
		
		public function killMovieClip() : void {
			pause();
			disableScroller();
			handleSrollUp();
			targetx			= 0;
			dragger_mc.x	= 0;
			
			mask_rectangle = null;
			scroll_mc.scrollRect = null;
		}
		
		
		
		
		private function resizeDragger() : void {
			if(drag_c_mc && drag_b_mc && drag_l_mc){
				drag_c_mc.width	= mask_width / mc_width * scroll_bg.width - drag_t_mc.width - drag_b_mc.width;
				if(drag_c_mc.width < 10)drag_c_mc.width = 10; else if(drag_c_mc.width + drag_t_mc.width + drag_b_mc.width >= scroll_bg.width) drag_c_mc.width = scroll_bg.width - drag_t_mc.width - drag_b_mc.width - 1;
				drag_b_mc.x = drag_c_mc.x + drag_c_mc.width;
				drag_l_mc.x = (drag_c_mc.width - drag_l_mc.width) * .5 + drag_c_mc.x;
			}
		}
		
		
		private function updateDrager(event:Event = null) : void {
			
			var _yD : Number = 100 / (oldscroll_w - olddragger_w) * (dragger_mc.x - scroll_bg.x);
			var _targetD : Number =  _yD / (100 / (scroll_bg.width - dragger_mc.width));
			dragger_mc.x = _targetD + scroll_bg.x;
			
			oldscroll_w = scroll_bg.width;
			olddragger_w = dragger_mc.width;
			
			xrate = 1;
			onFrame();
			xrate = 6;
		}
		
		
		
		
		
		
		
		
		private function onFrame(event:Event = null) : void {
			
			targetx = vwing / (scroll_bg.width - dragger_mc.width) * (dragger_mc.x - scroll_bg.x);
			
			
			mask_rectangle.x -= (mask_rectangle.x - targetx) / xrate;
			scroll_mc.scrollRect = mask_rectangle;
			
			
			if(!scroll_pressed && Math.round(targetx) == Math.round(mask_rectangle.x)){
				removeEventListener(Event.ENTER_FRAME, onFrame);
			}
		}
		
		
		
		
		
		private function enableScroller() : void {
			this.parent.addEventListener(MouseEvent.MOUSE_WHEEL, scrollHandler);
			dragger_mc.buttonMode = true;
			dragger_mc.addEventListener(MouseEvent.MOUSE_DOWN, handleSrollDown);
			visible = true;
			disable = false;
			//visible = true;
			if(top_mc){
				top_mc.buttonMode = true;
				top_mc.addEventListener(MouseEvent.MOUSE_DOWN, handleTopDown);
				top_mc.addEventListener(MouseEvent.MOUSE_UP, handleTopUp);
			}
			
			if(bottom_mc){
				bottom_mc.buttonMode = true;
				bottom_mc.addEventListener(MouseEvent.MOUSE_DOWN, handleBottomDown);
				bottom_mc.addEventListener(MouseEvent.MOUSE_UP, handleBottomUp);
			}
		}
		
		
		
		private function disableScroller(event : Event = null) : void {
			this.parent.removeEventListener(MouseEvent.MOUSE_WHEEL, scrollHandler);
			dragger_mc.buttonMode = false;
			dragger_mc.removeEventListener(MouseEvent.MOUSE_DOWN, handleSrollDown);
			pause();
			visible = false;
			disable = true;
			//visible = false;
			if(top_mc){
				top_mc.buttonMode = false;
				top_mc.removeEventListener(MouseEvent.MOUSE_DOWN, handleTopDown);
				top_mc.removeEventListener(MouseEvent.MOUSE_UP, handleTopUp);
			}
			
			if(bottom_mc){
				bottom_mc.buttonMode = false;
				bottom_mc.removeEventListener(MouseEvent.MOUSE_DOWN, handleBottomDown);
				bottom_mc.removeEventListener(MouseEvent.MOUSE_UP, handleBottomUp);
			}
			goTop();
		}

		
		
		
		
		
		
		
		
		private function handleTopDown(event : MouseEvent) : void {
			addEventListener(Event.ENTER_FRAME, handlePressTop);
		}
		
		private function handleTopUp(event : MouseEvent) : void {
			removeEventListener(Event.ENTER_FRAME, handlePressTop);
		}
		
		private function handleBottomDown(event : MouseEvent) : void {
			addEventListener(Event.ENTER_FRAME, handlePressBottom);
		}
		
		private function handleBottomUp(event : MouseEvent) : void {
			removeEventListener(Event.ENTER_FRAME, handlePressBottom);
		}
		
		
		
		
		
		private function handlePressTop(e : Event) : void {
			if(dragger_mc.x - 10 > scroll_bg.x){
				dragger_mc.x -= 10;
			}else{
				dragger_mc.x = scroll_bg.x;
			}
			start();
		}
		
		
		
		
		private function handlePressBottom(e : Event) : void {
			if(dragger_mc.x + dragger_mc.width + 10 < scroll_bg.x + scroll_bg.width){
				dragger_mc.x += 10;
			}else{
				dragger_mc.x = scroll_bg.x + scroll_bg.width - dragger_mc.width;
			}
			start();
		}
		
		
		
		private function scrollHandler(event:MouseEvent):void {
			if(event.delta>0) {
				start();
				handlePressTop(null);
			}
			
			if(event.delta<0) {
				start();
				handlePressBottom(null);
			}
			
		}
		
		
		
		private function handleSrollDown(event : MouseEvent = null) : void {
			scroll_pressed = true;
			var bounds : Rectangle = new Rectangle(scroll_bg.x, 0, (scroll_bg.width - dragger_mc.width), 0);
			dragger_mc.startDrag(false, bounds);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleSrollUp);
			start();
		}
		
		
		
		
		private function handleSrollUp(event : MouseEvent = null) : void {
			removeEventListener(Event.ENTER_FRAME, handlePressTop);
			removeEventListener(Event.ENTER_FRAME, handlePressBottom);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleSrollUp);
			scroll_pressed = false;
			dragger_mc.stopDrag();
//			handleSrollOut(null);
		}
		
	}
}
