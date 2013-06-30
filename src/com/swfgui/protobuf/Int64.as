package com.swfgui.protobuf
{

final public class Int64 extends Object
{
    public var high:int;
    public var low:uint;

    public function Int64(low:uint = 0, high:int = 0)
    {
        this.low = low;
        this.high = high;
    }
	
	public static function ConvertNumbertoInt64(n:Number):Int64
	{
		return new Int64(int(n % 0x100000000), int(n / 0x100000000));
	}
	
	public static function ConvertString16toInt64(s16:String):Int64
	{
		var s:String = s16.replace("0x", "");
		var h:String = "0";
		var l:String = "0";
		
		if (s.length > 8)
		{
			h = s.substring(0, s.length - 8);
			l = s.substr(h.length);
		}
		else
		{
			l = s;
		}
		
		var n:Int64 = new Int64(int("0x" + l), int("0x" + h));
		return n;
	}
    
    public function Add(n:Number):void
    {
    	var offset_high:int=n/0x100000000;
    	var offset_low:uint=n-(offset_high * 0x100000000);
    	low += offset_low;
    	high+=offset_high;
    }
	
	public function toString():String
	{
		return toNumber().toString();
	}
	
	public function toNumber():Number
	{
		var n:Number = low + (high * 0x100000000);
		return n;
	}
	
	public function get isZero():Boolean
	{
		return low == 0 && high == 0;
	}
	
	public function CompareTo(n:Int64):Boolean
	{
		return n.high == this.high 
			&& n.low == this.low;
	}
	
	public function GreaterThan(n:Int64):Boolean
	{
		if (this.high > n.high)
			return true;
		else if (this.high < n.high)
			return false;
			
		if (this.low > n.low)
			return true;
			
		return false;
	}
	
	public function LessThan(n:Int64):Boolean
	{
		if (this.high < n.high)
			return true;
		else if (this.high > n.high)
			return false;
			
		if (this.low < n.low)
			return true;
			
		return false;
	}
}
}
