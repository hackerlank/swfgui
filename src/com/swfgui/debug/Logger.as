package com.swfgui.debug
{
	
	import flash.events.EventDispatcher;
	import flash.system.System;
	import flash.utils.getTimer;
	
	import com.swfgui.utils.Utils;
	
	public class Logger extends EventDispatcher
	{
		
		internal static var level:int = 0;
		public static var isDebugging:Boolean = false;
		public static var isProfile:Boolean = false;
		
		
//		private static var _console:LoggerConsole;
//		public static function get console():LoggerConsole
//		{
//			if (_console == null)
//				_console = new LoggerConsole();
//			return _console;
//		}
		
		public function Logger()
		{
			
		}
		
		
		private static var _instance:Logger;
		public static function getInstance():Logger
		{
			if (_instance == null)
				_instance = new Logger();
			return _instance;
		}
		
		
		public static function Log(instance:*, str:String, _level:int=1):void
		{
			if(_level >= level)
			{
				var s:String = Utils.getClassName(instance) + "" + str;
				trace( s );
//				console.LocalConnectionHandler("Log_" + s);
			}
		}
		
		private static function get mem():int
		{
			return int(System.totalMemory / (1024 * 1024));
		}
	
		public static function Mem(str:String):void
		{
			trace("[MEM] > " + mem + " M <  " + str);
		}
		
		public static function Output(instance:*, str:String):void
		{
			trace(str);
		}
		
		
		public static function Debug(instance:*, str:String):void
		{
			if(isDebugging)
			{
				trace( Utils.getClassName(instance) +"[Debug] "+ str );
				
			}
		}
		
		
		public static function Warning(instance:*, str:String):void
		{
			
			var s:String = Utils.getClassName(instance) +"[Warning] "+ str;
			trace( s );
//			console.LocalConnectionHandler("WARNING_" + s);
		}
		
		
		
		
		private static var _lastTimer:Number;
		private static var _lastStr:String;
		private static var _lastInstance:*;
		private static var _lastLevel:int;
		public static function Perform(instance:*, str:String, level:int = 0):void
		{
			if(!isProfile)
				return;
			
			var nLevel:int = _lastLevel;
			var sLevel:String = "";
			
			var timeCost:Number = isNaN(_lastTimer) ? 0 : (getTimer() - _lastTimer);
			_lastTimer = getTimer();
			
			var sTimeCost:String; 
			if(timeCost < 10)
			{
				sTimeCost = "  " + timeCost.toString();
			}
			else if(timeCost < 100)
			{
				sTimeCost = " " + timeCost.toString();
			}
			else
			{
				sTimeCost = timeCost.toString();
			}
			
			while(nLevel-- > 0)
			{
				sLevel += "   ";
			} 
			
			if(_lastStr != null)
				trace( Utils.getClassName(_lastInstance) + "[" + sTimeCost + "ms]" + sLevel + _lastStr );
			
			_lastStr = str;
			_lastInstance = instance;
			_lastLevel = level;
		}
		
		
		public static function Throwing(instance:*, str:String):void
		{
			//return;
			
			if(instance is String)
			{
				Warning(instance, str);
				//Alert.show( String(instence) + " " + str );
			}
			else
			{
				Warning(instance, str);
				//Alert.show( Utils.getClassName(instence) + str );
			}
			
			//throw(new Error(Utils.getClassName(instence) + str));
		}
	}
}