package com.swfgui.managers
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;

	public class ViewManager
	{
		private static var impl:IViewManagerImpl = new ViewManagerImpl();
		
		public static function setImpl(instance:IViewManagerImpl):void
		{
			impl = instance;
		}
		
		public static function getDefaultView(componentName:String):DisplayObject
		{
			return impl.getDefaultView(componentName);
		}
		
		public static function setDefaultViews(loaderInfo:LoaderInfo):void
		{
			impl.setDefaultViews(loaderInfo);
		}
	}
}