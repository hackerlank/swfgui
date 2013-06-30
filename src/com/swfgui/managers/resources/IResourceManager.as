package com.swfgui.managers.resources
{
	import com.swfgui.controls.LoadingBar;
	import com.swfgui.loader.SLoader;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;

	public interface IResourceManager
	{
		function get baseUrl():String;
		function set baseUrl(value:String):void;
		
		/**
		 * [url] = 1234，加载时会自动加载后面：url?rev=1234
		 */
		function get revisionList():Dictionary;
		function set revisionList(value:Dictionary):void;
		
		function get loadingBar():LoadingBar;
		function set loadingBar(value:LoadingBar):void;
		
		/**
		 * 根据文件扩展名，注册文件类型，不区分大小写
		 * @param fileExtension 如swf、png、js
		 * @param fileDataformat 详见SLoaderDataFormat
		 */
		function registerFileType(fileExtension:String, fileDataformat:String, 
								  alwaysCache:Boolean=false):void;
		
		function hasResource(resourceName:String):Boolean;
		
		/**
		 * 根据资源的名字，返回的可能是Class、显示对象等，而getClass只返回Class
		 * @param resourceName
		 * @return 
		 */
		function getResource(resourceName:String):*;
		
		/**
		 * 调用一次，资源使用计数减1，为0后删除资源，
		 * @param resourceName
		 */
		function releaseResource(resourceName:String):void;
		
		/**
		 * 删除资源，不管有没有被使用
		 * @param resourceName
		 */
		function removeResource(resourceName:String):void;
		
		function addResource(sloader:SLoader, cache:Boolean=true):void;
		
		function removeAllResource():void;
		
		/**
		 * 
		 * @param url
		 * @param cache 为true时始终缓存，即使releaseResource，为false时，当releaseResource以后，
		 * 如果资源没有被使用，则删除。
		 * @param showLoadingBar
		 * @param params 如果有值，则作为后面三个函数的参数
		 * @param onComplete
		 * @param onError
		 * @param onProgress
		 * @return 
		 */
		function loadOne(url:String, 
						 cache:Boolean = false, 
						 showLoadingBar:Boolean = false, 
						 params:Array = null, 
						 onComplete:Function = null, 
						 onError:Function = null, 
						 onProgress:Function = null):SLoader;
		
		function loadMany(urls:Array, 
						  cache:Boolean = false, 
						  showLoadingBar:Boolean = false, 
						  params:Array = null, 
						  onComplete:Function = null, 
						  onError:Function = null, 
						  onProgress:Function = null):SLoader;
		
		function getClass(resourceName:String):Class;
		function getNewClass(resourceName:String):Object;
		
		function getString(resourceName:String):String;
		function getXML(resourceName:String):XML;
		function getJSON(resourceName:String):Object;
		
		function getDisplayObject(resourceName:String):DisplayObject;
		function getBitmapData(resourceName:String):BitmapData;
		function getMovieClip(resourceName:String):MovieClip;
		//function getBlitClip(resourceName:String, view:DisplayObject=null):BlitClip;
		
	}

}
