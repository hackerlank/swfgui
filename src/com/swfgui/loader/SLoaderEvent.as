package com.swfgui.loader
{
	import com.swfgui.loader.SLoader;
	
	import flash.events.Event;
	
	public class SLoaderEvent extends Event
	{
		public static const PROGRESS:String = "progress";
		public static const COMPLETE:String = "complete";
		public static const ERROR:String = "error";

		private var _sloader:SLoader;
		
		public function SLoaderEvent(type:String, sloader:SLoader)
		{
			super(type, false, false);
			
			_sloader = sloader;
		}
		
		override public  function clone():Event
		{
			return new SLoaderEvent(type, _sloader);
		}

		/**
		 * 发出事件的SLoader
		 * @default 
		 */
		public function get sloader():SLoader
		{
			return _sloader;
		}

		/**
		 * 当事件类型为ERROR时的错误描述信息
		 * @default 
		 */
		public function get errorText():String
		{
			return _sloader.errorText;
		}

		/**
		 * 当前加载资源的索引，从1开始
		 * @return 
		 */
		public function get curLoadIndex():int
		{
			return _sloader.curLoadIndex + 1;
		}

		/**
		 * 要加载的资源总数
		 * @return 
		 */
		public function get totalLoadCount():int
		{
			return _sloader.totalLoadCount;
		}

		/**
		 * 当前加载资源自身加载的百分比数，如58.9
		 * @return 
		 */
		public function get curLoadPercent():Number
		{
			return _sloader.curLoadPercent;
		}

	}
}