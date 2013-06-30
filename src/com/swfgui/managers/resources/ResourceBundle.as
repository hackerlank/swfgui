package com.swfgui.managers.resources
{
	import com.swfgui.controls.LoadingBar;
	import com.swfgui.debug.Logger;
	import com.swfgui.loader.SLoader;
	import com.swfgui.loader.SLoaderEvent;
	import com.swfgui.utils.ArrayUtil;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.net.URLLoader;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	/**
	 * 顺序加载资源，提供加载进度信息，供进度条使用,
	 * 缓存所有已加载的资源。
	  * @author llj
	 */
	public class ResourceBundle implements IResourceManager
	{
		public var multiLoadCount:int = 2;
		
		protected var loaderInfos:Dictionary = new Dictionary();
		protected var curLoaders:Array = [];
		protected var waitLoaders:Array = [];
		
		private var _baseUrl:String;
		private var _revisionList:Dictionary;
		private var _loadingBar:LoadingBar;
		
		public function ResourceBundle()
		{

		}
		
		public function hasResource(resourceName:String):Boolean
		{
			return getResource(resourceName) != null;
		}
		
		/**
		 * 根据资源的名字，返回的可能是Class、显示对象等，而getClass只返回Class
		 * @param resourceName
		 * @return 
		 */
		public function getResource(resourceName:String):*
		{
			var resArr:Array = resourceName.split("#");
			var swf:String = resArr[0];
			var symbol:String = resArr[1];
			var item:Item = loaderInfos[swf] as Item;
			var info:LoaderInfo;
			if(item)
			{
				if(item.loader is Loader)
				{
					info = Loader(item.loader).contentLoaderInfo;
				}
				else if(item.loader is URLLoader)
				{
					return URLLoader(item.loader).data;
				}
			}
			
			if(!info)
			{
				return null;
			}
			
			if(!symbol)
			{
				//跨域加载的图片，info.content == null
				return info.content ? info.content : info.loader;
			}
			
			if (info.applicationDomain && info.applicationDomain.hasDefinition(symbol))
			{
				//反射查找类定义
				return info.applicationDomain.getDefinition(symbol);
			}
			else if (info.content && info.content.hasOwnProperty(symbol))
			{
				//查找对象的属性
				return info.content[symbol];
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * 调用一次，资源使用计数减1，为0后删除资源，
		 * @param resourceName
		 */
		public function releaseResource(resourceName:String):void
		{
			var url:String = fixUrl(resourceName);
			var item:Item = loaderInfos[url];
			if(!item)
			{
				return;
			}
			item.useCount--;
			if(!item.cache && item.useCount <= 0)
			{
				item.sloader.unload(item.url);
				delete loaderInfos[url];
			}
		}
		
		/**
		 * 删除资源，不管有没有被使用
		 * @param resourceName
		 */
		public function removeResource(resourceName:String):void
		{
			var url:String = fixUrl(resourceName);
			var item:Item = loaderInfos[url];
			if(item)
			{
				item.sloader.unload(item.url);
				delete loaderInfos[url];
			}
		}
		
		/**
		 * 添加完毕后会调用sloader.clear()
		 * @param sloader
		 * @param cache
		 */
		public function addResource(sloader:SLoader, cache:Boolean=true):void
		{
			for(var url:String in sloader.loaderList)
			{
				loaderInfos[url] = new Item(url, sloader.loaderList[url], sloader, cache);
			}
			
			//因为加载使用了缓存，load.loaderList和load.loaderInfos不完备，为避免用户使用错误，索性统一清空
			//sloader.clear();
		}
		
		/**
		 * 清空已经加载的资源
		 */
		public function removeAllResource():void
		{
			var item:Item;
			for(var p:Object in loaderInfos)
			{
				item = loaderInfos[p];
				item.sloader.unload(item.url);
				//item.sloader.clear();
				delete loaderInfos[p];
			}
		}
		
		public function getClass(resourceName:String):Class
		{
			return getResource(resourceName) as Class;
		}
		
		public function getNewClass(resourceName:String):Object
		{
			var c:Class = getClass(resourceName);
			return c ? new c() : null;
		}
		
		public function getString(resourceName:String):String
		{
			var v:* = getResource(resourceName);
			return v is Class ? String(new v()) : v as String;
		}
		
		public function getXML(resourceName:String):XML
		{
			var v:* = getResource(resourceName);
			return XML(v is Class ? new v() : v);
		}
		
		public function getJSON(resourceName:String):Object
		{
			try
			{
				return JSON.parse(getString(resourceName));
			}
			catch(e:Error)
			{
				Logger.Warning(this, "json解析错误，资源：" + resourceName + "\n" + e.message);
				return null;
			}
			
			return null;
		}
		
		public function getDisplayObject(resourceName:String):DisplayObject
		{
			var v:* = getResource(resourceName);
			return v is Class ? new v() as DisplayObject : v as DisplayObject;
		}
		
		public function getBitmapData(resourceName:String):BitmapData
		{
			var v:* = getResource(resourceName);
			return v is Class ? new v() as BitmapData : v as BitmapData;
		}
		
		public function getMovieClip(resourceName:String):MovieClip
		{
			var v:* = getResource(resourceName);
			return v is Class ? new v() as MovieClip : v as MovieClip;
		}
		
		public function hasLoaded(url:String):Boolean
		{
			var item:Item = loaderInfos[fixUrl(url)];
			return item && item.sloader.content;
		}
		
		public function loadOne(url:String, 
						 cache:Boolean = false, 
						 showLoadingBar:Boolean = false, 
						 params:Array = null, 
						 onComplete:Function = null, 
						 onError:Function = null, 
						 onProgress:Function = null):SLoader
		{
			if(!url || url == "")
			{
				Logger.Warning(this, "loadOne, url没有内容");
				return null;
			}

			if(url.lastIndexOf("#") > 0)
			{
				url = url.split("#")[0];
			}
			
			//检查已加载的
			var item:Item = loaderInfos[url];
			if(item)
			{
				if(cache)
				{
					item.cache = true;
				}
				completeLater(item.sloader, params, onComplete);
				
				return item.sloader;
			}
			
			//检查正在加载的
			var loaderItem:LoaderItem;
			for each(loaderItem in curLoaders)
			{
				if(ArrayUtil.hasItem(url, loaderItem.urls))
				{
					if(cache)
					{
						loaderItem.cacheList[url] = true;
					}
					if(onComplete != null)
					{
						loaderItem.sloader.addEventListener(SLoaderEvent.COMPLETE, 
							function(e:SLoaderEvent):void
							{
								e.sloader.removeEventListener(SLoaderEvent.COMPLETE, 
									arguments.callee);
								onComplete.apply(null, params);
							});
					}
					
					return loaderItem.sloader;
				}
			}
			
			var loader:SLoader = new SLoader();
			loader.baseUrl = baseUrl;
			loader.revisionList = revisionList;
			startLoad(new LoaderItem(loader, [url], cache, 
				showLoadingBar, params, onComplete, onError, onProgress));
			
			return loader;
		}
		
		public function loadMany(urls:Array, 
						  cache:Boolean = false, 
						  showLoadingBar:Boolean = false, 
						  params:Array = null, 
						  onComplete:Function = null, 
						  onError:Function = null, 
						  onProgress:Function = null):SLoader
		{
			if(!urls || urls.length == 0)
			{
				Logger.Warning(this, "loadMany, urls没有内容");
				return null;
			}
			
			var loader:SLoader = new SLoader();
			loader.baseUrl = baseUrl;
			loader.revisionList = revisionList;
			
			var newUrls:Array = [];
			var waitLoader:SLoader;
			
			for each(var res:String in urls)
			{
				if(!res || res == "")
				{
					continue;
				}
				if(res.lastIndexOf("#") > 0)
				{
					res = res.split("#")[0];
				}
				//剔除已加载的
				if(loaderInfos[res])
				{
					if(cache)
					{
						loaderInfos[res].cache = true;
					}
					continue;
				}
				//剔除即将加载的
				var isWait:Boolean = false;
				for each(var li:LoaderItem in curLoaders)
				{
					if(ArrayUtil.hasItem(res, li.urls))
					{
						isWait = true;
						waitLoader = li.sloader;
						break;
					}
				}
				//剔除重复的
				if(!isWait && !ArrayUtil.hasItem(res, newUrls))
				{
					newUrls.push(res);
				}
			}
			
			if(newUrls.length > 0)
			{
				var loaderItem:LoaderItem = new LoaderItem(loader, newUrls, cache, 
					showLoadingBar, params, onComplete, onError, onProgress);
				if(waitLoader)
				{
					waitLoaders.push(loaderItem);
				}
				else
				{
					startLoad(loaderItem);
				}
			}
			else if(waitLoader)
			{
				//剔除了已经加载、重复的，剩下的就是等待，返回最后一个等待的。
				//如果要等待多个，会不会出错？因为返回的是最后一个等待
				return waitLoader;
			}
			else
			{
				completeLater(loader, params, onComplete);
			}
			
			return loader;
		}
		
		private function fixUrl(url:String):String
		{
			var n:int = url.lastIndexOf("#");
			if(n > 0)
			{
				return url.substring(0, n);
			}
			
			return url;
		}
		
		private function completeLater(loader:SLoader, params:Array, onComplete:Function):void
		{
			setTimeout(onCompleteLater, 30, loader, params, onComplete);
		}
		
		private function onCompleteLater(loader:SLoader, params:Array, onComplete:Function):void
		{
			loader.dispatchEvent(new SLoaderEvent(SLoaderEvent.COMPLETE, loader));
			if(onComplete != null)
			{
				onComplete.apply(null, params);
			}
		}
		
		private function startLoad(loaderItem:LoaderItem):void
		{
			if(curLoaders.length >= multiLoadCount)
			{
				//等待下次加载
				waitLoaders.push(loaderItem);
			}
			else
			{
				//立即加载
				curLoaders.push(loaderItem);
				loaderItem.sloader.addEventListener(SLoaderEvent.COMPLETE, onLoadComplete);
				if(loaderItem.urls.length == 1)
				{
					//防止只有一个资源的时候，加载出错而又不触发完成事件
					loaderItem.sloader.addEventListener(SLoaderEvent.ERROR, onLoadError);
				}
				loaderItem.startLoad();
			}
		}
		
		private function onLoadError(event:SLoaderEvent):void
		{
			event.sloader.removeEventListener(SLoaderEvent.COMPLETE, onLoadComplete);
			event.sloader.removeEventListener(SLoaderEvent.ERROR, onLoadError);
			ArrayUtil.deleteItemByProperty("sloader", event.sloader, curLoaders);
			
			if(waitLoaders.length > 0)
			{
				var n:int = multiLoadCount > waitLoaders.length ? 
					waitLoaders.length : multiLoadCount;
				for(var i:int = 0; i < n; i++)
				{
					startLoad(waitLoaders[i] as LoaderItem);
				}
				waitLoaders.splice(0, n);
			}
		}
		
		private function onLoadComplete(event:SLoaderEvent):void
		{
			var load:SLoader = event.sloader;
			load.removeEventListener(SLoaderEvent.COMPLETE, onLoadComplete);
			load.removeEventListener(SLoaderEvent.ERROR, onLoadError);
			var li:LoaderItem = ArrayUtil.deleteItemByProperty("sloader", load, curLoaders) as LoaderItem;
			
			for(var url:String in load.loaderList)
			{
				loaderInfos[url] = new Item(url, load.loaderList[url], load, li.cacheList[url]);
			}
			
			//因为加载使用了缓存，load.loaderList和load.loaderInfos不完备，为避免用户使用错误，索性统一清空
			//load.clear();
			
			if(waitLoaders.length > 0)
			{
				var n:int = multiLoadCount > waitLoaders.length ? 
					waitLoaders.length : multiLoadCount;
				for(var i:int = 0; i < n; i++)
				{
					startLoad(waitLoaders[i] as LoaderItem);
				}
				waitLoaders.splice(0, n);
			}
		}

		public function get baseUrl():String
		{
			return _baseUrl;
		}

		public function set baseUrl(value:String):void
		{
			_baseUrl = value;
		}

		public function get revisionList():Dictionary
		{
			return _revisionList;
		}

		public function set revisionList(value:Dictionary):void
		{
			_revisionList = value;
		}

		public function get loadingBar():LoadingBar
		{
			return _loadingBar;
		}

		public function set loadingBar(value:LoadingBar):void
		{
			_loadingBar = value;
		}
		
		public function registerFileType(fileExtension:String, fileDataformat:String, 
										 alwaysCache:Boolean=false):void
		{
			//todo 待实现
			SLoader.fileTypes[fileExtension.toLowerCase()] = fileDataformat;
		}

	}
}

import com.swfgui.loader.SLoader;

import flash.display.LoaderInfo;
import flash.utils.Dictionary;

class Item
{
	public var url:String;
	public var loader:Object;
	public var sloader:SLoader;
	public var useCount:int;
	public var cache:Boolean;
	
	public function Item(url:String, loader:Object, sloader:SLoader, cache:Boolean=false)
	{
		this.url = url;
		this.loader = loader;
		this.sloader = sloader;
		this.cache = cache;
	}
}

class LoaderItem
{
	public var sloader:SLoader;
	public var urls:Array;
	public var cacheList:Dictionary;
	public var showLoadingBar:Boolean;
	public var params:Array;
	public var onComplete:Function;
	public var onError:Function;
	public var onProgress:Function;
	
	public function LoaderItem(sloader:SLoader, 
							   urls:Array, 
							   cache:Boolean = false, 
							   showLoadingBar:Boolean = false, 
							   params:Array = null, 
							   onComplete:Function = null,
							   onError:Function = null, 
							   onProgress:Function = null)
	{
		this.sloader = sloader;
		this.urls = urls;
		this.showLoadingBar = showLoadingBar;
		this.params = params ? params : [];
		this.onComplete = onComplete;
		this.onError = onError;
		this.onProgress = onProgress;
		
		cacheList = new Dictionary();
		for each(var url:String in urls)
		{
			cacheList[url] = cache;
		}
	}
	
	public function startLoad():void
	{
		sloader.loadMany(urls, params, onComplete, null, onError, onProgress);
	}
}