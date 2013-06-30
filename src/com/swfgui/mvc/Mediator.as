package com.swfgui.mvc
{
	import flash.events.EventDispatcher;
	
	import com.swfgui.interfaces.IDisposable;

	/**
	 * 中介者模式，参考puremvc
	 * @author llj
	 */
	public class Mediator extends EventDispatcher implements IDisposable, IMediator
	{
		private var _hasDisposed:Boolean;
		
		public function Mediator()
		{
			registerNotifListeners();
		}
		
		/**
		 * 销毁对象：一般需要把属性置null，删除事件监听器……
		 */
		public function dispose():void
		{
			_hasDisposed = true;
			removeNotifListeners();
		}
		
		/**
		 * 防止重复Dispose
		 * @return
		 */
		public function get hasDisposed():Boolean
		{
			return _hasDisposed;
		}
		
		public function sendNotification(notificationName:String, 
										 arg1:Object = null, 
										 arg2:Object = null,
										 arg3:Object = null, 
										 arg4:Object = null):void
		{
			Facade.instance.sendNotification(notificationName, arg1, arg2, arg3, arg4);
		}
		
		
		/**
		 * 表示监听哪些通知，
		 * 每个元素也是一个数组[sig:Signal, listener:Function]
		 * @return 
		 */
		public function notificationListeners():Array
		{
			return [];
		}
		
		private function registerNotifListeners():void
		{
			Facade.instance.registerNotifListeners(this);
		}
		
		private function removeNotifListeners():void
		{
			Facade.instance.removeNotifListeners(this);
		}
	}
}