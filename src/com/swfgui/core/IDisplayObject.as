package com.swfgui.core
{
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.events.IEventDispatcher;


	/**
	 * 定义gui元件可显示对象
	 * @author llj
	 */
	public interface IDisplayObject extends IBitmapDrawable, IEventDispatcher
	{
		function get name():String;
		function set name(value:String):void;
		
		function get width():Number;
		function set width(value:Number):void;

		function get height():Number;
		function set height(value:Number):void;

		function get x():Number;
		function set x(value:Number):void;

		function get y():Number;
		function set y(value:Number):void;
		
		function get alpha():Number;
		function set alpha(value:Number):void;

		function get visible():Boolean;
		function set visible(value:Boolean):void;

		function get parent():DisplayObjectContainer;
	}
}