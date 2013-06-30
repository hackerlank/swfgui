package com.swfgui.core
{
	import flash.display.DisplayObjectContainer;

	/**
	 * 容器的布局器，mesure方法是刷新容器中单个组件的布局；updateDisplayList方法是
	 * 刷新容器中所有组件的布局。
	 * @author llj
	 */
	public interface ILayout
	{
		/**
		 * 根据child的坐标、宽高、约束和布局器的特性，来刷新child的布局信息（坐标或宽高）
		 * @param child
		 */
		function updateLayout(child:UIComponent):void;
		
		/**
		 * 刷新container容器中所有子组件的布局信息（坐标或宽高）
		 * @param container
		 */
		function updateDisplayList(container:DisplayObjectContainer, unscaledWidth:Number, unscaledHeight:Number):void;
	}
}