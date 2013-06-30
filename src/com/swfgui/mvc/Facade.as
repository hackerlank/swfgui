package com.swfgui.mvc
{
	import flash.events.EventDispatcher;
	
	import org.osflash.signals.Signal;

	/**
	 * 
	 * @author llj
	 */
	public class Facade extends EventDispatcher
	{
		private static var _instance:Facade;

		public function Facade()
		{
		}

		public static function get instance():Facade
		{
			return _instance || (_instance = new Facade);
		}

		/**
		 * 发送通知，模块间解耦，可以传四个参数，因为一般的通知不会
		 * 超过4个参数，参数再多的话，自己组合成一个Object吧
		 * @param notificationName
		 * @param arg1
		 * @param arg2
		 * @param arg3
		 * @param arg4
		 */
		public function sendNotification(notificationName:String, 
			arg1:Object = null, 
			arg2:Object = null,
			arg3:Object = null, 
			arg4:Object = null):void
		{
			this.dispatchEvent(new 
				Notification(notificationName, arg1,arg2, arg3, arg4));
		}
		
		public function registerNotifListeners(mediator:IMediator):void
		{
			var notifList:Array = mediator.notificationListeners();
			var len:int = notifList.length;
			
			for (var i:int = 0; i < len; i++)
			{
				var arr:Array = notifList[i] as Array;
				//this.addEventListener(arr[0], arr[1]);
				(arr[0] as Signal).add(arr[1]);
			}
		}
		
		public function removeNotifListeners(mediator:IMediator):void
		{
			var notifList:Array = mediator.notificationListeners();
			var len:int = notifList.length;
			
			for (var i:int = 0; i < len; i++)
			{
				var arr:Array = notifList[i] as Array;
				//this.removeEventListener(arr[0], arr[1]);
				(arr[0] as Signal).remove(arr[1]);
			}
		}
	}
}