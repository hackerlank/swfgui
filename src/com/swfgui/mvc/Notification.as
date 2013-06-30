package com.swfgui.mvc
{
	import flash.events.Event;
	
	/**
	 * 基于as3事件机制的通知实现
	 * @author llj
	 */
	public class Notification extends Event
	{
		//public static const NOTIFICATION:String = "NOTIFICATION";
		
		public var notificationName:String;
		public var arg1:Object;
		public var arg2:Object;
		public var arg3:Object;
		public var arg4:Object;
		
		/**
		 * 发送通知，arg1~arg4是4个预留参数位，可以随便使用
		 * @param notificationName
		 * @param arg1
		 * @param arg2
		 * @param arg3
		 * @param arg4
		 */
		public function Notification(notificationName:String, arg1:Object = null, 
										  arg2:Object = null,
										  arg3:Object = null, 
										  arg4:Object = null)
		{
			super(notificationName, false, false);
			
			this.notificationName = notificationName;
			this.arg1 = arg1;
			this.arg2 = arg2;
			this.arg3 = arg3;
			this.arg4 = arg4;
		}
		
		override public function clone():Event
		{
			return new Notification(notificationName, arg1, arg2, arg3, arg4);
		}
	}
}