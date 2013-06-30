package com.swfgui.protobuf
{

final public class UInt64 extends Object
{
    public var high:uint;
    public var low:uint;

    public function UInt64(low:uint = 0, high:uint = 0)
    {
        this.low = low;
        this.high = high;
    }

}
}
