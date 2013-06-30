package com.swfgui.protobuf
{
import flash.utils.*;

final public class Extension extends Object
{

    public function Extension()
    {
    }

    public static function packedRepeatedReadFunction(f:Function) : Function
    {
        return function (input:IDataInput, object:Array, tag:Tag) : void
        {
            var arr:Array = object[tag.number];
            if (arr == null)
            {
                arr = [];
                object[tag.number] = arr;
            }
            if (tag.wireType == WireType.LENGTH_DELIMITED)
            {
                ReadUtils.readPackedRepeated(input, f, arr);
            }
            else
            {
                arr.push(f(input));
            }
        }
    }

    public static function messageReadFunction(c:Class) : Function
    {
        return function (input:IDataInput, object:Array, tag:Tag) : void
        {
            var externalizable:IExternalizable = new c() as IExternalizable;
            ReadUtils.read_TYPE_MESSAGE(input, externalizable);
            object[tag.number] = externalizable;
        }
    }

    public static function writeFunction(wireType:uint, f:Function) : Function
    {
        return function (output:WritingBuffer, object:Array, fieldNumber:uint) : void
        {
            WriteUtils.writeTag(output, wireType, fieldNumber);
            f(output, object[fieldNumber]);
        }
    }

    public static function repeatedReadFunction(f:Function) : Function
    {
        return function (input:IDataInput, object:Array, tag:Tag) : void
        {
            var arr:Array = object[tag.number];
            if (arr == null)
            {
                arr = [];
                object[tag.number] = arr;
            }
            arr.push(f(input));
        }
    }

    public static function repeatedMessageReadFunction(c:Class) : Function
    {
        return function (input:IDataInput, object:Array, tag:Tag) : void
        {
            var arr:Array = object[tag.number];
            if (arr == null)
            {
                arr = [];
                object[tag.number] = arr;
            }
            var externalizable:IExternalizable = new c();
            ReadUtils.read_TYPE_MESSAGE(input, externalizable);
            arr.push(externalizable);
        }
    }

    public static function packedRepeatedWriteFunction(f:Function) : Function
    {
        return function (output:WritingBuffer, object:Array, fieldNumber:uint) : void
        {
            WriteUtils.writeTag(output, WireType.LENGTH_DELIMITED, fieldNumber);
            WriteUtils.writePackedRepeated(output, f, object[fieldNumber] as Array);
        }
    }

    public static function repeatedWriteFunction(wireType:uint, f:Function) : Function
    {
        return function (output:WritingBuffer, object:Array, fieldNumber:uint) : void
        {
            var arr:Array = object[fieldNumber];
            var i:int = 0;
            while (i < arr.length)
            {
                
                WriteUtils.writeTag(output, wireType, fieldNumber);
                f(output, arr[i]);
                i = i + 1;
            }
        }
    }

    public static function readFunction(f:Function) : Function
    {
        return function (input:IDataInput, object:Array, tag:Tag) : void
        {
            object[tag.number] = f(input);
        }
    }

}
}
