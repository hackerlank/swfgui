package com.swfgui.msg
{
import com.swfgui.protobuf.Message;



public class MsgManager
{
	public static var _impl:IMsgManagerImpl = new MsgManagerImpl(null);
	
	
	/**
	 * 为了扩展，定义一个"静态工具类"，分成了三步：
	 * 1、定义interface Ixxx
	 * 2、定义interface的实现类xxxImpl
	 * 3、定义供外部使用的类xxx
	 */
	public function MsgManager()
	{
		
	}
	
	private static function get impl():IMsgManagerImpl
	{
		return _impl
	}
	
	
	/**
	 * [msgType:int , msgClass:Class, callBack:Function]  
	 * @param iMsgProxy
	 * 
	 */		
	public static function registerMsgProxy(iMsgProxy:IMsgProxy):void
	{
		impl.registerMsgProxy(iMsgProxy);
	}
	
	public static function removeMsgProxy(iMsgProxy:IMsgProxy):void
	{
		impl.removeMsgProxy(iMsgProxy);
	}
	
	
	public static function notifyGameMsg(gameMsg:GameMsg):Object
	{
		return impl.notifyGameMsg(gameMsg);
	}
	
	public static function NotifyMessage(type:int, msg:Message):void
	{
		impl.NotifyMessage(type, msg);
	}
	
	
	public static function getTypeByClass(_class:*):int
	{
		return impl.getTypeByClass(_class);
	}
	
	
}
}