package com.swfgui.msg
{

	import flash.errors.IOError;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IExternalizable;
	
	import com.swfgui.protobuf.*;



	/**
	 *
	 * 消息的结构：type(消息类型) flag(是否加密压缩) content(消息的内容)
	 * @author llj
	 */
	public final class GameMsg extends Message implements IExternalizable
	{

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		private var _msgLength:int;//4 包体长度，不包含包头的16个字节
		public var type:int;//2 opcode 命令字，用于存放消息ID的16位双字节，表示消息的意义，包体将依据它分发到不同的处理逻辑中
		public var cmdEx:int;//2 次要opcode 第二层命令字，特殊情况下会用到，以提升服务器对数据包进行解析和分发时的性能
		public var route:int;//2 路由ID，用于为网关服务标识转发路径，提升转发性能
		public var flag:int;//1 消息标记位，标示消息是否加密、加密类型、以及其他需要标记的信息
		public var blank:Number = 0;//5 保留字，可以用于携带小数据，若此处可以存储的下，则可以省略包体信息，这时包体长度为0
		public var content:ByteArray;//msgLength 包体是由google的protobuf协议进行编码的


		//--------------------------------------------------------------------------
		//
		//  IO Methods
		//
		//--------------------------------------------------------------------------

		override public function writeToBuffer(output:WritingBuffer):void
		{
			output.writeUnsignedInt(msgLength);
			output.writeShort(type);
			output.writeShort(cmdEx);
			output.writeShort(route);
			output.writeByte(flag);
			output.writeInt(0);
			output.writeByte(0);
			if(content)
			{
				output.writeBytes(content);
			}
		}

		public function readExternal(input:IDataInput):void
		{
			//_msgLength = input.readUnsignedInt();
			type = input.readUnsignedShort();
			cmdEx = input.readUnsignedShort();
			this.retCode = cmdEx;
			route = input.readUnsignedShort();
			flag = input.readByte();
			blank = input.readInt() + input.readByte();
			
			content = new ByteArray();
			content.endian = Endian.LITTLE_ENDIAN;
			input.readBytes(content);
		}

		public function get msgLength():int
		{
			return content ? content.length : 0;
		}

		override public function toString() : String
		{
			var c:String = "";
			content.position = 0;
			while(content.bytesAvailable)
			{
				c += content.readUnsignedByte() + ", ";
			}
			
			return "length:" + msgLength + "\n" +
				"cmd:" + type + "\n" +
				"cmdEx:" + cmdEx + "\n" +
				"route:" + route + "\n" +
				"flag:" + flag + "\n" +
				"blank:" + blank + "\n" +				
				"content:" + c + "\n\n";
		}

	}

}