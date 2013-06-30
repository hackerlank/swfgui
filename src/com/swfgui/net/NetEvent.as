package com.swfgui.net
{
	import flash.events.Event;

	public class NetEvent extends Event
	{
		public static const SUCCESS:String = "success";
		public static const GET_PROTO_DATA:String = "getProtoData";
		public static const CONNECTED:String = "connected";
		
		private var _eventData:Object
		public function NetEvent(type:String, eventData:Object=null,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this._eventData = eventData;
			super(type, bubbles, cancelable);
		}
		
		public function get eventData():Object
		{
			return this._eventData
		}
	}
}