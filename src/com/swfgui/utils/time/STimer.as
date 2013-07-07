package com.swfgui.utils.time
{
	import com.swfgui.interfaces.IDisposable;
	import com.swfgui.queue.MethodQueueElement;
	
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	/**
	 * 扩展的Timer，会修正省电模式Timer次数减少的问题
	 * @author llj
	 * 
	 */
	public class STimer extends Timer implements IDisposable
	{
		private static var timeout:Dictionary = new Dictionary();
		private static var timeoutIndex:uint;
		
		public static function setTimeout(closure:Function, delay:Number, ... arguments):uint
		{
			var stimer:STimer = new STimer(delay, 1, null, null, closure, arguments);
			stimer.start();
			timeoutIndex++;
			timeout[timeoutIndex] = stimer;
			return timeoutIndex;
		}
		
		public static function clearTimeout(id:uint):void
		{
			var stimer:STimer = timeout[id];
			if(stimer)
			{
				stimer.dispose();
			}
		}
		
		private var prevTime:int;
		private var onTimer:MethodQueueElement;
		private var onTimerComplete:MethodQueueElement;
		
		public function STimer(delay:Number, repeatCount:int=0, 
							   onTimer:Function = null, onTimerArgs:Array=null, 
							   onTimerComplete:Function = null, onTimerCompleteArgs:Array=null)
		{
			super(delay, repeatCount);
			this.onTimer = new MethodQueueElement(onTimer, onTimerArgs, false);
			this.onTimerComplete = new MethodQueueElement(onTimerComplete, onTimerCompleteArgs);
		}
		
		private var _hasDisposed:Boolean;
		
		public function get hasDisposed():Boolean
		{
			return _hasDisposed;
		}
		
		public function dispose():void
		{
			if(hasDisposed)
			{
				return;
			}
			
			this.removeEventListener(TimerEvent.TIMER,timerHandler);
			this.removeEventListener(TimerEvent.TIMER_COMPLETE,timerCompleteHandler);
			
			onTimer.clear();
			onTimerComplete.clear();
		}
		
		override public function start():void
		{
			this.addEventListener(TimerEvent.TIMER,timerHandler);
			this.addEventListener(TimerEvent.TIMER_COMPLETE,timerCompleteHandler);
			
			this.prevTime = getTimer();
			
			super.start();
		}
		
		protected function timerHandler(event:TimerEvent):void
		{
			while (getTimer() - prevTime >= delay)
			{
				prevTime += delay;
				onTimer.call();
			}
		}
		
		protected function timerCompleteHandler(event:TimerEvent):void
		{
			stop();
			onTimerComplete.call();
			dispose();
		}
	}
}