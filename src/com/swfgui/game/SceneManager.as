package com.swfgui.game
{
	import com.swfgui.core.Application;
	import com.swfgui.managers.PopUpManager;
	import com.swfgui.utils.display.DisplayUtil;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	/**
	 * 场景切换管理，保证只有一个场景在容器中
	 * @author llj
	 */
	public class SceneManager
	{
		public static var sceneContainer:DisplayObjectContainer;
		private static var lastScene:DisplayObject;
		private static var _mainScene:DisplayObject;
		private static var curScene:DisplayObject;
		
		public static function enterScene(scene:DisplayObject):void
		{
			if(!scene)
			{
				return;
			}
			lastScene = curScene;
			curScene = scene;
			DisplayUtil.safeRemoveChild(curScene);
			PopUpManager.removeAllPopUp();
			if(!sceneContainer)
			{
				sceneContainer = Application.instance;
			}
			sceneContainer.addChild(scene);
		}
		
		public static function enterMainScene(value:DisplayObject):void
		{
			_mainScene = value;
			enterScene(value);
		}
		
		public static function exitScene(scene:DisplayObject=null):void
		{
			if(scene != _mainScene)
			{
				enterScene(_mainScene);
			}
		}
		
		public static function returnPreScene():void
		{
			enterScene(lastScene);
		}
	}
}

