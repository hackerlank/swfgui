package com.swfgui.loader
{
	import com.swfgui.core.IStartup;
	import com.swfgui.debug.Logger;
	import com.swfgui.serialization.json.Json;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;

	/**
	 * 执行过程：（加载主程序，加载配置文件->加载进度条）->加载资源->反射并实例化主类，然后启动。
	 * 如果想在preloader中embed配置文件、进度条，可以继承或重写此类。
	 * 如果不允许动态加载资源（如ios），则可以把资源embed到主程序中。
	 * @author llj
	 */
	public class Preloader extends MovieClip
	{
		/**
		 * 主类名称
		 */
		public var mainClassName:String;
		protected var configUrl:String="assets/conf/config.js";
		public var configObj:Object;
		/**
		 * 进度条，可以是任何显示对象，也可以实现ILoadingBar
		 */
		public var loadingBar:DisplayObject;

		private var isMainLoaded:Boolean;
		private var isLoadingBarLoaded:Boolean;

		public function Preloader()
		{
			super();

			if (stage)
			{
				onAddToStage();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			}
		}

		protected function onAddToStage(event:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			Logger.Log(this, "Start at bytesLoaded/bytesTotal = " + 
				loaderInfo.bytesLoaded + "/" + loaderInfo.bytesTotal);

			if (loaderInfo.bytesLoaded == loaderInfo.bytesTotal)
			{
				isMainLoaded = true;
			}
			else
			{
				//监听主程序加载
				loaderInfo.addEventListener(Event.COMPLETE, onMainComplete);
				loaderInfo.addEventListener(ProgressEvent.PROGRESS, onMainProgress);
			}

			//加载配置文件
			var sloader:SLoader=new SLoader();
			
			//setTimeout(sloader.loadOne,1000,configUrl, [sloader], onConfigComplete);
			sloader.loadOne(configUrl, [sloader], onConfigComplete);
		}

		protected function onMainProgress(event:ProgressEvent):void
		{
			if (loadingBar is ILoadingBar)
			{
				ILoadingBar(loadingBar).update(loaderInfo.url, 
					loaderInfo.bytesLoaded, loaderInfo.bytesTotal, 1, 1);
			}
		}

		//主程序加载完成
		protected function onMainComplete(event:Event):void
		{trace("onMainComplete");
			loaderInfo.removeEventListener(Event.COMPLETE, onMainComplete);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onMainProgress);
			isMainLoaded=true;
			if (isLoadingBarLoaded)
			{
				loadRes();
			}
		}

		//配置文件加载完毕
		private function onConfigComplete(sloader:SLoader):void
		{trace("onConfigComplete");
			try
			{
				configObj=Json.deserialize(sloader.contentText);
				mainClassName=configObj.preload.mainClass;
				var barLoader:SLoader=new SLoader();
				barLoader.useCurrentDomain=true;
				barLoader.loadOne(configObj.preload.loadingBar, [barLoader], onLoadingBarComplete);
			}
			catch (e:Error)
			{
				Logger.Warning(this, e.message);
			}
		}

		//进度条加载完毕
		private function onLoadingBarComplete(sloader:SLoader):void
		{trace("onLoadingBarComplete");
			loadingBar=sloader.contentDisplay;
			onStageResize();
			stage.addChild(loadingBar);
			stage.addEventListener(Event.RESIZE, onStageResize);
			isLoadingBarLoaded=true;
			if (isMainLoaded)
			{
				loadRes();
			}
		}

		private function onStageResize(e:Event=null):void
		{
			loadingBar.x=(stage.stageWidth - loadingBar.width) * 0.5;
			loadingBar.y=(stage.stageHeight - loadingBar.height) * 0.5;
		}

		protected function loadRes():void
		{
			var urls:Array=[];
			for each (var urlItem:Object in configObj.resources)
			{
				urls.push(urlItem.url);
			}
			var resLoader:SLoader=new SLoader();
			resLoader.useCurrentDomain=true;
			resLoader.loadMany(urls, [resLoader], onResComplete, null, null, onResProgress);
		}
		
		private function onResProgress(sloader:SLoader):void
		{
			if (loadingBar is ILoadingBar)
			{
				ILoadingBar(loadingBar).update(sloader.url, sloader.loaderInfo.bytesLoaded, 
					sloader.loaderInfo.bytesTotal, sloader.curLoadIndex + 1, sloader.totalLoadCount);
			}
		}

		//资源加载完成
		protected function onResComplete(sloader:SLoader):void
		{trace("onResComplete");
			var mainClass:Class = getDefinitionByName(mainClassName) as Class;
			var main:DisplayObject = new mainClass() as DisplayObject;
			if (main is IStartup)
			{
				(main as IStartup).startup(configObj, sloader, loadingBar);
			}

			parent.removeChild(this);
		}
	}
}