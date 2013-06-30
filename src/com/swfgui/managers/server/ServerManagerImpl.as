package com.swfgui.managers.server
{
	import com.swfgui.debug.Logger;
	import com.swfgui.msg.GameMsg;
	import com.swfgui.msg.MsgManager;
	import com.swfgui.msg.MsgUtils;
	import com.swfgui.net.NetEvent;
	import com.swfgui.net.NetProtoSocket;
	import com.swfgui.protobuf.Int64;
	import com.swfgui.protobuf.Message;
	import com.swfgui.protobuf.WritingBuffer;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;


	public class ServerManagerImpl extends EventDispatcher implements IServerManagerImpl
	{
		public var autoReconnect:Boolean; //是否自动重连
		public var useCompress:Boolean;
		public var useConfuse:Boolean;

		private var nps:NetProtoSocket;

		public function ServerManagerImpl()
		{
		}

		public function initNetProtoSocket(host:String, port:int):void
		{
			nps = new NetProtoSocket();
			nps.connect(host, port);
			nps.addEventListener(NetEvent.GET_PROTO_DATA,netProtoSocketHandle);
			nps.addEventListener(Event.CLOSE,CloseHandle);
			nps.addEventListener(Event.CONNECT,ConnectHandle);
			nps.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandle);
			nps.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityError);
		}

		private var _lastSendTimer:Number = 0;

		public function get lastSendTimer():Number
		{
			return _lastSendTimer;
		}

		public function sendMsg(data:Message, msgType:int = -1):void
		{
			if (!nps)
			{
				return;
			}

			//if (nps.isConnect)
			{
				var msg:GameMsg = MsgUtils.GetGameMsgByMsg(data, msgType);
				//msg.flag = Globals.useCompress + Globals.useConfuse * 2;
				//MsgUtils.GameMsgEncode(msg);
				var buffer:WritingBuffer = new WritingBuffer();
				msg.writeExternal(buffer);
				nps.sendData(buffer);
				_lastSendTimer = getTimer();
				
				traceMsg("发送消息：", msg, buffer);
			}
			//else if (autoReconnect)
			{
				//nps.reconnect();
				//Globals.platform.debug("断线自动重连");
				//UiInterCmd.instance.debug("断线自动重连");
			}
		}

		private function recvMsg(data:ByteArray):void
		{
			var msg:GameMsg = new GameMsg();
			data.position = 0;
			msg.readExternal(data);
			MsgUtils.GameMsgDecode(msg);			
			MsgManager.notifyGameMsg(msg);
			
			//todo 打印网络信息
			var byte:ByteArray = new ByteArray();
			byte.endian = Endian.LITTLE_ENDIAN;
			byte.writeUnsignedInt(msg.msgLength);
			byte.writeBytes(data);
			traceMsg("收到消息：", msg, byte);
		}
		
		public function traceMsg(head:String, msg:GameMsg, data:ByteArray):void
		{
			var c:String = head + "type：" + msg.type + "\n";
			var pos:int = data.position;
			data.position = 0;			
			while(data.bytesAvailable)
			{
				c += data.readUnsignedByte() + ", ";
			}			
			data.position = pos;
			
			trace(c);
		}
		
		
		public function getClassNameByType(type:int):String
		{			
//			for(var name:String in MsgType)
//			{
//				if(MsgType[name] == type)
//				{
//					return name;
//				}
//			}
			
			return "null";
		}

		private function netProtoSocketHandle(evt:NetEvent):void
		{
			recvMsg(evt.eventData as ByteArray);
		}

		private function CloseHandle(evt:Event):void
		{
			this.dispatchEvent(evt);
			Logger.Log(this, "connect closed");
			disconnetc();
		}

		private function ConnectHandle(evt:Event):void
		{
			var event:NetEvent = new NetEvent(NetEvent.CONNECTED)
			this.dispatchEvent(event)
			Logger.Log(this, "connect succeed");
		}

		private function ioErrorHandle(evt:IOErrorEvent):void
		{
			this.dispatchEvent(evt);
			Logger.Log(this, "connect IOError");
			//AlertPanel.Show("connect IOError");
		}

		private function securityError(evt:SecurityErrorEvent):void
		{
			this.dispatchEvent(evt)
			Logger.Log(this, "connect security error");
			//AlertPanel.Show("连接安全策略错误");
			//Globals.platform.debug("连接安全策略错误");
			//UiInterCmd.instance.debug("连接安全策略错误");

			if (retryCount-- > 0)
			{
				//nps.reconnect();
			}
			else
			{
				retryCount = 10;
				//AlertPanel.Show("连接安全策略错误");
				//UiInterCmd.instance.debug("连接安全策略错误");
					//LoadingPnl.instance.hide();
			}
		}

		private var retryCount:int = 10;
		private var hasDisconnect:Boolean;

		private function disconnetc():void
		{
			hasDisconnect = true;

//			AlertPanel.Show("跟总部失去联系，重新连接！", Alert.OK, null, 
//				function(e:CloseEvent):void
//				{
//					Globals.platform.reLongin();
//				});
		}
		
		//--------------------------------------------------------------------------
		//
		//  Time
		//
		//--------------------------------------------------------------------------

		private var _serverTime:Number = getTimer();
		private var _gameTime:Number = getTimer();
		private var setTime:Number = getTimer();
		private var _timeFactor:int;

		public function get timeFactor():int
		{
			return _timeFactor;
		}

		/**
		 *
		 * @param serverTime
		 * @param timeFactor	// 游戏时间倍率(游戏时间/系统时间)
		 *
		 */
		internal function SetServerTime(serverTime:Int64, gameTime:Int64, timeFactor:int = 1):void
		{
			this._serverTime = serverTime.toNumber();
			this._gameTime = gameTime.toNumber();
			this._timeFactor = timeFactor;
			setTime = getTimer();
			//Logger.Log(this, "serverTime: " + serverTime.toString(16) + ", gameTime: " + gameTime.toString(16) + ", timeFactor: " + timeFactor);   	

			var serverDate:Date = new Date();
			serverDate.setTime(_serverTime);

			var gameDate:Date = new Date();
			gameDate.setTime(_gameTime);

			Logger.Log(this, "serverTime: " + serverDate + ", gameTime: " + gameDate + ", timeFactor: " + timeFactor);
		}

		/**
		 *	 服务器北京时间(绝对时间)
		 */
		public function get nowTime():Number
		{
			return getTimer(); //_serverTime + (getTimer()  - setTime) * timeFactor;
		}

		/**
		 *	游戏时间
		 */
		public function get gameTime():Number
		{
			return _gameTime + (getTimer() - setTime);
		}
	}
}