package com.swfgui.controls
{
	import com.swfgui.core.UIComponent;
	import com.swfgui.managers.ViewManager;
	
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	public class Button extends UIComponent
	{
		/**
		 * 按钮鼠标手型的统一开关
		 * @default
		 */
		public static const BUTTON_USE_HAND_CURSOR:Boolean = true;

		//按钮的状态，同时也代表viewMC中对应的帧
		protected const STATE_UP:int = 1;
		protected const STATE_OVER:int = 2;
		protected const STATE_DOWN:int = 3;
		protected const STATE_DISABLED:int = 4;
		
		protected const LABEL_TEXT:String = "labelText";
		protected const ICON_IMAGE:String = "iconImage";
		protected const HIT_AREA:String = "hit_area";

		private var _iconImage:Image;
		private var _icon:String;
		private var _labelText:TextField;
		private var _label:String;
		private var _color:int;

		/**
		 * 按钮的状态，有四种：up、over、down、disabled；ToggleButton又多出四种状态：
		 * up_selected、over_selected、down_selected、disabled_selected。
		 * 同时状态的值也代表viewMC中对应的帧。
		 * @default 
		 */
		protected var state:int;

		private var _clickSound:Object;
		private var _enabled:Boolean = true;
		private var _handCursor:Boolean = true;

		/**
		 * 
		 * @param view 通常是含有4帧(up,over,down,disabled)的MovieClip，
		 * 也可以是SimpleButton等其它任何显示对象
		 */
		public function Button(viewSource:Object=null)
		{
			super(viewSource);
		}
		
		override public function get className():String
		{
			return "Button";
		}
		
		override public function dispose():void
		{
			if(hasDisposed)
			{
				return;
			}
			
			view.removeEventListener(MouseEvent.CLICK, onSimpleButtonClk);
			this.removeEventListener(MouseEvent.CLICK, onMouseClk);
			removeListeners();
			
			super.dispose();
		}

		override protected function initialize():void
		{
			if(!_view)
			{
				_view = ViewManager.getDefaultView(className);
			}
			
			processView(false);
			
			if(viewContainer)
			{
				//icon
				var img:DisplayObject = viewContainer.getChildByName(ICON_IMAGE);
				if(img)
				{
					_iconImage = new Image(img);
				}
				
				//label
				_labelText = viewContainer.getChildByName(LABEL_TEXT) as TextField;
				if (_labelText)
				{
					_labelText.type = TextFieldType.DYNAMIC;
					_labelText.selectable = false;
					_color = _labelText.textColor;
				}
				
				//hitArea
				var area:Sprite = viewContainer.getChildByName(HIT_AREA) as Sprite;
				if (area)
				{
					area.visible = false;
					this.hitArea = area;
				}
			}
			
			if(view is SimpleButton)
			{
				view.addEventListener(MouseEvent.CLICK, onSimpleButtonClk);
			}
			else
			{
				this.mouseChildren = false;
			}
			
			state = STATE_UP;
			super.setHandCursor(_handCursor);
			this.addListeners();
			this.addEventListener(MouseEvent.CLICK, onMouseClk);
			this.updateState();//invalidateProperties();
		}
		
		private function onMouseClk(event:MouseEvent):void
		{
			if(!_enabled)
			{
				//按钮不可用，为什么不直接禁用鼠标事件呢，而只阻断点击事件？，
				//因为很多时候，按钮不可用，但又要求tooltip可用，比如显示“稍后开放”
				event.stopImmediatePropagation();
			}
		}
		
		private function onSimpleButtonClk(event:Event):void
		{
			event.stopPropagation();
			this.dispatchEvent(event);
		}

		/**
		 * 按钮上显示的文字
		 * @return
		 */
		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			if (_label == value)
			{
				return;
			}

			_label = value;
			
			if(_labelText)
			{
				_labelText.text = value;
			}			
		}
		
		public function get color():int
		{
			return _color;
		}
		
		public function set color(value:int):void
		{
			_color = value;
			if(_labelText)
			{
				_labelText.textColor = _color;
			}
		}

		override public function set enabled(value:Boolean):void
		{
			if (_enabled == value)
			{
				return;
			}
			
			_enabled = value;
			
			if(view is SimpleButton)
			{
				(view as SimpleButton).enabled = value;
			}
			
			if(_enabled)
			{
				super.setHandCursor(_handCursor);
				this.addListeners();
				if(state == STATE_DISABLED)
				{
					state = STATE_UP;
				}
			}
			else
			{
				super.setHandCursor(false);
				this.removeListeners();
				state = STATE_DISABLED;
			}
			
			updateState();//invalidateProperties();
		}

		/**
		 * 按钮单击的音效，可以是声音文件路径，或者标识符
		 * @return
		 */
		public function get clickSound():Object
		{
			return _clickSound;
		}

		public function set clickSound(value:Object):void
		{
			_clickSound = value;
		}


		private function addListeners():void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			this.addEventListener(MouseEvent.ROLL_OVER, this.onMouseOver);
			this.addEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
		}

		private function removeListeners():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			this.removeEventListener(MouseEvent.ROLL_OVER, this.onMouseOver);
			this.removeEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
		}

		protected function onMouseDown(e:MouseEvent):void
		{
			state = STATE_DOWN;
			updateState();//invalidateProperties();
		}

		protected function onMouseUp(e:MouseEvent):void
		{
			state = STATE_OVER;
			updateState();//invalidateProperties();
		}

		protected function onMouseOver(e:MouseEvent):void
		{
			if (!BUTTON_USE_HAND_CURSOR)
			{
				super.setHandCursor(false);
			}
			
			if (e.buttonDown)
			{
				if (state != STATE_DOWN)
				{
					state = STATE_DOWN;
				}
			}
			else
			{
				if (state != STATE_OVER)
				{
					state = STATE_OVER;
				}
			}

			updateState();//invalidateProperties();
		}

		protected function onMouseOut(e:MouseEvent):void
		{
			state = STATE_UP;
			updateState();//invalidateProperties();
		}

		/**
		 *
		 * @param show
		 */
		override public function setHandCursor(show:Boolean=true):void
		{
			if(_handCursor != show)
			{
				_handCursor = show;
				super.setHandCursor(BUTTON_USE_HAND_CURSOR ? show : false);
			}
		}
		
		override public function set width(value:Number):void
		{
			if(super.width != value)
			{
				super.width = value;
				view.width = super.width;
			}
		}
		
		override public function set height(value:Number):void
		{
			if(super.height != value)
			{
				super.height = value;
				view.height = super.height;
			}
		}

		public function get icon():String
		{
			return _icon;
		}

		public function set icon(value:String):void
		{
			if(_icon != value)
			{
				_icon = value;
				if(iconImage)
				{
					iconImage.source = value;
				}
			}
		}

		public function get labelText():TextField
		{
			return _labelText;
		}

		public function get iconImage():Image
		{
			return _iconImage;
		}
		
		protected function updateState():void
		{
			if(!viewMC)
			{
				return;
			}

			var frame:int = state;
			
			if(state == STATE_DISABLED)
			{
				frame = viewMC.totalFrames < 
					STATE_DISABLED ? STATE_DOWN : STATE_DISABLED;
			}
			
			viewMC.gotoAndStop(frame);
		}
	}
}