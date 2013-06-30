package com.swfgui.managers.server
{
	import flash.utils.getTimer;
	
	import com.swfgui.debug.Logger;

	public class ServerTime
	{
		private var _serverTime:Number = 0;
		private var setupTime:Number = 0;
		
		private static var _instance:ServerTime;
		
		public static function get instance():ServerTime
		{
			return _instance ? _instance : _instance = new ServerTime;
		}
		
		public function ServerTime()
		{
		}		

		/**
		 * 服务器毫秒数
		 * @return 
		 */
		public function get serverTime():Number
		{
			return _serverTime + getTimer() - setupTime;
		}

		public function set serverTime(value:Number):void
		{
			Logger.Log(this, "服务器时间：" + value.toString());
			_serverTime = value;
			setupTime = getTimer();
		}
		
		public function get serverTimeSecond():Number
		{
			return serverTime / 1000;
		}
	}
}