package com.swfgui.game
{
	import com.swfgui.debug.Logger;
	
	import flash.net.SharedObject;

	public class GameIO
	{
		public static var sharedName:String = "game";
		
		public static function saveObject(key:String, value:Object):void
		{
			try
			{
				var so:SharedObject = SharedObject.getLocal(sharedName);
				so.data[key] = value;
				so.flush();
			}
			catch(e:Error)
			{
				Logger.Warning(GameIO, e.message);
			}
		}
		
		public static function readObject(key:String):Object
		{
			try
			{
				var so:SharedObject = SharedObject.getLocal(sharedName);
				return so.data[key];
			}
			catch(e:Error)
			{
				Logger.Warning(GameIO, e.message);
			}
			return null;
		}
	}
}