package com.swfgui.protobuf
{
import flash.errors.*;
import flash.utils.*;

import com.swfgui.msg.GameMsg;

public class Message extends Object implements IMessage
{
	public var retCode:int;//0 正常  其他 错误，错误以后，就不解析后面的内容了

    public function Message()
    {
    }

    public function writeToBuffer(output:WritingBuffer) : void
    {
        throw new IllegalOperationError("Not implemented.");
    }

    public function toString() : String
    {
        return messageToString(this);
    }

    final public function writeExternal(output:IDataOutput) : void
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
    
    private static function messageToString(aa:*):String
    {
    	return "";
    }

}
}
