package com.swfgui.managers
{
	import flash.display.DisplayObject;

	public class DragManager
	{
		/**
		 * 直接拖动元件
		 * @default 
		 */
		public static const DIRECT:String = "direct";
		/**
		 * 赋值元件作为拖动图片
		 * @default 
		 */
		public static const SNAPSHOT:String = "snapshot";
		/**
		 * 根据元件外形，生成一个拖动框
		 * @default 
		 */
		public static const OUTLINE:String = "outline";
		
		private static var impl:IDragManagerImpl = new DragManagerImpl();
		
		public static function setImpl(instance:IDragManagerImpl):void
		{
			impl = instance;
		}
		
		
	}
}