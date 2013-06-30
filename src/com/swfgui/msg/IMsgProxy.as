package com.swfgui.msg
{
	public interface IMsgProxy
	{
		/**
		 * [msgType:int , msgClass:Class, callBack:Function] 
		 * @return 
		 * 
		 */		
		function msgListeners():Array;
	}
}