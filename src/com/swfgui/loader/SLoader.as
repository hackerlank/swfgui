package com.swfgui.loader
{
	import com.swfgui.debug.Logger;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	[Event(name="progress", type="com.swfgui.loader.SLoaderEvent")]

	[Event(name="complete", type="com.swfgui.loader.SLoaderEvent")]

	[Event(name="error", type="com.swfgui.loader.SLoaderEvent")]

	/**
	 * 方便的资源加载类，可顺序加载多个资源
	 * @author llj
	 */
	public class SLoader extends EventDispatcher
	{
		private static var _fileTypes:Dictionary;

		/**
		 * [文件扩展名] = SLoaderDataFormat.***
		 * @default
		 */
		public static function get fileTypes():Dictionary
		{
			if (!_fileTypes)
			{
				_fileTypes = new Dictionary();
				_fileTypes["swf"] = SLoaderDataFormat.DISPLAY;
				_fileTypes["png"] = SLoaderDataFormat.DISPLAY;
				_fileTypes["jpg"] = SLoaderDataFormat.DISPLAY;
				_fileTypes["gif"] = SLoaderDataFormat.DISPLAY;
				_fileTypes["xml"] = SLoaderDataFormat.TEXT;
				_fileTypes["js"] = SLoaderDataFormat.TEXT;
				_fileTypes["txt"] = SLoaderDataFormat.TEXT;
				_fileTypes["csv"] = SLoaderDataFormat.TEXT;
			}

			return _fileTypes;
		}

		/**
		 * 供用户临时存储数据用的
		 * @default
		 */
		public var userData:*;

		/**
		 * 资源的版本列表，放置浏览器缓存
		 * @default
		 */
		public var revisionList:Dictionary;

		public var baseUrl:String = null;

		private var _url:String;
		private var _urls:Array;

		private var _loader:Loader;
		private var _urlLoader:URLLoader;
		private var _dataFormat:String;
		
		private var _useCurrentDomain:Boolean = true;
		private var _checkPolicyFile:Boolean;

		private var _curLoadIndex:int;
		private var _isLoadComple:Boolean;

		private var _loaderInfo:LoaderInfo;
		private var _loaderList:Dictionary;

		private var params:Array;
		private var onComplete:Function;
		private var onOneComplete:Function;
		private var onError:Function;
		private var onProgress:Function;

		private var _errorText:String;
		/**
		 * 最好不要重复利用此类的实例，因为重复调用loadOne或loadMany可能会打断正在
		 * 加载的过程。
		 */
		public function SLoader()
		{

		}

		/**
		 * 停止加载，并清除已经加载的资源，相当于重置SLoader，
		 * 但不破坏已经加载资源的LoaderInfo。
		 */
		public function clear():void
		{
			try
			{
				if (_loader)
				{
					_loader.close();
					_loader = null;
				}
				if (_urlLoader)
				{
					_urlLoader.close();
					_urlLoader = null;
				}
			}
			catch (e:Error)
			{

			}
			
			_isLoadComple = false;
			_urls = null;
			_curLoadIndex = -1;
			_loaderInfo = null;
			_loaderList = null;

			clearFunc();
		}

		private function clearFunc():void
		{
			this.params = null;
			this.onComplete = null;
			this.onOneComplete = null
			this.onProgress = null;
			this.onError = null;
		}

		public function unload(url:String, stop:Boolean=true):void
		{
			var ld:Object = loaderList[url];
			if (ld)
			{
				if (ld is Loader)
				{
					Loader(ld).unload();
					if (stop)
					{
						Loader(ld).unloadAndStop();
					}
				}
				delete loaderList[url];
			}
		}

		public function unloadAll(stop:Boolean=true):void
		{
			for (var url:String in loaderList)
			{
				var ld:Object = loaderList[url];
				if (ld)
				{
					if (ld is Loader)
					{
						Loader(ld).unload();
						if (stop)
						{
							Loader(ld).unloadAndStop();
						}
					}
					delete loaderList[url];
				}
			}
		}

		/**
		 * 加载单个资源，如果加载出错不会触发SLoaderEvent.complete事件
		 * @param url 资源的地址
		 * @param params onComplete、onError和onProgress的回调参数
		 * @param onComplete 资源加载完成后调用，仅一次有效
		 * @param onError 资源加载发生错误后调用，仅一次有效
		 * @param onProgress 资源加载过程中调用，仅一次有效
		 */
		public function loadOne(url:String, 
			params:Array = null, 
			onComplete:Function = null, 
			onError:Function = null, 
			onProgress:Function = null):void
		{
			if (url && url != "")
			{
				loadMany([url], params, onComplete, null, onError, onProgress);
			}
			else
			{
				Logger.Warning(this, "无法加载空url");
			}
		}


		/**
		 * 顺序加载多个资源，即使其中有几个资源没有加载成功，也会触发SLoaderEvent.complete事件
		 * @param urls 资源的地址
		 * @param params onAllComplete、onOneComplete、onError和onProgress的回调参数
		 * @param onAllComplete 所有资源加载完成后调用，仅一次有效
		 * @param onOneComplete 单个资源加载完成后调用，仅一次有效
		 * @param onError 单个资源加载错误后调用，仅一次有效
		 * @param onProgress 单个资源加载过程中调用，仅一次有效
		 */
		public function loadMany(urls:Array, 
			params:Array = null, 
			onAllComplete:Function = null, 
			onOneComplete:Function = null, 
			onError:Function = null, 
			onProgress:Function = null):void
		{
			if (!urls || urls.length == 0)
			{
				Logger.Warning(this, "无法加载空urls");
				return;
			}

			//先重置所有
			clear();

			_urls = urls;
			this.params = params;
			this.onComplete = onAllComplete;
			this.onOneComplete = onOneComplete;
			this.onError = onError;
			this.onProgress = onProgress;

			_loaderList = new Dictionary();
			loadNext();
		}

		protected function loadNext():void
		{
			//全部加载完成
			if (curLoadIndex + 1 == _urls.length)
			{
				_isLoadComple = true;

				dispatchEvent(new SLoaderEvent(SLoaderEvent.COMPLETE, this));

				if (onComplete != null)
				{
					onComplete.apply(null, params);
				}

				//清除外部函数
				clearFunc();
				return;
			}

			_url = _urls[++_curLoadIndex];
			if (!url)
			{
				Logger.Warning(this, "无法加载空url");
				loadNext();
				return;
			}

			_errorText = "";
			_loaderInfo = null;
			_loader = null;
			_urlLoader = null;
			
			_dataFormat = getFileType(url);
			if (_dataFormat == SLoaderDataFormat.DISPLAY)
			{
				//这时候就给loaderinfo？
				//todo 似乎事件不能完全捕获异常，必须用try
				var loaderContext:LoaderContext;
				if (useCurrentDomain)
				{
					loaderContext = new LoaderContext(checkPolicyFile, ApplicationDomain.currentDomain, 
						Security.sandboxType == Security.REMOTE ? SecurityDomain.currentDomain : null);
				}
				else if(checkPolicyFile)
				{
					loaderContext = new LoaderContext(checkPolicyFile);
				}
				
				_loader = new Loader();
				_loaderInfo = loader.contentLoaderInfo;
				addEvents(_loaderInfo);
				_loader.load(new URLRequest(fixUrl(url)), loaderContext);
			}
			else
			{
				_urlLoader = new URLLoader();
				_urlLoader.dataFormat = _dataFormat;
				addEvents(_urlLoader);
				_urlLoader.load(new URLRequest(fixUrl(url)));
			}
		}

		private function fixUrl(url:String):String
		{
			if (revisionList && revisionList.hasOwnProperty(url))
			{
				url += (url.lastIndexOf("?") == -1 ? "?" : "&") + "rev=" + revisionList[url];
			}
			if (baseUrl)
			{
				url = baseUrl + url;
			}

			return url;
		}

		private function getFileType(url:String):String
		{
			var n:int = url.lastIndexOf(".");
			var m:int = url.lastIndexOf("?");
			var ext:String = n != -1 ? 
				url.substring(n + 1, m != -1 ? m : 2147483647).toLowerCase() : null;

			return ext && fileTypes[ext] ? fileTypes[ext] : SLoaderDataFormat.BINARY;
		}

		protected function addEvents(ld:IEventDispatcher):void
		{
			ld.addEventListener(Event.COMPLETE, onLoadCpt, false, 0, true);
			ld.addEventListener(IOErrorEvent.IO_ERROR, onIoErr, false, 0, true);
			ld.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true);
			ld.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
			if(ld is LoaderInfo)
			{
				LoaderInfo(ld).uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUnCaughtError);
			}
		}
		
		protected function removeEvents(ld:IEventDispatcher):void
		{
			ld.removeEventListener(Event.COMPLETE, onLoadCpt);
			ld.removeEventListener(IOErrorEvent.IO_ERROR, onIoErr);
			ld.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			ld.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			if(ld is LoaderInfo)
			{
				LoaderInfo(ld).uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUnCaughtError);
			}
		}

		protected function onLoadCpt(e:Event):void
		{
			Logger.Log(this, "成功加载:" + url);

			//e.target可能是LoaderInfo、URLLoader
			loaderList[url] = e.target is LoaderInfo ? LoaderInfo(e.target).loader : e.target;
			if(e.target is URLLoader)
			{
				URLLoader(e.target).close();
			}

			if (onOneComplete != null)
			{
				onOneComplete.apply(null, params);
			}

			removeEvents(e.target as IEventDispatcher);
			loadNext();
		}

		protected function onLoadProgress(e:Event):void
		{
			if(hasEventListener(SLoaderEvent.PROGRESS))
			{
				dispatchEvent(new SLoaderEvent(SLoaderEvent.PROGRESS, this));
			}

			if (onProgress != null)
			{
				onProgress.apply(null, params);
			}
		}

		protected function onIoErr(e:IOErrorEvent):void
		{
			_errorText = e.text;
			Logger.Warning(this, "IO错误，无法加载:" + url);
			errorHandler(e);
		}

		protected function onSecurityError(e:SecurityErrorEvent):void
		{
			_errorText = e.text;
			Logger.Warning(this, "安全限制，无法加载:" + url);
			errorHandler(e);
		}
		
		protected function onUnCaughtError(e:UncaughtErrorEvent):void
		{
			_errorText = e.text;
			Logger.Warning(this, "未知错误，无法加载:" + url);
			errorHandler(e);
		}
		
		private function errorHandler(e:Event):void
		{
			dispatchEvent(new SLoaderEvent(SLoaderEvent.ERROR, this));
			
			if (onError != null)
			{
				onError.apply(null, params);
			}
			
			removeEvents(e.target as IEventDispatcher);
			
			//只加载一个资源，如果失败，是不会触发完成事件的
			if (urls.length == 1)
			{
				clearFunc();
			}
			else
			{
				loadNext();
			}
		}

		/**
		 * 要加载的资源总数
		 * @return
		 */
		public function get totalLoadCount():int
		{
			return urls.length;
		}

		/**
		 * 当前加载到第几个资源，从0开始
		 * @default
		 */
		public function get curLoadIndex():int
		{
			return _curLoadIndex;
		}

		/**
		 * 当前加载资源自身加载的百分比数，如58.9
		 * @return
		 */
		public function get curLoadPercent():Number
		{
			if (loaderInfo)
			{
				return Math.floor(1000 * loaderInfo.bytesLoaded / loaderInfo.bytesTotal) * 0.1;
			}

			if (urlLoader)
			{
				return Math.floor(1000 * urlLoader.bytesLoaded / urlLoader.bytesTotal) * 0.1;
			}

			return 0.0;
		}

		/**
		 * 是否全部加载完成
		 * @return
		 */
		public function get isLoadComple():Boolean
		{
			return _isLoadComple;
		}

		public function get content():*
		{
			if (loader)
			{
				return loader.content;
			}

			if (urlLoader)
			{
				urlLoader.data;
			}

			return null;
		}

		/**
		 * 如果当前加载的是swf、图片等可视对象，则此值可用
		 * @return
		 */
		public function get contentDisplay():DisplayObject
		{
			return loader ? loader.content : null;
		}

		/**
		 * 如果当前加载的是swf，则此值可用
		 * @return
		 */
		public function get contentMovieClip():MovieClip
		{
			return loader ? loader.content as MovieClip : null;
		}

		/**
		 * 如果当前加载的是图片，则此值可用
		 * @return
		 */
		public function get contentBitmap():Bitmap
		{
			return loader ? loader.content as Bitmap : null;
		}

		/**
		 * 如果当前加载的是文本，则此值可用
		 * @return
		 */
		public function get contentText():String
		{
			return urlLoader ? urlLoader.data as String : null;
		}

		/**
		 * 如果当前加载的是二进制文件，则此值可用
		 * @return
		 */
		public function get contentBinary():ByteArray
		{
			return urlLoader ? urlLoader.data as ByteArray : null;
		}

		/**
		 * 如果当前加载资源的dataFormat==SLoaderDataFormat.DISPLAY，则此值可用
		 * @default
		 */
		public function get loader():Loader
		{
			return _loader;
		}

		/**
		 * 如果当前所加载资源的dataFormat==SLoaderDataFormat.DISPLAY，则此值可用
		 * @return
		 */
		public function get loaderInfo():LoaderInfo
		{
			return _loaderInfo;
		}

		/**
		 * 如果当前所加载资源的dataFormat是SLoaderDataFormat.TEXT、SLoaderDataFormat.BINARY,
		 * 则此值可用
		 * @return
		 */
		public function get urlLoader():URLLoader
		{
			return _urlLoader;
		}

		/**
		 * 当前加载的资源地址，如果所有资源都加载完成后，则是最后一个
		 * @default
		 */
		public function get url():String
		{
			return _url;
		}

		/**
		 * 所有要加载的资源地址
		 * @default
		 */
		public function get urls():Array
		{
			return _urls;
		}

		/**
		 * 所有已加载资源的Loader、URLLoader，
		 * [url]=Loader、URLLoader
		 * @return
		 */
		public function get loaderList():Dictionary
		{
			return _loaderList;
		}

		public function get errorText():String
		{
			return _errorText;
		}

		public function get useCurrentDomain():Boolean
		{
			return _useCurrentDomain;
		}

		public function set useCurrentDomain(value:Boolean):void
		{
			_useCurrentDomain = value;
		}

		public function get checkPolicyFile():Boolean
		{
			return _checkPolicyFile;
		}

		public function set checkPolicyFile(value:Boolean):void
		{
			_checkPolicyFile = value;
		}


	}
}