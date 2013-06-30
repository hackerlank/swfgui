package com.swfgui.core
{
	import flash.events.IEventDispatcher;

	/**
	 * 被滚动的内容可以是容器的所有子元件，TextField的文字内容，List的dataProvider等
	 * @author llj
	 */
	public interface IScrollable extends IEventDispatcher
	{
		/**
		 * 被滚动内容在水平方向上的最大位置
		 * @return 
		 */
		function get contentWidth():Number;//maxHScrollPosition():Number;
		function get contentHeight():Number;//minHScrollPosition():Number;
		
		/**
		 * 被滚动内容在垂直方向上的最大位置
		 * @return 
		 */
		function get viewportWidth():Number;//maxVScrollPosition():Number;
		function get viewportHeight():Number;//minVScrollPosition():Number;
		
		function get horizontalScrollPosition():Number;
		function set horizontalScrollPosition(value:Number):void;
		
		function get verticalScrollPosition():Number;
		function set verticalScrollPosition(value:Number):void;
		
		function get maxHorizontalScrollPosition():Number;
		function get maxVerticalScrollPosition():Number;
	}
}