package com.swfgui.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class ResizeEvent extends Event
	{
		public static const RESIZE:String = "resize";

		private var _oldWidth:Number;
		private var _oldHeight:Number;
		
		public function ResizeEvent(type:String, oldWdth:Number,
									oldHeight:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_oldWidth = oldWdth;
			_oldHeight = oldHeight;
		}
		
		override public function clone():Event
		{
			return new ResizeEvent(type, oldWidth, oldHeight, bubbles, cancelable);
		}

		public function get oldWidth():Number
		{
			return _oldWidth;
		}

		public function get oldHeight():Number
		{
			return _oldHeight;
		}

	}
}