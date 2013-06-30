package com.swfgui.msg
{
import com.swfgui.protobuf.Message;


public interface IMsgManagerImpl
{
	function registerMsgProxy(iMsgProxy:IMsgProxy):void
	
	function removeMsgProxy(iMsgProxy:IMsgProxy):void
	
	function notifyGameMsg(gameMsg:GameMsg):Object
	
	function NotifyMessage(type:int, msg:Message):void
	
	function getTypeByClass(_class:*):int
}
}