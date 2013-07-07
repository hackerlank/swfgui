package com.swfgui.controls
{
	import com.swfgui.core.UIComponent;
	import com.swfgui.events.TickEvent;
	import com.swfgui.math.SuperMath;
	import com.swfgui.queue.MethodQueueElement;
	import com.swfgui.utils.time.Tick;
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	/**
	 * view可以是一个TextField，或者一个mc，其中包含item0、item1、item2……，每个item也是
	 * 一个mc，包含10~12帧的位图序列：0 1 2 3 4 5 6 7 8 9 . -
	 * @author llj
	 */
	public class NumbericLabel extends UIComponent
	{
		public var minRollBitCount:int = 4;
		
		private var viewText:TextField;
		private var items:Array = [];
		private var _text:String = "";
		private var _value:Number = NaN;
		
		private var onComplete:MethodQueueElement;
		private var _fps:Number;
		private var time:int;
		private var consumeTime:int;
		private var timeCount:int;
		
		
		public function NumbericLabel(viewSource:Object=null)
		{
			super(viewSource);
		}
		
		override public function get className():String
		{
			return "NumbericLabel";
		}
		
		override public function dispose():void
		{
			if(hasDisposed)
			{
				return;
			}
			Tick.instance.removeEventListener(TickEvent.TICK, onTick);
			viewText = null;
			super.dispose();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			if(view is TextField)
			{
				viewText = view as TextField;
			}
			else
			{
				items.length = 0;
				var i:int;
				while(true)
				{
					var item:MovieClip = this.getChildByName
						("item" + i.toString()) as MovieClip;
					if(item)
					{
						items.push(item);
					}
					else
					{
						break;
					}
					i++;
				}
			}
			
		}
		
		/**
		 * 播放随机数字滚动特效
		 * @param time 持续时间，毫秒
		 * @param onComplete
		 * @param onCompleteArgs
		 * @param fps 默认系统fps
		 */
		public function playRollEffect(
			time:int=1000, onComplete:Function=null, 
			onCompleteArgs:Array=null, fps:Number=NaN):void
		{
			this.onComplete = new MethodQueueElement(onComplete, onCompleteArgs);
			this._fps = fps;
			this.time = time;
			consumeTime = 0;
			timeCount = 0;
			Tick.instance.addEventListener(TickEvent.TICK, onTick);
		}
		
		public function stopRollEffect():void
		{
			updateValue();
			Tick.instance.removeEventListener(TickEvent.TICK, onTick);
		}
		
		private function roll():void
		{
			if(viewText)
			{
				var len:int = Math.max(_text.length, minHeight);
				viewText.text = SuperMath.randNumber(len).toString();
			}
			else
			{
				var n:int = items.length;
				var item:MovieClip;
				for(var i:int = 0; i < n; i++)
				{
					item = MovieClip(items[i]);
					item.visible = true;
					item.gotoAndStop(SuperMath.randIntRange(1, 10));
				}
			}
		}
		
		private function onTick(event:TickEvent):void
		{
			consumeTime += event.interval;
			if(consumeTime >= time)
			{
				stopRollEffect();
				onComplete.call();
				onComplete.clear();
				return;
			}
			
			timeCount -= event.interval;
			while (timeCount < 0)
			{
				roll();
				timeCount += 1000/ fps;
			}
		}

		private function updateValue():void
		{
			if(viewText)
			{
				viewText.text = _text;
			}
			else
			{
				var n:int = items.length;
				var str:String;
				var item:MovieClip;
				var bit:Number;
				for(var i:int = 0; i < n; i++)
				{
					item = MovieClip(items[i]);
					str = _text.charAt(i);
					if(str)
					{
						item.visible = true;
						bit = Number(str);
						if(!isNaN(bit))
						{
							item.gotoAndStop(bit + 1);
						}
						else if(str == ".")
						{
							item.gotoAndStop(11)
						}
						else
						{
							item.gotoAndStop(12);
						}
					}
					else
					{
						item.visible = false;
					}
				}
			}
		}
		
		private function get fps():Number
		{
			if (!isNaN(_fps))
			{
				return 	_fps;
			}
			else if (!isNaN(Tick.fps))
			{
				Tick.fps;
			}
			else if (stage)
			{
				return stage.frameRate;
			}
			else
			{
				return 30;
			}
			
			return NaN;
		}
		
		public function get text():String
		{
			return _text;
		}

		public function set text(value:String):void
		{
			if(_text == value)
			{
				return;
			}
			_text = value ? value : "";
			updateValue();
		}

		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			if(_value == value)
			{
				return;
			}
			_value = value;
			_text = isNaN(value) ? "" : value.toString();
			 updateValue();
		}

	}
}