package com.swfgui.managers
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;

	/**
	 *
	 * @author llj
	 *
	 */
	public class ToolTipManager extends EventDispatcher
	{
		public function ToolTipManager()
		{
			
		}

		private static var impl:IToolTipManagerImpl = new ToolTipManagerImpl();

		public static function setImpl(instance:IToolTipManagerImpl):void
		{
			impl = instance;
		}

		public static function registerToolTip(target:DisplayObject, toolTip:DisplayObject):void
		{
			impl.registerToolTip(target, toolTip);
		}

		public static function deleteToolTipFrom(target:DisplayObject):DisplayObject
		{
			return impl.deleteToolTipFrom(target);
		}
		
		public static function get enabled():Boolean
		{
			return impl.enabled;
		}

		public static function set enabled(value:Boolean):void
		{
			impl.enabled = value;
		}
		
		public static function get showDelay():Number
		{
			return impl.showDelay;
		}

		public static function set showDelay(value:Number):void
		{
			impl.showDelay = value;
		}
		
		public static function get hideTimeout():Number
		{
			return impl.hideTimeout;
		}

		public static function set hideTimeout(value:Number):void
		{
			impl.hideTimeout = value;
		}
	}
}