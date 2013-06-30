package com.swfgui.managers.server
{
	import com.swfgui.debug.Logger;
	import com.swfgui.protobuf.Message;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * 
	 * @author llj
	 * 
	 */
	public class ServerManager extends EventDispatcher
	{
		private static var _instence:IServerManagerImpl;
		
		public static function setInstance(instence:IServerManagerImpl):void
		{
			_instence = instence;
		}
		
		public function ServerManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function get instance():IServerManagerImpl
		{
			return _instence;
		}
		
		public static function sendMsg(data:Message, msgType:int = -1):void
		{
			_instence.sendMsg(data, msgType);
		}
		
		/**
		 * 服务器毫秒数
		 * @return 
		 */
		public static function get serverTime():Number
		{
			return ServerTime.instance.serverTime;
		}
		
		public static function get gameTime():Number
		{
			return ServerTime.instance.serverTime;
		}
		
		public static var lastPingSendTime:Number;
		public static function Ping():void
		{
			Logger.Log(ServerManager, "PingGate_C2S_Msg [" + 
				"]");
			lastPingSendTime = serverTime;
			
			//var msg:PingGate_C2S_Msg = new PingGate_C2S_Msg();
			//sendMsg(msg);
			
		}
	}
}