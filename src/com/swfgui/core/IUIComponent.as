package com.swfgui.core
{
	import com.swfgui.interfaces.IDisposable;

	public interface IUIComponent extends IDisplayObject, ILayoutable, IDisposable
	{
		function setView(view:Object):void;
		
		function get autoLayout():Boolean;
		function set autoLayout(value:Boolean):void;
		
		function get autoWidth():Boolean;
		function set autoWidth(value:Boolean):void;
		
		function get autoHeight():Boolean;
		function set autoHeight(value:Boolean):void;

		function get enabled():Boolean;
		function set enabled(value:Boolean):void;

		function get toolTip():String;
		function set toolTip(value:String):void;
		
		function get toolTipHandler():Object;
		function set toolTipHandler(value:Object):void;
	}
}