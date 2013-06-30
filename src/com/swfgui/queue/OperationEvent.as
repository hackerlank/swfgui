package com.swfgui.queue
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class OperationEvent extends Event
	{		
		public static const COMPLETE:String = "COMPLETE";
		
		public var thisRef:EventDispatcher;
		
		public function OperationEvent(type:String, thisRef:EventDispatcher, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.thisRef = thisRef;
		}
		
		override public function clone():Event
		{
			return new OperationEvent(type, thisRef, bubbles, cancelable);
		}
	}
}