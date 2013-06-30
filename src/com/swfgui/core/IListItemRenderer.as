package com.swfgui.core
{
	import com.swfgui.interfaces.IDisposable;
	
	import flash.display.DisplayObject;

	public interface IListItemRenderer extends IDisplayObject, IDisposable
	{
		/**
		 * 绑定的数据
		 */
		function get data():Object;
		function set data(value:Object):void;
		
		/**
		 * data在dataProvider中的索引 
		 */
		function get dataIndex():int;
		function set dataIndex(value:int):void;
		
		/**
		 * item在List中的索引
		 */
//		function get itemIndex():int;
//		function set itemIndex(value:int):void;
		
		function get selected():Boolean;
		function set selected(value:Boolean):void;
		
		function get view():DisplayObject;
	}
}