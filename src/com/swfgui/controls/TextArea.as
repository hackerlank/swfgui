package com.swfgui.controls
{
	import com.swfgui.containers.ScrollPolicy;
	import com.swfgui.core.IScrollable;
	import com.swfgui.core.ValidateManager;
	import com.swfgui.math.SuperMath;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;

	[Event(name="change", type="flash.events.Event")]

	public class TextArea extends TextBase implements IScrollable
	{
		private var _editable:Boolean=true;
	
		private var _horizontalScrollBar:ScrollBar;
		private var _verticalScrollBar:ScrollBar;

		private var _horizontalScrollPosition:Number=0;
		private var _verticalScrollPosition:Number=0;

		private var _horizontalScrollPolicy:String="auto";
		private var _verticalScrollPolicy:String="auto";

		protected var invalidateScrollPostionFlag:Boolean;
		private var _scrollRect:Rectangle;

		public function TextArea(viewSource:Object=null)
		{
			super(viewSource);
		}
		
		override public function get className():String
		{
			return "TextArea";
		}

		override public function dispose():void
		{
			if (hasDisposed)
			{
				return;
			}

			_viewText.removeEventListener(Event.CHANGE, onTextChange);
			_viewText.removeEventListener(Event.CHANGE, onTextChange);

			super.dispose();
		}

		override protected function initialize():void
		{
			if(viewContainer)
			{
				var hscrollBarView:DisplayObject = viewContainer.getChildByName("hscrollBar");
				if (hscrollBarView)
				{
					_horizontalScrollBar = new ScrollBar(hscrollBarView);
					_horizontalScrollBar.direction = ScrollBar.HORIZONTAL;
					_horizontalScrollBar.scrollTarget = this;
				}
				
				var vscrollBarView:DisplayObject = viewContainer.getChildByName("vscrollBar");
				if (vscrollBarView)
				{
					_verticalScrollBar = new ScrollBar(vscrollBarView);
					_verticalScrollBar.direction = ScrollBar.VERTICAL;
					_verticalScrollBar.scrollTarget = this;
				}
			}
			
			super.initialize();
			
			_scrollRect = new Rectangle(0, 0, _viewText.width, _viewText.height);
			autoSize = false;
			selectable = true;
			_viewText.type = TextFieldType.INPUT;
			//设置了autoSize和wordWrap以后，就会自动向下调整大小
			//_viewText.autoSize = TextFieldAutoSize.NONE;
			_viewText.wordWrap = true;
			_viewText.multiline = true;
			_viewText.mouseWheelEnabled = false;
			_viewText.selectable = true;
			_viewText.scrollRect = _scrollRect;

			_viewText.addEventListener(Event.CHANGE, onTextChange);
			_viewText.addEventListener(KeyboardEvent.KEY_DOWN, onTextKeyDown);
		}

		private function onTextKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ENTER)
			{
				if(contentHeight > viewportHeight)
				{
					verticalScrollPosition += _viewText.textHeight / 
						_viewText.numLines;
				}
			}
		}

		private function onTextChange(event:Event):void
		{
			event.stopPropagation();
			this.dispatchEvent(event);
			invalidateSize();
		}

		override protected function updateSize():void
		{
			super.updateSize();

			_scrollRect.width += width - oldWidth;
			_scrollRect.height += height - oldHeight;
			
			if(_verticalScrollBar && _viewText.textHeight > _scrollRect.width)
			{
				_viewText.autoSize = TextFieldAutoSize.LEFT;
			}
			else
			{
				_viewText.autoSize = TextFieldAutoSize.NONE;
			}

			//TextField本身的按行滚动效果不好，就改成了scrollRect滚动
			if (_horizontalScrollBar)
			{
				_horizontalScrollBar.visible = 
					(_horizontalScrollPolicy == ScrollPolicy.AUTO && 
					contentWidth > viewportWidth) ||
					_horizontalScrollPolicy == ScrollPolicy.ON;

				//_horizontalScrollBar.maxScrollPosition = viewText.maxScrollH;

				if (_horizontalScrollBar.visible)
					_horizontalScrollBar.validateProperties();
			}

			if (_verticalScrollBar)
			{
				_verticalScrollBar.visible = 
					(_verticalScrollPolicy == ScrollPolicy.AUTO && 
					contentHeight > viewportHeight) ||
					_verticalScrollPolicy == ScrollPolicy.ON;

				//_verticalScrollBar.maxScrollPosition = viewText.maxScrollV;
				//_verticalScrollBar.minScrollPosition = 0;

				if (_verticalScrollBar.visible)
					_verticalScrollBar.invalidateProperties();
			}

			invalidateScrollPostion();
		}

		//--------------------------------------------------------------------------
		//
		//  invalidateScrollPostion
		//
		//--------------------------------------------------------------------------

		/**
		 * 下一周期将刷新滚动条位置
		 */
		protected function invalidateScrollPostion():void
		{
			if (!invalidateScrollPostionFlag && !hasDisposed)
			{
				this.invalidateScrollPostionFlag = true;
				callLater(validateScrollPostion);
			}
		}

		protected function validateScrollPostion():void
		{
			updateScrollPostion();
			invalidateScrollPostionFlag = false;
		}

		protected function updateScrollPostion():void
		{
			_verticalScrollPosition = SuperMath.getRange(_verticalScrollPosition, 0, 
				contentHeight > viewportHeight ? contentHeight - viewportHeight : 0)
			
			_horizontalScrollPosition = SuperMath.getRange(_horizontalScrollPosition, 0, 
				contentWidth > viewportWidth ? contentWidth - viewportWidth : 0)
		
			
			if (_horizontalScrollBar && _horizontalScrollBar.visible)
			{
				_horizontalScrollBar.updateThumbPosion(_horizontalScrollPosition);
					//_viewText.scrollH = _horizontalScrollPosition;
				
				_scrollRect.x = _horizontalScrollPosition;
			}
			if (_verticalScrollBar && _verticalScrollBar.visible)
			{
				_verticalScrollBar.updateThumbPosion(_verticalScrollPosition);
					//_viewText.scrollV = _verticalScrollPosition;
				
				_scrollRect.y = _verticalScrollPosition;
			}

			_viewText.scrollRect = _scrollRect;
		}

		override public function validateNow(onlyValidateNeeded:Boolean=false):void
		{
			super.validateNow(onlyValidateNeeded);
			
			if (onlyValidateNeeded)
			{
				if (invalidateScrollPostionFlag)
				{
					validateScrollPostion();
				}
			}
			else
			{
				validateScrollPostion();
			}
			
			invalidateDisplayListFlag = false;
			invalidateLayoutFlag = false;
			invalidatePropertiesFlag = false;
			invalidateSizeFlag = false;
			invalidateScrollPostionFlag = false;
		}

		public function get horizontalScrollBar():ScrollBar
		{
			return _horizontalScrollBar;
		}

		public function get verticalScrollBar():ScrollBar
		{
			return _verticalScrollBar;
		}

		public function get horizontalScrollPosition():Number
		{
			return _horizontalScrollPosition;
		}

		public function set horizontalScrollPosition(value:Number):void
		{
			if (_horizontalScrollPosition == value)
			{
				return;
			}

			_horizontalScrollPosition = value;
			invalidateScrollPostion();
		}

		public function get verticalScrollPosition():Number
		{
			return _verticalScrollPosition;
		}

		public function set verticalScrollPosition(value:Number):void
		{
			if (_verticalScrollPosition == value)
			{
				return;
			}

			_verticalScrollPosition = value;
			invalidateScrollPostion();
		}

		public function get horizontalScrollPolicy():String
		{
			return _horizontalScrollPolicy;
		}

		public function set horizontalScrollPolicy(value:String):void
		{
			if (_horizontalScrollPolicy == value)
			{
				return;
			}

			_horizontalScrollPolicy = value;
			invalidateProperties();
		}

		public function get verticalScrollPolicy():String
		{
			return _verticalScrollPolicy;
		}

		public function set verticalScrollPolicy(value:String):void
		{
			if (_verticalScrollPolicy == value)
			{
				return;
			}

			_verticalScrollPolicy = value;
			invalidateProperties();
		}

		//--------------------------------------------------------------------------
		//
		//  属性
		//
		//--------------------------------------------------------------------------

		public function get displayAsPassword():Boolean
		{
			return viewText.displayAsPassword;
		}

		public function set displayAsPassword(value:Boolean):void
		{
			viewText.displayAsPassword = value;
		}

		public function get maxChars():int
		{
			return viewText.maxChars;
		}

		public function set maxChars(value:int):void
		{
			viewText.maxChars = value;
		}

		public function get restrict():String
		{
			return viewText.restrict;
		}

		public function set restrict(value:String):void
		{
			viewText.restrict = value;
		}

		public function get editable():Boolean
		{
			return _editable;
		}

		public function set editable(value:Boolean):void
		{
			if (_editable == value)
			{
				return;
			}

			_editable = value;

			viewText.type = _editable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
		}

		public function get contentHeight():Number
		{
			return viewText.textHeight + 2;
		}

		public function get contentWidth():Number
		{
			return viewText.textWidth + 2;
		}

		public function get viewportWidth():Number
		{
			return _scrollRect.width;
		}

		public function get viewportHeight():Number
		{
			return _scrollRect.height;
		}

		public function appendText(newText:String):void
		{
			if (newText)
			{
				viewText.appendText(newText);
				invalidateSize();
			}
		}
		
		public function get maxHorizontalScrollPosition():Number
		{
			return contentWidth - viewportWidth > 0 ? contentWidth - viewportWidth : 0;
		}
		
		public function get maxVerticalScrollPosition():Number
		{
			return contentHeight - viewportHeight > 0 ? contentHeight - viewportHeight : 0;
		}
	}
}