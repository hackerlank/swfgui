package com.swfgui.core
{
	import flash.geom.Rectangle;

	public interface IViewport
	{
	 	function get width():Number;
		function set width(value:Number):void;
			
		function get height():Number;
		function set height(value:Number):void;
		
	 	function get contentHeight():Number;
		function get contentWidth():Number;
		
		function get horizontalScrollPosition():Number;
		function set horizontalScrollPosition(value:Number):void;
		
		function get verticalScrollPosition():Number;
		function set verticalScrollPosition(value:Number):void;
		
	 	function get scrollRect():Rectangle;
		function set scrollRect(value:Rectangle):void;
	}
}