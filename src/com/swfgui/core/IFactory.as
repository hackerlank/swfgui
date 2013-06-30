package com.swfgui.core
{
	import flash.display.DisplayObject;

	public interface IFactory
	{
		function newInstance(viewSource:Object=null):*;
	}
}