package com.swfgui.msg
{
	import flash.utils.Dictionary;
	import flash.utils.IExternalizable;
	import flash.utils.getQualifiedClassName;
	
	import com.swfgui.protobuf.Message;

	
	public class MsgManagerImpl implements IMsgManagerImpl
	{
		//以消息类型为键，消息的观察者数组为值
		//msgMap[123] = [msgObserver, msgObserver]
		private var msgMap:Dictionary;
		
		private var msgType:Class;

		public function MsgManagerImpl(msgType:Class)
		{
			this.msgType = msgType;
			msgMap = new Dictionary();
		}


		/**
		 *
		 * 注册一个消息proxy类
		 * [msgType:int , msgClass:Class, callBack:Function]
		 * @param iMsgProxy
		 *
		 */
		public function registerMsgProxy(iMsgProxy:IMsgProxy):void
		{
			var msgList:Array = iMsgProxy.msgListeners();
			var msgObserver:MsgObserver;
			var msgType:int; //消息类型
			var msgClass:Class; //消息解析类
			var callBack:Function; //回调函数
			var len:int = msgList.length;

			for (var i:int = 0; i<len; i++)
			{
				msgType = msgList[i][0];
				msgClass = msgList[i][1];
				callBack = msgList[i][2];
				msgObserver = new MsgObserver(msgClass, callBack, iMsgProxy);

				if (!this.msgMap[msgType])
				{
					this.msgMap[msgType] = new Array();
				}
				(this.msgMap[msgType] as Array).push(msgObserver);
			}
		}

		public function removeMsgProxy(iMsgProxy:IMsgProxy):void
		{
			var msgList:Array = iMsgProxy.msgListeners();
			var msgType:int;
			var len:int = msgList.length;

			for (var i:int = 0; i<len; i++)
			{
				msgType = msgList[i][0];
				
				//格式msgMap[123] = [msgObserver, msgObserver]
				if (this.msgMap[msgType])
				{
					var msgObserverList:Array = this.msgMap[msgType] as Array;
					var length:int = msgObserverList.length;
					
					for (var j:int = 0; j < length; j++)
					{
						var msgObserver:MsgObserver = msgObserverList[j] as MsgObserver;
						if (msgObserver.compareIMsgProxy(iMsgProxy))
						{
							msgObserverList.splice(j,1);
							break;
						}
					}
					if (msgObserverList.length == 0)
					{
						this.msgMap[msgType] = null;
					}
				}
			}
		}

		public function notifyGameMsg(gameMsg:GameMsg):Object
		{
			var msgObss:Array = this.msgMap[gameMsg.type] as Array
			var classInstence:Object,
				i:int,
				j:int;

			if (msgObss)
			{
				//通知所有观察者，消息来了
				for (i = 0; i < msgObss.length; i++)
				{
					var msgObserver:MsgObserver = msgObss[i] as MsgObserver;
					if (!classInstence)
					{
						classInstence = msgObserver.msgClassInstence();
						//当retCode为0时，才解析具体协议内容
						if(gameMsg.retCode == 0)
						{
							(classInstence as IExternalizable).readExternal(gameMsg.content);
						}
						
						classInstence.retCode = gameMsg.retCode;
					}

					msgObserver.callBack.call(null, classInstence);
				}
			}

			return classInstence;
		}


		public function NotifyMessage(type:int, msg:Message):void
		{
			var msgObss:Array = this.msgMap[type] as Array;
			var classInstence:Object,
				i:int,
				j:int;
			if (msgObss)
			{
				for (i = 0; i < msgObss.length; i++)
				{
					var msgObserver:MsgObserver = msgObss[i] as MsgObserver;
					msgObserver.callBack.call(null, classInstence);
				}
			}
		}

		//根据消息类，得到消息类型opcode
		public function getTypeByClass(_class:*):int
		{
			var name:String = getQualifiedClassName(_class);
			name = name.split("::")[1] as String;

			if (msgType[name] == null)
				return 0;

			var type:int = msgType[name];
			return type;
		}
		
	}
}