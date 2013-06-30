package com.swfgui.msg
{

	public class MsgObserver
	{
		private var _msgClass:Class;
		private var _callBack:Function;
		private var _imsgProxy:IMsgProxy;		
		
		/**
		 * 
		 * @param msgClass 消息类，如AddItem_S2C
		 * @param callBack 消息代理者，如ItemProxy
		 */
		public function MsgObserver(msgClass:Class, callBack:Function, imsgProxy:IMsgProxy):void
		{
			this._msgClass = msgClass;
			this._callBack = callBack;
			this._imsgProxy = imsgProxy;
		}
		
		public function msgClassInstence():Object
		{
			var classInstence:Object = new this._msgClass;
			return classInstence;
		}
		
		public function get callBack():Function
		{
			return this._callBack;
		}
		
		public function get imsgProxy():IMsgProxy
		{
			return this._imsgProxy
		}
		
		public function compareIMsgProxy( imsgProxy:IMsgProxy ):Boolean
		{
			return this._imsgProxy === imsgProxy;
		}	

	}
}
