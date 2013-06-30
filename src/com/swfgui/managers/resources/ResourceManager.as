package com.swfgui.managers.resources
{
	import com.swfgui.controls.LoadingBar;
	import com.swfgui.loader.SLoader;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;

	/**
	 * 参见IResourceManager
	 * @author llj
	 */
	public class ResourceManager
	{
		private static var impl:IResourceManager = new ResourceBundle();
		
		public static function setImpl(instance:IResourceManager):void
		{
			impl = instance;
		}
		
		public static function get baseUrl():String
		{
			return impl.baseUrl;
		}
		
		public static function set baseUrl(value:String):void
		{
			impl.baseUrl = value;
		}

		public static function get revisionList():Dictionary
		{
			return impl.revisionList;
		}
		
		public static function set revisionList(value:Dictionary):void
		{
			impl.revisionList = value;
		}
		
		public static function get loadingBar():LoadingBar
		{
			return impl.loadingBar;
		}
		
		public static function set loadingBar(value:LoadingBar):void
		{
			impl.loadingBar = value;
		}
		
		public static function registerFileType(fileExtension:String, fileDataformat:String, 
												alwaysCache:Boolean=false):void
		{
			impl.registerFileType(fileExtension, fileDataformat, alwaysCache);
		}
		
		public static function hasResource(resourceName:String):Boolean
		{
			return impl.hasResource(resourceName);
		}
		
		public static function getResource(resourceName:String):*
		{
			return impl.getResource(resourceName);
		}
		
		public static function releaseResource(resourceName:String):void
		{
			impl.releaseResource(resourceName);
		}
		
		public static function removeResource(resourceName:String):void
		{
			impl.removeResource(resourceName);
		}
		
		public static function addResource(sloader:SLoader, cache:Boolean=true):void
		{
			impl.addResource(sloader, cache);
		}
		
		public static function removeAllResource():void
		{
			impl.removeAllResource();
		}
		
		public static function loadOne(url:String, 
						 params:Array = null, 
						 onComplete:Function = null, 
						 cache:Boolean = false, 
						 showLoadingBar:Boolean = false,
						 onError:Function = null, 
						 onProgress:Function = null):SLoader
		{
			return impl.loadOne(url, cache, showLoadingBar, params, 
				onComplete, onError, onProgress);
		}
		
		public static function loadMany(urls:Array, 
						  params:Array = null, 
						  onComplete:Function = null, 
						  cache:Boolean = false, 
						  showLoadingBar:Boolean = false,
						  onError:Function = null, 
						  onProgress:Function = null):SLoader
		{
			return impl.loadMany(urls, cache, showLoadingBar, params, 
				onComplete, onError, onProgress);
		}

		public static function getClass(resourceName:String):Class
		{
			return impl.getClass(resourceName);
		}

		public static function getNewClass(resourceName:String):Object
		{
			return impl.getNewClass(resourceName);
		}

		public static function getString(resourceName:String):String
		{
			return impl.getString(resourceName);
		}
		
		public static function getXML(resourceName:String):XML
		{
			return impl.getXML(resourceName);
		}
		
		public static function getJSON(resourceName:String):Object
		{
			return impl.getJSON(resourceName);
		}

		public static function getDisplayObject(resourceName:String):DisplayObject
		{
			return impl.getDisplayObject(resourceName);
		}
		
		public static function getBitmapData(resourceName:String):BitmapData
		{
			return impl.getBitmapData(resourceName);
		}
		
		public static function getMovieClip(resourceName:String):MovieClip
		{
			return impl.getMovieClip(resourceName);
		}
	}

}