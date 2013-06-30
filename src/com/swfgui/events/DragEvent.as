package com.swfgui.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class DragEvent extends Event
	{
		/**
		 * 开始拖动元件（可中断）
		 */
		public static const DRAG_START:String="dragStart";
		
		/**
		 * 拖动过程中每帧都触发
		 */
		public static const DRAG_ING:String="dragIng";
		
		/**
		 * 停止拖动元件（可中断）
		 */
		public static const DRAG_STOP:String="dragStop";
		
		/**
		 * 有元件拖动到自己之上
		 */
		public static const DRAG_ENTER:String="dragEnter";
		
		/**
		 * 有元件拖离自己
		 */
		public static const DRAG_EXIT:String="dragExit";
		
		/**
		 * 有元件拖放到自己身上
		 */
		public static const DRAG_DROP:String="dragDrop";
		
		/**
		 * 元件的拖动操作完成
		 */
		public static const DRAG_COMPLETE:String="dragComplete";
		
		private var _dragTarget:DisplayObject;
		private var _dragData:Object;
		
		public function DragEvent(type:String, dragTarget:DisplayObject, dragData:Object=null, 
								  bubbles:Boolean=false, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			_dragTarget = dragTarget;
			_dragData = dragData;
		}
		
		override public function clone():Event
		{
			return new DragEvent(type, dragTarget, bubbles, cancelable);
		}

		/**
		 * 要拖动的目标元件
		 */
		public function get dragTarget():DisplayObject
		{
			return _dragTarget;
		}

		public function get dragData():Object
		{
			return _dragData;
		}
	}
}