package com.swfgui.core
{
	import flash.events.IEventDispatcher;

	/**
	 * 可布局元素接口
	 * @author DOM
	 */
	public interface ILayoutable extends IEventDispatcher
	{
		/**
		 * 指定此组件是否包含在父容器的布局中。若为false，则父级容器在测量和布局阶段都忽略此组件。默认值为true。
		 * 注意，visible属性与此属性不同，设置visible为false，父级容器仍会对其布局。
		 */		
		function get includeInLayout():Boolean;
		
		function set includeInLayout(value:Boolean):void;
		/**
		 * 距父级容器离左边距离
		 */		
		function get left():Number;
		
		function set left(value:Number):void;
		/**
		 * 距父级容器右边距离
		 */
		function get right():Number;
		
		function set right(value:Number):void;
		/**
		 * 距父级容器顶部距离
		 */
		function get top():Number;
		
		function set top(value:Number):void;
		/**
		 * 距父级容器底部距离
		 */		
		function get bottom():Number;
		
		function set bottom(value:Number):void;
		/**
		 * 在父级容器中距水平中心位置的距离
		 */		
		function get horizontalCenter():Number;
			
		function set horizontalCenter(value:Number):void;
		/**
		 * 在父级容器中距竖直中心位置的距离
		 */	
		function get verticalCenter():Number;
		
		function set verticalCenter(value:Number):void;
		
		/**
		 * 表示从注册点开始应用的对象的水平缩放比例（百分比）。默认注册点为 (0,0)。1.0 等于 100% 缩放。 
		 */		
		function get scaleX():Number;
		/**
		 * 表示从对象注册点开始应用的对象的垂直缩放比例（百分比）。默认注册点为 (0,0)。1.0 是 100% 缩放。
		 */		
		function get scaleY():Number;
		/**
		 * 组件的最大宽度,若设置了percentWidth,或同时设置left和right,则此属性无效。
		 */	
		function get maxWidth():Number;
		function set maxWidth(value:Number):void;
		/**
		 * 组件的最小宽度 
		 * 若设置了percentWidth,或同时设置left和right,则此属性无效。
		 * 若此属性设置为大于maxWidth的值时，则也无效。
		 */
		function get minWidth():Number;
		function set minWidth(value:Number):void;
		/**
		 * 组件的最大高度,若设置了percentHeight,或同时设置top和bottom,则此属性无效。
		 */
		function get maxHeight():Number;
		function set maxHeight(value:Number):void;
		/**
		 * 组件的最小高度
		 * 若设置了percentHeight,或同时设置top和bottom,则此属性无效。
		 * 若此属性设置为大于maxHeight的值时，则也无效
		 */
		function get minHeight():Number;
		function set minHeight(value:Number):void;
		/**
		 * 设置组件的布局宽高,此值应已包含scaleX,scaleY的值
		 */		
		function setLayoutBoundsSize(width:Number,height:Number):void;
		/**
		 * 设置组件的布局位置
		 */		
		function setLayoutBoundsPosition(x:Number,y:Number):void;
	}
}