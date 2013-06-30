package com.swfgui.managers
{
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;

	[Event(name="dragStart", type="com.swfgui.events.DragEvent")]

	[Event(name="dragIng", type="com.swfgui.events.DragEvent")]

	[Event(name="dragStop", type="com.swfgui.events.DragEvent")]

	[Event(name="dragEnter", type="com.swfgui.events.DragEvent")]

	[Event(name="dragExit", type="com.swfgui.events.DragEvent")]

	[Event(name="dragDrop", type="com.swfgui.events.DragEvent")]

	[Event(name="dragComplete", type="com.swfgui.events.DragEvent")]

	/**
	 * 拖动主要有两种：位置的移动，数据的移动。比如，拖动window组件是位置的移动；从list1往list2里面拖动，则是数据的移动；
	 * Sprite的startDrag倾向于前者，Flex的DragManager倾向于后者，此类两种拖动都支持。还可以同时拖动多个。
	 * @author llj
	 */
	public interface IDragManagerImpl extends IEventDispatcher
	{
		/**
		 * 开始拖动
		 * @param target 要拖动的元件，不要求是交互元件
		 * @param dragImage 拖动时显示的图像，可以是DragManager中的DIRECT、SNAPSHOT或OUTLINE，
		 * 也可以是一个DisplayObject，默认OUTLINE，显示一个拖动矩形框
		 * @param bounds 拖动的范围，坐标系为dragImage的父容器
		 * @param dragData 拖动相关的数据，可以据此判断是否能接受拖动的释放
		 * @param params 后面三个函数的参数
		 * @param onDragStart 拖动开始时候执行
		 * @param onDragStop 拖动停止时候执行
		 * @param onDragIng 拖动过程中每帧都执行
		 * @param lockCenter 是否以物体中心点为拖动的点
		 * @param imageAlpha dragImage的alpha值，默认0.5
		 */
		function startDrag(target:DisplayObject, 
			dragImage:Object = "outline",
			bounds:Rectangle = null, 
			dragData:Object = null,
			params:Array = null, 
			onDragStart:Function = null,
			onDragStop:Function = null,
			onDragIng:Function = null,
			lockCenter:Boolean = false,
			imageAlpha:Number = 0.5):void;
		
		function stopDrag(target:DisplayObject):void;
		
		/**
		 * 可以在DragEvent.DRAG_ENTER里面调用，表示可以接受拖拽释放
		 * @param target
		 * @param cursor 接受时显示的光标指示
		 */
		function acceptDragDrop(target:DisplayObject, cursor:DisplayObject=null):void;
		
		/**
		 * 可以在DragEvent.DRAG_ENTER里面调用，表示可以拒绝拖拽释放
		 * @param target
		 * @param cursor 拒绝时显示的光标指示
		 */
		function rejectDragDrop(target:DisplayObject, cursor:DisplayObject=null):void;
		
		/**
		 * 注册以后，元件就可以拖动了
		 * @param trigger 触发target开始拖动的元件，比如一个window组件，鼠标按下title栏的时候开始拖动，
		 * 那么，title就是trigger，window就是target
		 */
		function register(trigger:DisplayObject,
			target:DisplayObject = null, 
			dragImage:Object = "outline",
			bounds:Rectangle = null, 
			dragData:Object = null,
			params:Array = null, 
			onDragStart:Function = null,
			onDragStop:Function = null,
			onDragIng:Function = null,
			lockCenter:Boolean = false,
			imageAlpha:Number = 0.5):void;
		
		/**
		 * 取消注册，要不然target不能dispose
		 * @param trigger
		 */
		function unregister(trigger:DisplayObject):void;
	}
}