package com.swfgui.events
{
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * 移动事件
	 * 
	 * @author flashyiyi
	 * 
	 */
	public class MoveEvent extends Event
	{
		public static const MOVE:String = "move";
		
		private var _oldX:Number;
		private var _oldY:Number;
		
		public function MoveEvent(type:String, oldX:Number, oldY:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_oldX = oldX;
			_oldY = oldY;
		}
		
		public override function clone() : Event
		{
			return new MoveEvent(type, oldX, oldY, bubbles,cancelable);
		}

		public function get oldX():Number
		{
			return _oldX;
		}

		public function get oldY():Number
		{
			return _oldY;
		}

	}
}