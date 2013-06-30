package com.swfgui.managers
{
	import com.swfgui.containers.PopUpWindow;
	import com.swfgui.core.Application;
	import com.swfgui.effects.Tween;
	import com.swfgui.interfaces.IDisposable;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	
	/**
	 * 弹出窗口管理，支持并行排列窗口
	 * @author llj
	 */
	public class PopUpManager
	{	
		//新窗口相对于老窗口的位置
		public static const POSITION_CENTER:int = 0;//直接放在上层
		public static const POSITION_LEFT:int = 1;//位于老窗口的左边
		public static const POSITION_RIGHT:int = 2;	//位于老窗口的右边
		
		/**
		 * 可以并存（同时打开）的窗口
		 * @default 
		 */
		public static const coexistWindow:Array = [
			
		];
		
		protected static var windowList:Array = [];
		protected static var windowListEx:Array = [];
		
		private static var isAddStageEvent:Boolean;
		private static var stageWidth:int;
		private static var stageHeight:int;		
		
		private static var modelShape:Sprite = new Sprite();
		private static var modelCount:int;
		
		public function PopUpManager()
		{
			
		}		
		
		/**
		 * 弹出顶级窗口
		 * @param window
		 * @param parent
		 * @param modal
		 * @param position 新窗口相对于老窗口的位置
		 */
		public static function addPopUp(window:DisplayObject, 
			parent:DisplayObject=null, 
			modal:Boolean = false, 
			position:int=-1):void
		{			
			if(!isAddStageEvent)
			{
				Application.instance.stage.addEventListener(Event.RESIZE, onStageResize);
				stageWidth = Application.instance.stageWidth;
				stageHeight = Application.instance.stageHeight;
			}
			
			//没有老窗口，直接打开
			if(windowList.length == 0)
			{	
				_addPopUp(window, modal, position);
				return;
			}
			
			//检查有没有打开过这个窗口
			var k:int;
			for each(var a:Array in windowList)
			{
				if(window == a[0])
				{
					if(!window.parent)
					{
						windowList.splice(k, 1);
						removeModal(a[2]);
						k--;
					}
					else
					{						
						return;
					}
				}
				k++;
			}
			
			var wnd1:*;
			var wnd:DisplayObject;
			
			//不可与任何窗口共存，关闭所有老窗口，然后打开
			var coexistWindowList:Array = getCoexistWindow(window);
			if(coexistWindowList.length == 0)
			{
				while(windowList.length > 0)
				{
					var arr:Array = windowList.pop();
					wnd = arr[0];
					_removePopUp(wnd, arr[2]);
				}
				
				_addPopUp(window, modal, position);
				return;
			}
			
			//关闭不可共存的老窗口
			for(var i:int = 0; i < windowList.length; i++)
			{
				wnd = windowList[i][0];
				var flag:Boolean;
				flag = false;
				for each(wnd1 in coexistWindowList)
				{
					if(wnd is wnd1)
					{
						flag = true;
					}
				}
				
				if(!flag)
				{
					var m:Boolean = windowList[i][2];
					windowList.splice(i, 1);
					_removePopUp(wnd, m);
					i--;
				}
			}
			
			Application.instance.popUpLayer.addChild(window);
			
			var diff:int = 5;
			
			if(windowList.length > 0)
			{
				//新窗口的位置取决于老窗口的位置
				if(position < 0)	
				{
					position = windowList[0][1];
					if(position == POSITION_LEFT)
					{
						position = POSITION_RIGHT;
					}
					else if(position == POSITION_RIGHT)
					{
						position = POSITION_LEFT;
					}
				}
				
				var wndArr:Array;
				//var centerPt:Point = new Point(Application.instance.stageWidth * 0.5, Application.instance.stageHeight * 0.5);
				var centerX:int;
				if(position == POSITION_LEFT)
				{					
					for each(wndArr in windowList)
					{
						wnd = wndArr[0];
						centerX = (Application.instance.stageWidth - wnd.width - window.width) * 0.5 + window.width;
						Tween.to(wnd, 0.5,{x:centerX + diff});						
					}
					Tween.to(window, 0.5, {x:centerX - window.width - diff});
				}
				else if(position == POSITION_RIGHT)
				{
					for each(wndArr in windowList)
					{
						wnd = wndArr[0];
						centerX = (Application.instance.stageWidth - wnd.width - window.width) * 0.5 + wnd.width;
						Tween.to(wnd, 0.5,{x:centerX - wnd.width - diff});						
					}
					Tween.to(window, 0.5, {x:centerX + diff});
				}
			}
			
			windowList.push([window, position, modal]);
		}
		
		private static function _addPopUp(window:DisplayObject,
										  modal:Boolean,
										  position:int):void
		{
			addModal(modal);
			Application.instance.popUpLayer.addChild(window);
			windowList.push([window, position, modal]);
		}
		
		private static function _removePopUp(wnd:DisplayObject, modal:Boolean):void
		{
			if(wnd is PopUpWindow)
			{
				(wnd as PopUpWindow).hide();
			}
			else
			{						
				removePopUp(wnd);
				if(wnd is IDisposable)
				{
					(wnd as IDisposable).dispose();
				}
			}
			
			removeModal(modal);
		}
		
		protected static function onStageResize(event:Event):void
		{
			var dx:int = (Application.instance.stage.stageWidth - stageWidth) * 0.5;
			var dy:int = (Application.instance.stage.stageHeight - stageHeight)*0.5;
			stageHeight = Application.instance.stage.stageHeight;
			stageWidth = Application.instance.stage.stageWidth;
			var num:int = Application.instance.popUpLayer.numChildren;
			
			for(var i:int = 0; i < num; i++)
			{
				var child:DisplayObject = Application.instance.popUpLayer.getChildAt(i);
				if(child == modelShape)
				{
					updateModal();
				}
				else
				{
					child.x += dx;
					child.y += dy;
				}
			}				
		}
		
		private static function addModal(modal:Boolean):void
		{
			if(!modal)
			{
				return;
			}
			updateModal();
			if(!modelShape.parent)
			{
				Application.instance.popUpLayer.addChildAt(modelShape, 0);
			}
			modelCount++;
		}
		
		private static function updateModal():void
		{
			modelShape.graphics.clear();
			modelShape.graphics.beginFill(0, 0.3);
			modelShape.graphics.drawRect(0,0,Application.instance.stage.stageWidth,
				Application.instance.stage.stageHeight);
			modelShape.graphics.endFill();
		}
		
		private static function removeModal(modal:Boolean):void
		{
			if(!modal)
			{
				return;
			}
			
			modelCount--;
			
			if(modelCount == 0 || (modelShape.parent && 
				Application.instance.popUpLayer.numChildren == 1) || 
				(windowList.length == 0 && windowListEx.length == 0))
			{
				modelCount = 0;
				if(modelShape.parent)
				{
					modelShape.parent.removeChild(modelShape);
				}
			}
		}
		
		/**
		 * 弹出顶级窗口，新老窗口不相互影响
		 * @param window
		 * @param parent
		 * @param modal
		 */
		public static function addPopUpEx(window:DisplayObject, 
										parent:DisplayObject=null, 
										modal:Boolean = false):void
		{
			//检查有没有打开过这个窗口
			var i:int;
			for each(var a:Array in windowListEx)
			{
				if(window == a[0])
				{
					if(!window.parent)
					{
						windowListEx.splice(i, 1);
						removeModal(a[1]);
						i--;
					}
					else
					{
						return;
					}
				}
				i++;
			}
			
			addModal(modal);
			Application.instance.popUpLayer.addChild(window);
			windowListEx.push([window, modal]);
		}
		
		private static function getCoexistWindow(target:DisplayObject):Array
		{
			var rtv:Array = [];
			for each(var a:Array in coexistWindow)
			{
				if(target instanceof a[0])
				{
					rtv.push(a[1]);
				}
				else if(target instanceof a[1])
				{
					rtv.push(a[0]);
				}
			}
			
			return rtv;
		}

		public static function centerPopUp(window:DisplayObject):void
		{
			window.x = (Application.instance.stageWidth - window.width) * 0.5;
			window.y = (Application.instance.stageHeight - window.height) * 0.5;
		}

		public static function bringToFront(window:DisplayObject):void
		{
			if (Application.instance.popUpLayer.contains(window))
			{
				Application.instance.popUpLayer.setChildIndex(window, 
					Application.instance.popUpLayer.numChildren - 1);
			}
		}


		public static function removePopUp(window:DisplayObject):void
		{
			if(!window)
			{
				return;
			}
			
			//从舞台上删除
			if (Application.instance.popUpLayer.contains(window))
			{
				Application.instance.popUpLayer.removeChild(window);
			}
			
			var i:int;
			var len:int = windowList.length;
			for (i = 0; i < len; i++)
			{
				var a:Array = windowList[i];
				if(a[0] == window)
				{
					//从列表中删除，删除模态
					windowList.splice(i, 1);
					removeModal(a[2]);
					break;
				}
			}

			var wnd:DisplayObject;
			if(windowList.length == 1)
			{
				wnd = windowList[0][0];
				
				Tween.to(wnd, 0.5, {x:(Application.instance.stageWidth - wnd.width) * 0.5, 
					y:(Application.instance.stageHeight - wnd.height) * 0.5});
			}
			else if(windowList.length > 1)
			{
				window = windowList[0][0];
				var position:int = windowList[0][1];
				var wndArr:Array;
				var centerX:int;
				var diff:int = 5;
				
				if(position == POSITION_LEFT)
				{					
					for(i = 1; i < windowList.length; i++)
					{
						wndArr = windowList[i];
						wnd = wndArr[0];
						centerX = (Application.instance.stageWidth - wnd.width - window.width) * 0.5 + window.width;
						Tween.to(wnd, 0.5,{x:centerX + diff});						
					}
					Tween.to(window, 0.5, {x:centerX - window.width - diff});
				}
				else if(position == POSITION_RIGHT)
				{
					for(i = 1; i < windowList.length; i++)
					{
						wndArr = windowList[i];
						wnd = wndArr[0];
						centerX = (Application.instance.stageWidth - wnd.width - window.width) * 0.5 + wnd.width;
						Tween.to(wnd, 0.5,{x:centerX - wnd.width - diff});						
					}
					Tween.to(window, 0.5, {x:centerX + diff});
				}
			}
		}
		
		/**
		 * 移除窗口，新老窗口不相互影响
		 * @param window
		 */
		public static function removePopUpEx(window:DisplayObject):void
		{
			if(!window)
			{
				return;
			}
			
			//从舞台上删除
			if (Application.instance.popUpLayer.contains(window))
			{
				Application.instance.popUpLayer.removeChild(window);
			}
			
			var len:int = windowListEx.length;
			for (var i:int = 0; i < len; i++)
			{
				var a:Array = windowListEx[i];
				if(a[0] == window)
				{
					//从列表中删除，删除模态
					windowListEx.splice(i, 1);
					removeModal(a[1]);
					break;
				}
			}
		}
		
		/**
		 * 删除所有弹出窗口，并Dispose
		 */
		public static function removeAllPopUp():void
		{
			windowList.length = 0;
			windowListEx.length = 0;
			modelCount = 0;
			removeModal(true);
			
			while(Application.instance.popUpLayer.numChildren)
			{
				var wnd:DisplayObject = Application.instance.popUpLayer.getChildAt(0);
				Application.instance.popUpLayer.removeChild(wnd);
				if(wnd is PopUpWindow)
				{
					(wnd as PopUpWindow).hide();
				}
				else
				{
					if(wnd is IDisposable)
					{
						(wnd as IDisposable).dispose();
					}
				}
			}
		}
	}
}