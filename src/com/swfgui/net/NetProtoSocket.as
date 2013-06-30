package com.swfgui.net
{
	import com.swfgui.debug.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;

	/**
	 * 把游戏消息GameMsg打包成数据包packet，通过tcp发送到服务器
	 * GameMsg是一个protobuf message：type、flag、content(具体的message)
	 * 数据包packet格式：packetLength, packetContent
	 */
	public class NetProtoSocket extends EventDispatcher
	{
		private var socket:Socket
		private var _host:String;
		private var _port:int;
		
		public static const headLength:int = 16;
		public static const headLengthSize:int = 4;

		public function NetProtoSocket()
		{
			socket = new Socket();
			socket.endian = Endian.LITTLE_ENDIAN;
			socket.timeout = 5000;
			socket.addEventListener(Event.CLOSE,CloseHandle);
			socket.addEventListener(Event.CONNECT,ConnectHandle);
			socket.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandle);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA,socketDataHandle);
		}

		public function connect(host:String,port:int):void
		{
			this._host = host;
			this._port = port;
			socket.connect(host,port)
			Logger.Log(this, "connecting " + host + ":" + port);
		}

		public function reconnect():void
		{
			if (!socket.connected)
			{
				socket.connect(_host,_port)
			}
		}

		private function CloseHandle(evt:Event):void
		{
			this.dispatchEvent(evt);
			//Alert.instance.show("服务器断开，请重新登录");
		}

		private function ConnectHandle(evt:Event):void
		{
			this.dispatchEvent(evt);
		}

		private function ioErrorHandle(evt:IOErrorEvent):void
		{
			this.dispatchEvent(evt);
			//Alert.instance.show("服务器断开，请重新登录");
		}

		private function securityError(evt:SecurityErrorEvent):void
		{
			this.dispatchEvent(evt);
			//Alert.instance.show("安全策略错误");
		}

		public function get isConnect():Boolean
		{
			return socket.connected
		}
		
		public function sendData(data:ByteArray):void
		{
			try
			{				
				data.position = 0;
				socket.writeBytes(data);
				socket.flush();
			}
			catch(e:Error)
			{
				//Alert.instance.show("服务器断开，请重新登录");
			}
		}		
		
		private var packetLength:uint;

		private function socketDataHandle(evt:Event):void
		{
			readDataPacket(socket);
		}

		/**
		 * 从data中分离出数据包
		 * @param data
		 */
		protected function readDataPacket(data:IDataInput):void
		{
			while (data.bytesAvailable > 1)
			{
				//开始读取一个新包
				if (packetLength == 0)
				{
					if(data.bytesAvailable > headLengthSize)
					{
						packetLength = ReadPacketLength(data);
					}
					else
					{
						break;
					}
				}

				if (data.bytesAvailable >= packetLength)
				{
					//读取完整包
					var packet:ByteArray = new ByteArray();
					packet.endian = Endian.LITTLE_ENDIAN;
					data.readBytes(packet, 0, packetLength);
					packet.position = 0;
					this.dispatchEvent(new NetEvent(NetEvent.GET_PROTO_DATA, packet));
					packetLength = 0;
				}
				else
				{
					//等待后续数据
					break;
				}
			}
		}
		
		/**
		 * 把数据打包成数据包，以便使用tcp发送
		 * @param data
		 * @return 
		 */
		protected function writeDataPacket(data:ByteArray):ByteArray
		{
			/*var contentLength:int = data.length;
			var too:int = 0;
			data.position = 0;
			
			while (contentLength > 0)
			{
				data.writeByte(0);
				contentLength /= 128;
				too++;
			}
			
			//数据包长度写入
			data.position = 0;
			WriteUtils.write_TYPE_UINT32(data, data.length - too);*/
			
			
			
			return data;
		}
		
		/**
		 * 从数据流中读取出数据包长度
		 * @param input
		 * @return 
		 */
		protected function ReadPacketLength(data:IDataInput):uint
		{
			var result:uint = 0
			/*for (var i:uint = 0; ; i += 7)
			{
				var b:uint = data.readUnsignedByte();
				if (i < 32)
				{
					if (b >= 0x80)
					{
						result |= ((b & 0x7f) << i);
					}
					else
					{
						result |= (b << i);
						break;
					}
				}
				else
				{
					while (data.readUnsignedByte() >= 0x80)
					{
					}
					break
				}
			}*/
				
//			var i:int = data.readUnsignedInt();
			result = data.readUnsignedInt() + headLength - headLengthSize;
//			var b:ByteArray = new ByteArray();
//			b.endian = Endian.BIG_ENDIAN;
//			b.writeUnsignedInt(i);			
//			b.position = 0;
//			trace("socket接收：", b.readByte(), b.readByte(), b.readByte(), b.readByte());
				
			return result;
		}

	}
}