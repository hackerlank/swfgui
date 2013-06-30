package com.swfgui.mvc
{
	import com.swfgui.interfaces.IDisposable;
	import com.swfgui.msg.IMsgProxy;
	import com.swfgui.msg.MsgManager;

	/**
	 * 代理者模式，访问远程数据，参考puremvc
	 * @author llj
	 */
	public class Proxy implements IMsgProxy, IDisposable
	{
		private var _hasDisposed:Boolean;
		
		public function Proxy()
		{
			this.registerMsgListeners();
		}
		
		/**
		 * 销毁对象：一般需要把属性置null，删除事件监听器……
		 */
		public function dispose():void
		{
			_hasDisposed = true;
			this.removeMsgListeners();
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
		 * 表示监听哪些消息
		 * 每个元素也是数组：[msgType:int , msgClass:Class, callBack:Function]
		 * @return 
		 */
		public function msgListeners():Array
		{
			return [];
		}
		
		private function registerMsgListeners():void
		{
			MsgManager.registerMsgProxy(this);
		}
		
		private function removeMsgListeners():void
		{
			MsgManager.removeMsgProxy(this);
		}
	}
}