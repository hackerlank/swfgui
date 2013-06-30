package com.swfgui.msg
{
	import flash.sampler.getSize;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IExternalizable;
	
	import com.swfgui.protobuf.Int64;
	import com.swfgui.protobuf.Message;
	import com.swfgui.protobuf.WriteUtils;
	import com.swfgui.protobuf.WritingBuffer;


	/**
	 * 	为protobuf提供的一些辅助抽象方法
	 *
	 */
	public class MsgUtils
	{
		public function MsgUtils()
		{
		}

		public static function DecodeToClass(by:ByteArray, toClass:Class):Object
		{
			by.position = 0;
			var classInstence:Object = new toClass();
			(classInstence as IExternalizable).readExternal(by);
			return classInstence;
		}

		public static function DecodeToMsgByGamgMsgBuffer(buffer:IDataInput, class1:Class):IExternalizable
		{
			var data2:GameMsg = new GameMsg();
			data2.readExternal(buffer);

			var msg:IExternalizable = new class1() as IExternalizable;
			msg.readExternal(data2.content);

			return msg;
		}

		/**
		 * 把protobuf消息包装成GameMsg，用于发送
		 * @param data protobuf消息
		 * @param msgType protobuf消息类型，也就是常说的opcode
		 * @return 
		 */
		public static function GetGameMsgByMsg(data:Message, msgType:int = -1):GameMsg
		{
			var msg:GameMsg = new GameMsg();
			if (msgType == -1)
				msg.type = MsgManager.getTypeByClass(data);
			else
				msg.type = msgType;

			msg.content = new ByteArray();
			msg.content.endian = Endian.LITTLE_ENDIAN;
			data.writeExternal(msg.content);

			return msg;
		}
				
		/**
		 * 压缩混淆GameMsg
		 * @param msg
		 */
		public static function GameMsgEncode(msg:GameMsg):void
		{
			var isCompress:uint = msg.flag & 1;
			var isConfuse:uint = msg.flag & 2;

			var realByteArray:ByteArray = new ByteArray();
			if (isCompress > 0
				&& msg.content.length > 0)
			{
				//压缩
				msg.content.compress();
			}


			if (isConfuse > 0
				&& msg.content.length > 0)
			{
				//混淆
				msg.content = ConfuseBytes(msg.content, msg.content.length % 2);
			}

		}
		
		/**
		 * 解压缩、还原GameMsg
		 * @param msg
		 */
		public static function GameMsgDecode(msg:GameMsg):void
		{
			var isCompress:uint = msg.flag & 1;
			var isConfuse:uint = msg.flag & 2;


			if (isConfuse > 0)
			{
				msg.content = DeconfuseBytes(msg.content, msg.content.length % 2);
			}


			if (isCompress > 0)
			{
				msg.content.position = 0;
				msg.content.uncompress();
			}

		}

		//混淆代码，简单移位与或
		private static function ConfuseBytes(inBytes:ByteArray, idd:int):ByteArray
		{
			if (inBytes.length >= 2)
			{
				inBytes.position = 0;
				var tempByte:int = inBytes[0];
				inBytes[0] = inBytes[inBytes.length - 1];
				inBytes[inBytes.length - 1] = tempByte;

				for (var i:int = idd; i < inBytes.length; i += 2)
				{
					var minTempByte:int = inBytes[i];
					inBytes[i] = ~(minTempByte << 4 & 0x00F0 | minTempByte >> 4 & 0x000F);
				}

			}
			return inBytes;
		}

		private static function DeconfuseBytes(inBytes:ByteArray, idd:int):ByteArray
		{
			if (inBytes.length >= 2)
			{
				for (var i:int = idd; i < inBytes.length; i += 2)
				{
					var minTempByte:int = ~inBytes[i];
					inBytes[i] = (minTempByte << 4 & 0x00F0 | minTempByte >> 4 & 0x000F);
				}

				var tempByte:int = inBytes[0];
				inBytes[0] = inBytes[inBytes.length - 1];
				inBytes[inBytes.length - 1] = tempByte;
			}
			return inBytes;
		}
	}
}