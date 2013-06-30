package com.swfgui.managers
{
	import com.swfgui.core.Application;
	import com.swfgui.debug.Logger;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * 应用的程序的层级管理
	 * @author llj
	 */
	public class SystemManager extends EventDispatcher
	{
		//按层级排列
		private var _application:Application;
		private var _popupLayer:Sprite;
		private var _toolTipLayer:Sprite;
		private var _debugLayer:Sprite;
		
		
		private static var _instance:SystemManager;
		
		public static function get instance():SystemManager
		{		
			return _instance ? _instance : (_instance = new SystemManager());
		}
		
		public function SystemManager()
		{
			_popupLayer = new Sprite();
			_popupLayer.mouseEnabled = false;
			
			_toolTipLayer = new Sprite();
			_toolTipLayer.mouseEnabled = false;
			
			_debugLayer = new Sprite();
			_debugLayer.mouseEnabled = false;var s:Event = new Event(Event.RESIZE);
		}
		
		private function initLayer(parent:DisplayObjectContainer):void
		{
			//parent.addChild(_application);
			parent.addChild(_popupLayer);
			parent.addChild(_toolTipLayer);
			parent.addChild(_debugLayer);
		}
		
		/**
		 * 弹窗窗口层
		 * @return 
		 */
		public function get popupLayer():Sprite
		{
			return _popupLayer;
		}

		/**
		 * 提示层
		 * @return 
		 */
		public function get toolTipLayer():Sprite
		{
			return _toolTipLayer;
		}

		/**
		 * debug弹窗层，最上层，不受模态窗口影响
		 * @return 
		 */
		public function get debugLayer():Sprite
		{
			return _debugLayer;
		}
		
		public function get application():Application
		{
			return _application;
		}
		
		public function set application(value:Application):void
		{
			if(!value || !value.parent)
			{
				Logger.Warning(this, "setted Application is null or not add to stage");
				return;
			}
			
			if(_application == value)
			{
				return;
			}
			
			//Application在最底层
			_application = value;
			initLayer(_application.parent);
		}

	}
}