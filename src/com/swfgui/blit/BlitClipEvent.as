package com.swfgui.blit
{
	import flash.events.Event;
	
	public class BlitClipEvent extends Event
	{
		/**
		 * 循环播放结束
		 */
		public static const PLAY_COMPLETE:String = "playComplete";
		
		/**
		 * 一次播放开始
		 */
		public static const PLAY_START:String = "playStart";
		
		/**
		 * 一次播放结束
		 */
		public static const PLAY_END:String = "playEnd";
		
		private var _label:String;
		
		public function BlitClipEvent(type:String, label:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_label = label;
		}
		
		override public function clone():Event
		{
			return new BlitClipEvent(type, label, bubbles, cancelable);
		}

		public function get label():String
		{
			return _label;
		}

	}
}