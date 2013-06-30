package com.swfgui.managers
{
	import flash.display.DisplayObject;
	
	public interface IToolTipManagerImpl
	{
		function get enabled():Boolean;
		function set enabled(value:Boolean):void;

		function set hideTimeout(value:Number):void;
		function get hideTimeout():Number;

		function get showDelay():Number;
		function set showDelay(value:Number):void;

		/**
		 * 注册toolTip到target上，toolTip类型可以是：IToolTip、DisplayObject。
		 * @param target
		 * @param toolTip
		 */
		function registerToolTip(target:DisplayObject, toolTip:DisplayObject):void;
		
		/**
		 * 从target上删除toolTip，返回删除了的toolTip
		 * @param target
		 */
		function deleteToolTipFrom(target:DisplayObject):DisplayObject;
	}
}