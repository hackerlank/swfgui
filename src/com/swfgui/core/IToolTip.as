package com.swfgui.core
{
	import com.swfgui.interfaces.IDisposable;

	public interface IToolTip extends IDisplayObject, IDisposable
	{
		function get text():String;
		function set text(value:String):void;
	}
}