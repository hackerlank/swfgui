package com.swfgui.controls
{
	import com.swfgui.core.ResizeMode;
	import com.swfgui.core.UIComponent;
	import com.swfgui.effects.Tween;
	import com.swfgui.math.SuperMath;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;

	/**
	 * 包装一个mc作为进度条
	 * @author llj
	 */
	public class ProgressBar extends UIComponent
	{
		public static const DIRECTION_LEFT:String = "left";
		public static const DIRECTION_RIGHT:String = "right";

		protected static const LABEL_TEXT:String = "labelText";
		protected static const BAR:String = "bar";
		//protected static const TRACK:String = "track";

		private var _maximum:Number = 0;
		private var _minimum:Number = 0;
		private var _direction:String = DIRECTION_RIGHT;

		private var _label:String = "";
		private var _value:Number = 0;
		private var targetFrame:int;

		private var updateByMC:Boolean;
		private var labelText:TextField;
		private var bar:DisplayObject;
		private var barMask:Shape;

		public function ProgressBar(viewSource:Object=null)
		{
			super(viewSource);
		}

		override protected function initialize():void
		{
			if (viewMC && viewMC.totalFrames > 1)
			{
				updateByMC = true;
				labelText = viewContainer.getChildByName(LABEL_TEXT) as TextField;
				viewMC.gotoAndStop(1);
				return;
			}

			if (viewContainer)
			{
				updateByMC = false;
				labelText = viewContainer.getChildByName(LABEL_TEXT) as TextField;
				bar = viewContainer.getChildByName(BAR);
			}

			if (!bar)
			{
				//把整个view当作bar
				bar = view;
				processView(false);
			}
			else
			{
				processView();
			}

			if (labelText)
			{
				//防止label被mask，也防止被遮住
				this.addChild(labelText);
			}

			barMask = new Shape();
			barMask.graphics.beginFill(0);
			barMask.graphics.drawRect(0, 0, 1, 1);
			barMask.graphics.endFill();
			barMask.x = bar.x;
			barMask.y = bar.y;
			bar.mask = barMask;
			bar.parent.addChild(barMask);
			bar.visible=true;
		}

		override public function dispose():void
		{
			if (hasDisposed)
			{
				return;
			}

			if (viewMC && viewMC.hasEventListener(Event.ENTER_FRAME))
			{
				viewMC.removeEventListener(Event.ENTER_FRAME, onEnterframe);
			}

			super.dispose();
		}

		override protected function updateProperties():void
		{
			super.updateProperties();
			updateProgress();
		}

		protected function updateProgress():void
		{
			if (updateByMC)
			{
				targetFrame = SuperMath.getRange(_value / (_maximum - _minimum) * 
					viewMC.totalFrames, 1, viewMC.totalFrames)
				viewMC.gotoAndStop(targetFrame);
				return;
			}

			if (percentComplete > 0)
			{
				bar.visible = true;
				if (bar.width > bar.height)
				{
					barMask.height = bar.height;
					barMask.width = bar.width * percentComplete;

					if (_direction == DIRECTION_LEFT)
					{
						barMask.x = bar.x;
						barMask.y = bar.y;
					}
					else
					{
						barMask.x = bar.width - barMask.width;
						barMask.y = bar.y;
					}
				}
				else
				{
					barMask.height = bar.height * percentComplete;
					barMask.width = bar.width;

					if (_direction == DIRECTION_LEFT)
					{
						barMask.x = bar.x;
						barMask.y = bar.y;
					}
					else
					{
						barMask.x = bar.x;
						barMask.y = bar.height - barMask.height;
					}
				}
			}
			else
			{
				bar.visible = false;
			}
		}

		public function setProgress(value:Number, total:Number):void
		{
			if (_value == value && _maximum == total)
			{
				return;
			}

			_value = value;
			_maximum = total;

			invalidateProperties();
		}

		private function onEnterframe(e:Event):void
		{
			if (viewMC.currentFrame == targetFrame)
			{
				viewMC.stop();
				viewMC.removeEventListener(Event.ENTER_FRAME, onEnterframe);
			}
			viewMC.nextFrame();
		}

		public function get maximum():Number
		{
			return _maximum;
		}

		public function set maximum(value:Number):void
		{
			_maximum = value;
		}

		public function get minimum():Number
		{
			return _minimum;
		}

		public function set minimum(value:Number):void
		{
			_minimum = value;
		}

		public function get percentComplete():Number
		{
			return _value / (_maximum - _minimum);
		}

		/**
		 * 进度值增大时，进度条的扩展方向，默认ProgressBar.DIRECTION_RIGHT
		 * @return
		 */
		public function get direction():String
		{
			return _direction;
		}

		public function set direction(value:String):void
		{
			_direction = value;
		}

		public function get value():Number
		{
			return _value;
		}

		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;
			if(labelText)
			{
				labelText.text = value;
			}
		}
	}
}