package com.swfgui.managers
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.text.TextField;
	
	/**
	 * 提供获取组件的默认view的接口
	 * @author llj
	 */
	internal class ViewManagerImpl implements IViewManagerImpl
	{
		public function ViewManagerImpl()
		{
		}
		
		/**
		 * 
		 * @param componentName 组件类名
		 * @return 
		 */
		public function getDefaultView(componentName:String):DisplayObject
		{
			var rtv:DisplayObject;
			
			switch (componentName)
			{
				case "TextBaes":
				case "Label":
					rtv = new TextField();
					rtv.width = 100;
					rtv.height = 20;
					break;
				case "TextArea":
					rtv = new TextField();
					rtv.width = 200;
					rtv.height = 100;
					break;
				case "Alert":
					var cls:Class = loaderInfo.applicationDomain.getDefinition("Alert") as Class;
					if(cls)
					{
						rtv = new cls() as DisplayObject;
					}
					break;
				default:
					rtv = null;
					break;
			}
			
			return rtv;
		}
		
		private var loaderInfo:LoaderInfo;
		
		public function setDefaultViews(loaderInfo:LoaderInfo):void
		{
			this.loaderInfo = loaderInfo;
		}
	}
}