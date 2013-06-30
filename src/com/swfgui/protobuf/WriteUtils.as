package com.swfgui.protobuf
{
import flash.utils.*;

final public class WriteUtils extends Object
{

    public function WriteUtils()
    {
    }

    public static function write_TYPE_SINT32(output:WritingBuffer, value:int) : void
    {
        write_TYPE_UINT32(output, ZigZag.encode32(value));
    }

    public static function write_TYPE_UINT64(output:WritingBuffer, value:UInt64) : void
    {
        writeVarint64(output, value.low, value.high);
    }

    private static function writeVarint64(output:WritingBuffer, low:uint, high:uint) : void
    {
        var _loc_4:uint = 0;
        if (high == 0)
        {
            write_TYPE_UINT32(output, low);
        }
        else
        {
            _loc_4 = 0;
            while (_loc_4 < 4)
            {
                
                output.writeByte(low & 127 | 128);
                low = low >>> 7;
                _loc_4 = _loc_4 + 1;
            }
            if ((high & 268435455 << 3) == 0)
            {
                output.writeByte(high << 4 | low);
            }
            else
            {
                output.writeByte((high << 4 | low) & 127 | 128);
                write_TYPE_UINT32(output, high >>> 3);
            }
        }
    }

    public static function write_TYPE_BYTES(output:WritingBuffer, value:ByteArray) : void
    {
        write_TYPE_UINT32(output, value.length);
        output.writeBytes(value);
    }

    public static function write_TYPE_INT64(output:WritingBuffer, value:Int64) : void
    {
        writeVarint64(output, value.low, value.high);
    }

    public static function write_TYPE_INT32(output:WritingBuffer, value:int) : void
    {
        if (value < 0)
        {
            writeVarint64(output, value, 4294967295);
        }
        else
        {
            write_TYPE_UINT32(output, value);
        }
    }

    public static function write_TYPE_SFIXED64(output:WritingBuffer, value:Int64) : void
    {
        output.endian = Endian.LITTLE_ENDIAN;
        output.writeUnsignedInt(ZigZag.encode64low(value.low, value.high));
        output.writeUnsignedInt(ZigZag.encode64high(value.low, value.high));
    }

    public static function write_TYPE_SFIXED32(output:WritingBuffer, value:int) : void
    {
        write_TYPE_FIXED32(output, ZigZag.encode32(value));
    }

    public static function write_TYPE_FIXED64(output:WritingBuffer, value:Int64) : void
    {
        output.endian = Endian.LITTLE_ENDIAN;
        output.writeUnsignedInt(value.low);
        output.writeInt(value.high);
    }

    public static function write_TYPE_FIXED32(output:WritingBuffer, value:int) : void
    {
        output.endian = Endian.LITTLE_ENDIAN;
        output.writeInt(value);
    }

    public static function write_TYPE_BOOL(output:WritingBuffer, value:Boolean) : void
    {
        output.writeByte(value ? (1) : (0));
    }

    public static function write_TYPE_MESSAGE(output:WritingBuffer, value:IMessage) : void
    {
        var _loc_3:* = output.beginBlock();
        value.writeToBuffer(output);
        output.endBlock(_loc_3);
    }

    public static function write_TYPE_ENUM(output:WritingBuffer, value:int) : void
    {
        write_TYPE_INT32(output, value);
    }

    public static function write_TYPE_STRING(output:WritingBuffer, value:String) : void
    {
        var _loc_3:* = output.beginBlock();
        output.writeUTFBytes(value);
        output.endBlock(_loc_3);
    }

    public static function write_TYPE_FLOAT(output:WritingBuffer, value:Number) : void
    {
        output.endian = Endian.LITTLE_ENDIAN;
        output.writeFloat(value);
    }

    public static function writePackedRepeated(output:WritingBuffer, writeFunction:Function, value:Array) : void
    {
        var _loc_4:* = output.beginBlock();
        var _loc_5:uint = 0;
        while (_loc_5 < value.length)
        {
            
            writeFunction(output, value[_loc_5]);
            _loc_5 = _loc_5 + 1;
        }
        output.endBlock(_loc_4);
    }

    public static function writeTag(output:WritingBuffer, wireType:uint, number:uint) : void
    {
        write_TYPE_UINT32(output, number << 3 | wireType);
    }

    public static function write_TYPE_DOUBLE(output:WritingBuffer, value:Number) : void
    {
        output.endian = Endian.LITTLE_ENDIAN;
        output.writeDouble(value);
    }

    public static function write_TYPE_UINT32(output:ByteArray, value:uint) : void
    {
        while (true)
        {
            
            if ((value & ~127) == 0)
            {
                output.writeByte(value);
                return;
            }
            output.writeByte(value & 127 | 128);
            value = value >>> 7;
        }
    }

    public static function write_TYPE_SINT64(output:WritingBuffer, value:Int64) : void
    {
        writeVarint64(output, ZigZag.encode64low(value.low, value.high), ZigZag.encode64high(value.low, value.high));
    }
    
    public static function write_BUFFER_LENGTH(output:WritingBuffer, value:int) : void
    {
    	if (value == 0)
    		return;
    	
    	WriteUtils.write_TYPE_INT32(output, value || 0x7f);
    	value = value >> 4;
    	write_BUFFER_LENGTH(output, value >> 4)
    }

}
}
