package com.swfgui.effects
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import com.swfgui.interfaces.IDisposable;

	public class McEffect implements IDisposable
	{
		private var effectOver:Function;
		private var effectOverArg:Array;
		private var mc:MovieClip;
		
		public function McEffect(mc:MovieClip, effectOver:Function = null, effectOverArg:Array=null)
		{
			if(!mc)
			{
				return;
			}
			
			this.mc = mc;
			mc.gotoAndStop(1);
			
			this.effectOver = effectOver;
			this.effectOverArg = effectOverArg;
		}
				
		public function dispose():void
		{
			if(hasDisposed)
			{
				return;
			}
			
			if(mc)
			{
				mc.stop();				
				mc.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				mc = null;
			}
			
			effectOver = null;
			effectOverArg = null;
		}
		
		private var _hasDisposed:Boolean;
		
		public function get hasDisposed():Boolean
		{
			return _hasDisposed;
		}
		
		public function play(stage:DisplayObjectContainer, x:int, y:int):void
		{
			if(!mc || !stage)
			{
				stopEffect();
				return;
			}
			mc.x = x;
			mc.y = y;			
			stage.addChild(mc);
			//mc.play();
			mc.gotoAndPlay(1);
			mc.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
				
		protected function onEnterFrame(event:Event):void
		{
			if(mc.currentFrame == mc.totalFrames)
			{
				stopEffect();
			}
		}
		
		private function stopEffect():void
		{
			if(mc && mc.parent)
			{
				mc.parent.removeChild(mc);
			}
			
			if(effectOver != null)
			{
				effectOver.apply(null, effectOverArg);
			}
						
			dispose();
		}
	}	
}