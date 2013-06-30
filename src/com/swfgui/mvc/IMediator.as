package com.swfgui.mvc
{
	public interface IMediator
	{
		function sendNotification(notificationName:String, 
								  arg1:Object = null, 
								  arg2:Object = null,
								  arg3:Object = null, 
								  arg4:Object = null):void;
		
		function notificationListeners():Array;
	}
}