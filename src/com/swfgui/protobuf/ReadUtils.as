package com.swfgui.protobuf
{
import flash.errors.*;
import flash.utils.*;


final public class ReadUtils extends Object
{

    public function ReadUtils()
    {
    }

    public static function read_TYPE_FLOAT(input:IDataInput) : Number
    {
        input.endian = Endian.LITTLE_ENDIAN;
        return input.readFloat();
    }

    public static function read_TYPE_SFIXED32(input:IDataInput) : int
    {
        input.endian = Endian.LITTLE_ENDIAN;
        return ZigZag.decode32(input.readInt());
    }

    public static function readTag(input:IDataInput) : Tag
    {
        var tag:Tag = new Tag();
        var n:uint = read_TYPE_UINT32(input);
        tag.wireType = n & 7;
        tag.number = n >>> 3;
        return tag;
    }

    public static function read_TYPE_SINT64(input:IDataInput) : Int64
    {
        var n64:Int64 = read_TYPE_INT64(input);
        n64.low = ZigZag.decode64low(n64.low, n64.high);
        n64.high = ZigZag.decode64high(n64.low, n64.high);
        return n64;
    }

    public static function read_TYPE_BOOL(input:IDataInput) : Boolean
    {
        return read_TYPE_UINT32(input) != 0;
    }

    public static function readPackedRepeated(input:IDataInput, readFuntion:Function, value:Array) : void
    {
        var ba:ByteArray = read_TYPE_BYTES(input);
        while (ba.bytesAvailable > 0)
            value.push(readFuntion(ba));
    }

    public static function read_TYPE_MESSAGE(input:IDataInput, message:IExternalizable) : IExternalizable
    {
        message.readExternal(read_TYPE_BYTES(input));
        return message;
    }

    public static function read_TYPE_STRING(input:IDataInput) : String
    {
        var n:uint = read_TYPE_UINT32(input);
        return input.readUTFBytes(n);
    }

    public static function read_TYPE_BYTES(input:IDataInput) : ByteArray
    {
        var ba:ByteArray = new ByteArray();
        var n:uint = read_TYPE_UINT32(input);
        if (n > 0)
        {
            input.readBytes(ba, 0, n);
        }
        return ba;
    }

    public static function read_TYPE_INT64(input:IDataInput) : Int64
    {
        var _loc_3:uint = 0;
        var _loc_2:* = new Int64();
        var _loc_4:uint = 0;
        while (true)
        {
            
            _loc_3 = input.readUnsignedByte();
            if (_loc_4 == 28)
            {
                break;
            }
            else if (_loc_3 >= 128)
            {
                _loc_2.low = _loc_2.low | (_loc_3 & 127) << _loc_4;
            }
            else
            {
                _loc_2.low = _loc_2.low | _loc_3 << _loc_4;
                return _loc_2;
            }
            _loc_4 = _loc_4 + 7;
        }
        if (_loc_3 >= 128)
        {
            _loc_3 = _loc_3 & 127;
            _loc_2.low = _loc_2.low | _loc_3 << _loc_4;
            _loc_2.high = _loc_3 >>> 4;
        }
        else
        {
            _loc_2.low = _loc_2.low | _loc_3 << _loc_4;
            _loc_2.high = _loc_3 >>> 4;
            return _loc_2;
        }
        _loc_4 = 3;
        while (true)
        {
            
            _loc_3 = input.readUnsignedByte();
            if (_loc_4 < 32)
            {
                if (_loc_3 >= 128)
                {
                    _loc_2.high = _loc_2.high | (_loc_3 & 127) << _loc_4;
                }
                else
                {
                    _loc_2.high = _loc_2.high | _loc_3 << _loc_4;
                    break;
                }
            }
            _loc_4 = _loc_4 + 7;
        }
        return _loc_2;
    }

    public static function read_TYPE_INT32(input:IDataInput) : int
    {
        return int(read_TYPE_UINT32(input));
    }

    public static function read_TYPE_UINT64(input:IDataInput) : UInt64
    {
        var _loc_3:uint = 0;
        var _loc_2:* = new UInt64();
        var _loc_4:uint = 0;
        while (true)
        {
            
            _loc_3 = input.readUnsignedByte();
            if (_loc_4 == 28)
            {
                break;
            }
            else if (_loc_3 >= 128)
            {
                _loc_2.low = _loc_2.low | (_loc_3 & 127) << _loc_4;
            }
            else
            {
                _loc_2.low = _loc_2.low | _loc_3 << _loc_4;
                return _loc_2;
            }
            _loc_4 = _loc_4 + 7;
        }
        if (_loc_3 >= 128)
        {
            _loc_3 = _loc_3 & 127;
            _loc_2.low = _loc_2.low | _loc_3 << _loc_4;
            _loc_2.high = _loc_3 >>> 4;
        }
        else
        {
            _loc_2.low = _loc_2.low | _loc_3 << _loc_4;
            _loc_2.high = _loc_3 >>> 4;
            return _loc_2;
        }
        _loc_4 = 3;
        while (true)
        {
            
            _loc_3 = input.readUnsignedByte();
            if (_loc_4 < 32)
            {
                if (_loc_3 >= 128)
                {
                    _loc_2.high = _loc_2.high | (_loc_3 & 127) << _loc_4;
                }
                else
                {
                    _loc_2.high = _loc_2.high | _loc_3 << _loc_4;
                    break;
                }
            }
            _loc_4 = _loc_4 + 7;
        }
        return _loc_2;
    }

    public static function read_TYPE_UINT32(input:IDataInput) : uint
    {
        var _loc_4:uint = 0;
        var _loc_2:uint = 0;
        var _loc_3:uint = 0;
        while (true)
        {
            
            _loc_4 = input.readUnsignedByte();
            if (_loc_3 < 32)
            {
                if (_loc_4 >= 128)
                {
                    _loc_2 = _loc_2 | (_loc_4 & 127) << _loc_3;
                }
                else
                {
                    _loc_2 = _loc_2 | _loc_4 << _loc_3;
                    break;
                }
            }
            else
            {
                while (input.readUnsignedByte() >= 128)
                {
                    
                }
                break;
            }
            _loc_3 = _loc_3 + 7;
        }
        return _loc_2;
    }

    public static function read_TYPE_FIXED64(input:IDataInput) : Int64
    {
        input.endian = Endian.LITTLE_ENDIAN;
        var _loc_2:* = new Int64();
        _loc_2.low = input.readUnsignedInt();
        _loc_2.high = input.readInt();
        return _loc_2;
    }

    public static function read_TYPE_FIXED32(input:IDataInput) : int
    {
        input.endian = Endian.LITTLE_ENDIAN;
        return input.readInt();
    }

    public static function read_TYPE_SFIXED64(input:IDataInput) : Int64
    {
        var _loc_2:Int64 = null;
        _loc_2 = read_TYPE_FIXED64(input);
        var _loc_3:* = _loc_2.low;
        var _loc_4:* = _loc_2.high;
        _loc_2.low = ZigZag.decode64low(_loc_3, _loc_4);
        _loc_2.high = ZigZag.decode64high(_loc_3, _loc_4);
        return _loc_2;
    }

    public static function read_TYPE_DOUBLE(input:IDataInput) : Number
    {
        input.endian = Endian.LITTLE_ENDIAN;
        return input.readDouble();
    }

    public static function read_TYPE_ENUM(input:IDataInput) : int
    {
        return read_TYPE_INT32(input);
    }

    public static function read_TYPE_SINT32(input:IDataInput) : int
    {
        return ZigZag.decode32(read_TYPE_UINT32(input));
    }

    public static function skip(input:IDataInput, wireType:uint) : void
    {
        var _loc_3:uint = 0;
        switch(wireType)
        {
            case WireType.VARINT:
            {
                while (input.readUnsignedByte() > 128)
                {
                    
                }
                break;
            }
            case WireType.FIXED_64_BIT:
            {
                input.readInt();
                input.readInt();
                break;
            }
            case WireType.LENGTH_DELIMITED:
            {
                _loc_3 = read_TYPE_UINT32(input);
                while (_loc_3 != 0)
                {
                    
                    input.readByte();
                    _loc_3 = _loc_3 - 1;
                }
                break;
            }
            case WireType.FIXED_32_BIT:
            {
                input.readInt();
                break;
            }
            default:
            {
                throw new IOError("Invalid wire type: " + wireType);
                break;
            }
        }
    }

}
}
