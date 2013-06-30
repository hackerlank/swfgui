package com.swfgui.managers.server
{
	import com.swfgui.protobuf.Int64;
	import com.swfgui.protobuf.Message;
	
	import flash.events.IEventDispatcher;
	
	/**
	 * 
	 * @author Allen
	 * 
	 */
	public interface IServerManagerImpl extends IEventDispatcher
	{
		function initNetProtoSocket(host:String, port:int):void;		
		
		function get nowTime():Number;
		
		function get gameTime():Number
		
		function sendMsg(data:Message, msgType:int = -1):void;
		
		function get lastSendTimer():Number
	}
}