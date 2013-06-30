package com.swfgui.managers
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;

	public interface IViewManagerImpl
	{
		function getDefaultView(componentName:String):DisplayObject;
		function setDefaultViews(loaderInfo:LoaderInfo):void;
	}
}