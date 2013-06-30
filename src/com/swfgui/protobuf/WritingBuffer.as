package com.swfgui.protobuf
{
import flash.errors.*;
import flash.utils.*;

final public class WritingBuffer extends ByteArray
{
    private var _slices:ByteArray;

    public function WritingBuffer()
    {
        _slices = new ByteArray();
		_slices.endian = Endian.LITTLE_ENDIAN;
		this.endian = Endian.LITTLE_ENDIAN;
    }

    public function toNormal(output:IDataOutput) : void
    {
        var _loc_3:uint = 0;
        if (_slices.length % 8 != 0)
        {
            throw new IllegalOperationError();
        }
        _slices.position = 0;
        var _loc_2:uint = 0;
        while (_slices.bytesAvailable > 0)
        {
            
            _loc_3 = _slices.readUnsignedInt();
            if (_loc_3 > _loc_2)
            {
                output.writeBytes(this, _loc_2, _loc_3 - _loc_2);
            }
            else if (_loc_3 < _loc_2)
            {
                throw new IllegalOperationError();
            }
            _loc_2 = _slices.readUnsignedInt();
        }
        if (_loc_2 < length)
        {
            output.writeBytes(this, _loc_2);
        }
    }

    public function beginBlock() : uint
    {
        _slices.writeUnsignedInt(position);
        var _loc_1:* = _slices.length;
        if (_loc_1 % 8 != 4)
        {
            throw new IllegalOperationError();
        }
        _slices.writeDouble(0);
        _slices.writeUnsignedInt(position);
        return _loc_1;
    }

    public function endBlock(beginSliceIndex:uint) : void
    {
        if (_slices.length % 8 != 0)
        {
            throw new IllegalOperationError();
        }
        _slices.writeUnsignedInt(position);
        _slices.position = beginSliceIndex + 8;
        var _loc_2:* = _slices.readUnsignedInt();
        _slices.position = beginSliceIndex;
        _slices.writeUnsignedInt(position);
        WriteUtils.write_TYPE_UINT32(this, position - _loc_2);
        _slices.writeUnsignedInt(position);
        _slices.position = _slices.length;
        _slices.writeUnsignedInt(position);
    }

}
}
