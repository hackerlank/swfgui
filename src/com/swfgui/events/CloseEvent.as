package com.swfgui.events
{
	import flash.events.Event;
	
	public class CloseEvent extends Event
	{
		public static const CLOSE:String = "close";
		
		private var _detail:int;
		
		public function CloseEvent(type:String, detail:int = -1, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_detail = detail;
		}

		/**
		 * 可能的值：Alert.YES、Alert.NO、Alert.OK
		 */
		public function get detail():int
		{
			return _detail;
		}

		override public function clone():Event
		{
			return new CloseEvent(type, detail, bubbles, cancelable);
		}
	}
}