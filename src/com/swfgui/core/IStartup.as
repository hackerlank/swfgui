package com.swfgui.core
{
	import com.swfgui.loader.SLoader;
	
	import flash.display.DisplayObject;

	public interface IStartup
	{
		/**
		 * Preloader通过反射new出主类实例，然后调用此函数，传入一些数据。
		 * @param config 配置文件中的配置
		 * @param sloader 预加载的资源
		 * @param loadingBar 进度条留给主类处理，因为主类初始化也需要时间，所以不是preload完毕以后立马删除进度条。
		 */
		function startup(config:Object, sloader:SLoader, loadingBar:DisplayObject):void;
	}
}