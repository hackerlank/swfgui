package com.swfgui.core
{
	import flash.events.IEventDispatcher;

	public interface IValidatable extends IEventDispatcher
	{
		function invalidateSize():void;
		function invalidateProperties():void;
		function invalidateDisplayList():void;
		
		function validateSize():void;
		function validateProperties():void;
		function validateDisplayList():void;
		
		function validateNow(onlyValidateNeeded:Boolean=false):void;
		
		/**
		 * 在显示列表的嵌套深度
		 */		
		function get nestLevel():int;
		function set nestLevel(value:int):void;
		/**
		 * 是否完成初始化。此标志只能由 LayoutManager 修改。
		 */		
		function get initialized():Boolean;
		function set initialized(value:Boolean):void;
		/**
		 * 一个标志，用于确定某个对象是否正在等待分派其updateComplete事件。此标志只能由 LayoutManager 修改。
		 */		
		function get updateCompletePendingFlag():Boolean;
		function set updateCompletePendingFlag(value:Boolean):void;
		/**
		 * 是否含有父级显示对象
		 */		
		function get hasParent():Boolean;
	}
}