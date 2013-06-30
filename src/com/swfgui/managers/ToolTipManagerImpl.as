package com.swfgui.managers
{
	import com.swfgui.core.Application;
	import com.swfgui.core.IUIComponent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	internal class ToolTipManagerImpl extends EventDispatcher implements IToolTipManagerImpl
	{
		private const TIMER_INTERVAL:int = 50;
		private const TOOLTIP_OFFSET:int = 20;
		
		private var targetList:Dictionary;// target->toolTip
		private var showList:Dictionary;//target->showDelay count
		private var hideList:Dictionary;//target->hideTimeout count
		private var _enabled:Boolean = true;
		private var _showDelay:Number = 300;
		private var _hideTimeout:Number = 0;
		private var timer:Timer;

		public function ToolTipManagerImpl()
		{
			targetList = new Dictionary(true);
			showList = new Dictionary(true);
			hideList = new Dictionary(true);
			timer = new Timer(TIMER_INTERVAL);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		/**
		 * 把toolTip注册到目标上，当鼠标移到目标上，会自动显示，移出则会隐藏。
		 * @param target
		 * @param toolTip
		 */
		public function registerToolTip(target:DisplayObject, toolTip:DisplayObject):void
		{
			if(enabled && target && toolTip)
			{
				targetList[target] = toolTip;
				addEvents(target);
				
				var pt:Point = target.localToGlobal(new Point(target.mouseX, target.mouseY));
				if(target && target.stage && target.hitTestPoint(pt.x, pt.y))
				{
					show(target);
				}
			}
		}
		
		//todo 应该加个渐出特效
		/**
		 * 删除目标上的toolTip，并返回该toolTip
		 * @param target
		 * @return 返回删除的toolTip
		 */
		public function deleteToolTipFrom(target:DisplayObject):DisplayObject
		{
			if(!target || !targetList[target])
			{
				return null;
			}
			
			hide(target);
			removeEvents(target);
			
			var rtv:DisplayObject = targetList[target];
			delete targetList[target];
			delete showList[target];
			
			return rtv;
		}

		private function addEvents(target:DisplayObject):void
		{
			target.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
			target.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
			target.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			target.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		private function removeEvents(target:DisplayObject):void
		{
			target.removeEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
			target.removeEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
			target.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			target.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		private function getTooltip(target:Object):DisplayObject
		{
			var rtv:DisplayObject;
			//可以完全从targetList里面获取toolTip，为了性能考虑才这么做的
			if(target is IUIComponent)
			{
				rtv = (target as IUIComponent).toolTipHandler as DisplayObject;
			}
			
			return rtv ? rtv : targetList[target];
		}
		
		protected function onTimer(event:TimerEvent):void
		{
			var target:Object;
			for (target in showList)
			{
//				if(--showList[target] <= 0)
//				{
//					show(target);
//				}
			}
			
			for (target in hideList)
			{
//				if(--hideList[target] <= 0)
//				{
//					hide(target);
//				}
			}
		}
		
		private function onMouseRollOver(e:MouseEvent):void
		{
			if (!this.enabled)
			{
				return;
			}
		
			if (showDelay >= TIMER_INTERVAL)
			{
				showList[e.currentTarget] =  Math.round(showDelay / TIMER_INTERVAL);
				timer.start();
			}
			else
			{
				show(e.currentTarget);
			}
		}

		private function onMouseRollOut(e:MouseEvent):void
		{
			hide(e.currentTarget);
		}

		private function onMouseMove(e:MouseEvent):void
		{
			if (!this.enabled)
			{
				return;
			}

			updateToolTipPosition(e.currentTarget as DisplayObject, 
			getTooltip(e.currentTarget));
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			hide(event.target);
		}

		private function show(target:Object):void
		{
			delete showList[target];
			
			var dis:DisplayObject = target as DisplayObject;
			var toolTip:DisplayObject = getTooltip(target);
			var pt:Point = dis.localToGlobal(new Point(dis.mouseX, dis.mouseY));
			if(dis && toolTip && dis.stage && dis.hitTestPoint(pt.x, pt.y))
			{
				updateToolTipPosition(dis, toolTip);
				Application.instance.toolTipLayer.addChild(toolTip);
				
				if(hideTimeout >= TIMER_INTERVAL)
				{
					hideList[target] = Math.round(hideTimeout / TIMER_INTERVAL);
				}
				else
				{
					delete hideList[target];
				}
			}
			else
			{
				delete hideList[target];
			}
		}
		
		public function hide(target:Object):void
		{
			delete hideList[target];
			
			var toolTip:DisplayObject = getTooltip(target);
			if(toolTip && toolTip.parent)
			{
				toolTip.parent.removeChild(toolTip);
			}
		}
		
		public function updateToolTipPosition(target:DisplayObject, toolTip:DisplayObject):void
		{
			if(!target || !toolTip)
			{
				return;
			}
			
			var globalPt:Point = Application.instance.componentToApp(
				target, new Point(target.mouseX, target.mouseY));
			
			if(globalPt.x + toolTip.width + TOOLTIP_OFFSET > Application.instance.width)
			{
				if(globalPt.x - toolTip.width - TOOLTIP_OFFSET < 0)
				{
					toolTip.x = (Application.instance.width - toolTip.width) * 0.5;
				}
				else
				{
					toolTip.x = globalPt.x - toolTip.width - TOOLTIP_OFFSET;
				}
			}
			else
			{
				toolTip.x = globalPt.x + TOOLTIP_OFFSET;
			}
			
			if(globalPt.y + toolTip.height + TOOLTIP_OFFSET > Application.instance.height)
			{
				if(globalPt.y - toolTip.height - TOOLTIP_OFFSET < 0)
				{
					toolTip.y = (Application.instance.height - toolTip.height) * 0.5;
				}
				else
				{
					toolTip.y = globalPt.y - toolTip.height - TOOLTIP_OFFSET;
				}
			}
			else
			{
				toolTip.y = globalPt.y + TOOLTIP_OFFSET;
			}
		}
		
		/**
		 * 禁用所有toolTip
		 * @return 
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			if(_enabled == value)
			{
				return;
			}
			
			_enabled = value;
			if(!value)
			{
				var target:Object;
				for(target in targetList)
				{
					hide(target);
				}
				
				for(target in showList)
				{
					delete showList[target];
				}
				
				timer.stop();
			}
		}
	
		/**
		 *  鼠标移动到目标上以后，延迟显示时间，默认300毫秒
		 *  @default 300
		 */
		public function get showDelay():Number
		{
			return _showDelay;
		}
		
		public function set showDelay(value:Number):void
		{
			_showDelay = value;
		}
		
		/**
		 * tooltip自动隐藏时间，默认0毫秒，不隐藏。
		 *  @default 0
		 */
		public function get hideTimeout():Number
		{
			return _hideTimeout;
		}
		
		public function set hideTimeout(value:Number):void
		{
			_hideTimeout = value;
		}

	}
}