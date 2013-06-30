package com.swfgui.controls
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import com.swfgui.core.UIComponent;
	import com.swfgui.managers.SystemManager;
	
	public class Cursor extends UIComponent
	{
		private var _curTarget:InteractiveObject;
		private var _delayDisplayTime:int;
		private var timer:Timer;
		private var label:Label;
		
		public function Cursor(viewSource:Object=null)
		{
			super(viewSource);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			this.mouseChildren = false;
			this.mouseEnabled = false;
			timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		override public function dispose():void
		{
			if(hasDisposed)
			{
				return;
			}
			
			if(this.parent)
			{
				this.parent.removeChild(this);
			}
			
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			
			super.dispose();
		}
		
		override protected function updateProperties():void
		{
			super.updateProperties();
			
			if(label)
			{
				label.width = label.textWidth + 10;
				label.height = label.textHeight + 6;
				
				this.graphics.clear();
				this.graphics.beginFill(0xffff00, 0.8);
				this.graphics.drawRoundRect(0,0, label.width + 6, label.height + 6, 10, 10);
				this.graphics.endFill();
			}
		}
		
		private function onTimer(e:TimerEvent):void
		{
			show();
			timer.stop();
		}
		
		public function show():void
		{
			updateTooltip();
			SystemManager.instance.toolTipLayer.addChild(this);
			//this.addEventListener(Event.ENTER_FRAME, onEnterframe);
		}
		
		private function onEnterframe(e:Event):void
		{
			if(!_curTarget.hitTestPoint(_curTarget.x + _curTarget.mouseX, _curTarget.y + _curTarget.mouseY))
			{
				hide();
			}
		}
		
		public function hide():void
		{
			if(this.parent)
			{
				this.parent.removeChild(this);
			}
			
			timer.stop();
			if(this.hasEventListener(Event.ENTER_FRAME))
			{
				this.removeEventListener(Event.ENTER_FRAME, onEnterframe);
			}
		}
		
		public function updateTooltip():void
		{
			var globalPt:Point = _curTarget.localToGlobal(new Point(_curTarget.mouseX, _curTarget.mouseY));
			this.x = globalPt.x;
			this.y = globalPt.y;
		}
		
		public function get curTarget():InteractiveObject
		{
			return _curTarget;
		}

		public function set curTarget(value:InteractiveObject):void
		{
			_curTarget = value;
			
			if(!_curTarget)
			{
				return;
			}
			
			_curTarget.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
			_curTarget.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
			_curTarget.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			if(!this.enabled)
			{
				return;
			}
			
			updateTooltip();
		}
		
		private function onMouseRollOver(e:MouseEvent):void
		{
			if(!this.enabled)
			{
				return;
			}
			
			if(_delayDisplayTime > 0)
			{
				timer.start();
			}
			else
			{
				show();
			}
		}
		
		private function onMouseRollOut(e:MouseEvent):void
		{
			hide();
		}

		public function get delayDisplayTime():int
		{
			return _delayDisplayTime;
		}

		public function set delayDisplayTime(value:int):void
		{
			_delayDisplayTime = value;
			if(_delayDisplayTime < 0)
			{
				_delayDisplayTime = 0;
			}
			
			timer.delay = _delayDisplayTime;
		}
	}
}