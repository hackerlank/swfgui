package com.swfgui.protobuf
{
import flash.errors.*;
import flash.utils.*;


public class ExtensibleMessage extends Array implements IMessage
{

    public function ExtensibleMessage()
    {
    }

    public function writeToBuffer(output:WritingBuffer):void
    {
        throw new IllegalOperationError("Not implemented.");
    }

    public function toString():String
    {
        return "";//messageToString(this);
    }

    final public function writeExternal(output:IDataOutput):void
    {
        var wb:WritingBuffer = output as WritingBuffer;
        if (wb == null)
        {
            wb = new WritingBuffer();
            writeToBuffer(wb);
            wb.toNormal(output);
        }
        else
        {
            writeToBuffer(wb);
        }
    }

}
}
