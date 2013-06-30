package com.swfgui.containers
{
	import com.swfgui.controls.ScrollBar;
	import com.swfgui.core.BasicLayout;
	import com.swfgui.core.ILayout;
	import com.swfgui.core.IScrollable;
	import com.swfgui.core.UIComponent;
	import com.swfgui.effects.Tween;
	import com.swfgui.math.SuperMath;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.TouchscreenType;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	/**
	 * 容器类，支持滚动
	 * @author llj
	 */
	public class Canvas extends UIComponent implements IScrollable
	{
		private var _scrollByContent:Boolean;
		
		private var _horizontalScrollBar:ScrollBar;
		private var _verticalScrollBar:ScrollBar;

		private var _horizontalScrollPosition:Number=0;
		private var _verticalScrollPosition:Number=0;

		private var _horizontalScrollPolicy:String="auto";
		private var _verticalScrollPolicy:String="auto";

		private var _contentWidth:Number=0;
		private var _contentHeight:Number=0;
		
		private var _contentBackgroundAlpha:Number = 0;
		private var _contentBackgroundColor:int = 0;
		
		//todo 如果超出的就不会显示，
		private var _clipContent:Boolean = true;
		
		protected var _scrollRect:Rectangle = new Rectangle();
		private var lastScrollX:Number=0;
		private var lastScrollY:Number=0;

		protected var isUpdateScrollBar:Boolean;
		protected var invalidateScrollPostionFlag:Boolean;

		public function Canvas(viewSource:Object=null)
		{
			super(viewSource);
		}

		override public function get className():String
		{
			return "Canvas";
		}

		override public function dispose():void
		{
			super.dispose();
		}

		override protected function initialize():void
		{
			scrollByContent = Capabilities.touchscreenType != TouchscreenType.NONE;
			
			//初始化元件不能放到capture之后
			if (viewContainer)
			{
				var hscrollBarView:DisplayObject = viewContainer.getChildByName("hscrollBar");
				if (hscrollBarView)
				{
					_horizontalScrollBar = new ScrollBar(hscrollBarView);
					_horizontalScrollBar.direction = ScrollBar.HORIZONTAL;
					_horizontalScrollBar.scrollTarget = this;
					viewContainer.setChildIndex(_horizontalScrollBar, viewContainer.numChildren - 1);
					_clipContent = true;
				}

				var vscrollBarView:DisplayObject = viewContainer.getChildByName("vscrollBar");
				if (vscrollBarView)
				{
					_verticalScrollBar = new ScrollBar(vscrollBarView);
					_verticalScrollBar.direction = ScrollBar.VERTICAL;
					_verticalScrollBar.scrollTarget = this;
					viewContainer.setChildIndex(_verticalScrollBar, viewContainer.numChildren - 1);
					_clipContent = true;
				}
			}
			
			super.initialize();
			
			_contentWidth = width;
			_contentHeight = height;
			_scrollRect.width = width + 1;
			_scrollRect.height = height + 1;
		}
		
		override protected function updateSize():void
		{
			super.updateSize();
			
			if (_horizontalScrollBar)
			{
				_horizontalScrollBar.width += width - oldWidth;
				_horizontalScrollBar.y += height - oldHeight;
			}
			
			if (_verticalScrollBar)
			{
				_verticalScrollBar.height += height - oldHeight;
				_verticalScrollBar.x += width - oldWidth;
			}
			
			if (_contentBackgroundColor >= 0)
			{
				this.graphics.beginFill(_contentBackgroundColor, _contentBackgroundAlpha);
				this.graphics.drawRect(0, 0, _contentWidth, _contentHeight);
				this.graphics.endFill();
			}
		}
		
		override public function invalidateSize():void
		{
			super.invalidateSize();
			isUpdateScrollBar = true;
			invalidateScrollPostion();
		}

		/**
		 * 刷新显示列表，必然要刷新滚动条，所以覆盖此方法
		 */
		override public function invalidateDisplayList():void
		{
			super.invalidateDisplayList();
			isUpdateScrollBar = true;
			invalidateScrollPostion();
		}

		public function updateScrollBar():void
		{
			mesureContent();
			_scrollRect.width = width + 1;
			_scrollRect.height = height + 1;

			if (!_clipContent)
			{
				this.scrollRect = null;
				return;
			}

			if (_horizontalScrollBar)
			{
				_horizontalScrollBar.visible = 
					(_horizontalScrollPolicy == ScrollPolicy.AUTO && 
					contentWidth > viewportWidth) ||
					_horizontalScrollPolicy == ScrollPolicy.ON;

				if (_horizontalScrollBar.visible)
				{
					_horizontalScrollBar.validateProperties();
				}
				else
				{
					//滚动条消失，滚动0
					_horizontalScrollPosition = 0;
				}
			}

			if (_verticalScrollBar)
			{
				_verticalScrollBar.visible = 
					(_verticalScrollPolicy == ScrollPolicy.AUTO && 
					contentHeight > viewportHeight) ||
					_verticalScrollPolicy == ScrollPolicy.ON;

				if (_verticalScrollBar.visible)
				{
					_verticalScrollBar.validateProperties();
				}
				else
				{
					_verticalScrollPosition = 0;
				}
			}
		}

		private function mesureContent():void
		{
			var maxWidth:int;
			var maxHeight:int;
			var len:int = this.numChildren;
			for (var i:int = 0; i < len; i++)
			{
				//用this作getBounds的参数时， new MovieClip()的x、y很大
				var child:DisplayObject = this.getChildAt(i);
				var rect:Rectangle = child.getBounds(child);
				if (rect.right + child.x > maxWidth)
				{
					maxWidth = rect.right + child.x;
				}

				if (rect.bottom + child.y > maxHeight)
				{
					maxHeight = rect.bottom + child.y;
				}
			}

			_contentWidth = maxWidth;
			_contentHeight = maxHeight;
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
			if (isUpdateScrollBar)
			{
				updateScrollBar();
				isUpdateScrollBar = false;
			}
			updateScrollPostion();
			invalidateScrollPostionFlag = false;
		}

		protected function updateScrollPostion():void
		{
			if (!_clipContent)
			{
				return;
			}
			
			_scrollRect.x = _horizontalScrollPosition;
			_scrollRect.y = _verticalScrollPosition;
			
			this.scrollRect = _scrollRect;
			updateScrollBarPosition();

			lastScrollX = _scrollRect.x;
			lastScrollY = _scrollRect.y;
		}

		protected function updateScrollBarPosition():void
		{
			if (_horizontalScrollBar)
			{
				_horizontalScrollBar.updateThumbPosion(_horizontalScrollPosition);
				if (_horizontalScrollBar.parent == this)
				{
					_horizontalScrollBar.x += _scrollRect.x - lastScrollX;
					_horizontalScrollBar.y += _scrollRect.y - lastScrollY;
				}
			}
			if (_verticalScrollBar)
			{
				_verticalScrollBar.updateThumbPosion(_verticalScrollPosition);
				if (_verticalScrollBar.parent == this)
				{
					_verticalScrollBar.x += _scrollRect.x - lastScrollX;
					_verticalScrollBar.y += _scrollRect.y - lastScrollY;
				}
			}

			if (backgroundSkin)
			{
				backgroundSkin.x += _scrollRect.x - lastScrollX;
				backgroundSkin.y += _scrollRect.y - lastScrollY;
			}
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

		//--------------------------------------------------------------------------
		//
		//  Scrolling
		//
		//--------------------------------------------------------------------------

		public function get contentWidth():Number
		{
			return _contentWidth;
		}

		public function get contentHeight():Number
		{
			return _contentHeight;
		}

		public function get viewportWidth():Number
		{
			return verticalScrollBar && verticalScrollBar.visible && 
				verticalScrollBar.parent == this ? 
				width - verticalScrollBar.width : width;
		}

		public function get viewportHeight():Number
		{
			return horizontalScrollBar && horizontalScrollBar.visible && 
				horizontalScrollBar.parent == this ? 
				height - horizontalScrollBar.height : height;
		}

		/**
		 * 横向滚动条，可以位于容器内，也可以位于容器外
		 * @return
		 */
		public function get horizontalScrollBar():ScrollBar
		{
			return _horizontalScrollBar;
		}

		public function set horizontalScrollBar(value:ScrollBar):void
		{
			if (_horizontalScrollBar == value)
			{
				return;
			}
			_clipContent = true;
			_horizontalScrollBar = value;
			_horizontalScrollBar.scrollTarget = this;
			invalidateDisplayList();
		}

		public function get verticalScrollBar():ScrollBar
		{
			return _verticalScrollBar;
		}

		/**
		 * 纵滚动条，可以位于容器内，也可以位于容器外
		 * @return
		 */
		public function set verticalScrollBar(value:ScrollBar):void
		{
			if (_verticalScrollBar == value)
			{
				return;
			}
			_clipContent = true;
			_verticalScrollBar = value;
			_verticalScrollBar.scrollTarget = this;
			invalidateDisplayList();
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
			invalidateDisplayList();
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
			invalidateDisplayList();
		}

		/**
		 * 是否裁剪超出容器的内容，默认为false，如果有滚动条，则此值将始终为true，没有滚动条或者滚动条被关闭的情况下，
		 * 设置为false才起作用。
		 * @return
		 */
		public function get clipContent():Boolean
		{
			return _clipContent;
		}

		public function set clipContent(value:Boolean):void
		{
			if ((_horizontalScrollBar || _verticalScrollBar) && 
				(horizontalScrollPolicy != ScrollPolicy.OFF || 
				verticalScrollPolicy != ScrollPolicy.OFF))
			{
				value = true;
			}

			if (_clipContent == value)
			{
				return;
			}

			_clipContent = value;
			invalidateDisplayList();
		}

		override protected function get frontHideNumChildren():uint
		{
			return super.frontHideNumChildren + 
				(_horizontalScrollBar && _horizontalScrollBar.parent == this ? 1 : 0) + 
				(_verticalScrollBar && _verticalScrollBar.parent == this ? 1 : 0);
		}

		public function get contentBackgroundAlpha():Number
		{
			return _contentBackgroundAlpha;
		}

		public function set contentBackgroundAlpha(value:Number):void
		{
			_contentBackgroundAlpha = value;
			invalidateSize();
		}

		public function get contentBackgroundColor():int
		{
			return _contentBackgroundColor;
		}

		public function set contentBackgroundColor(value:int):void
		{
			_contentBackgroundColor = value;
			invalidateSize();
		}
		
		/**
		 * 子元件的布局器
		 * @return
		 */
		public function get layout():ILayout
		{
			return _layout;
		}
		
		public function set layout(value:ILayout):void
		{
			if (_layout != value)
			{
				_layout = value;
				if (!value)
				{
					value = BasicLayout.instance;
				}
				
				invalidateDisplayList();
			}
		}

		/**
		 * 拖动content来滚动。默认的，如果设备支持触摸，则为true，否则为false。
		 * @return 
		 */
		public function get scrollByContent():Boolean
		{
			return _scrollByContent;
		}
		
		private var isMouseMove:Boolean;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		public function set scrollByContent(value:Boolean):void
		{
			_scrollByContent = value;
			if(value)
			{
				if(Multitouch.inputMode == MultitouchInputMode.NONE)
				{
					this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
				else
				{
					this.addEventListener(TouchEvent.TOUCH_BEGIN, onMouseDown);
				}
			}
			else
			{
				if(Multitouch.inputMode == MultitouchInputMode.NONE)
				{
					this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
				else
				{
					this.removeEventListener(TouchEvent.TOUCH_BEGIN, onMouseDown);
				}
			}
		}
	
		protected function onMouseDown(event:Event):void
		{
			if(event.target == horizontalScrollBar ||
				event.target == verticalScrollBar)
			{
				return;
			}
			
			if(Multitouch.inputMode == MultitouchInputMode.NONE)
			{
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			else
			{
				stage.addEventListener(TouchEvent.TOUCH_MOVE, onMouseMove);
				stage.addEventListener(TouchEvent.TOUCH_END, onMouseUp);
			}
			lastMouseX = this.mouseX;
			lastMouseY = this.mouseY;
		}
		
		protected function onMouseMove(event:Event):void
		{
			isMouseMove = true;
			if(maxHorizontalScrollPosition > 0)
			{
				horizontalScrollPosition += Math.round(mouseX - lastMouseX);
			}
			if(maxVerticalScrollPosition > 0)
			{
				verticalScrollPosition += Math.round(mouseY - lastMouseY);
			}
			lastMouseX = mouseX;
			lastMouseY = mouseY;
		}
		
		protected function onMouseUp(event:Event):void
		{
			if(Multitouch.inputMode == MultitouchInputMode.NONE)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			else
			{
				stage.removeEventListener(TouchEvent.TOUCH_MOVE, onMouseMove);
				stage.removeEventListener(TouchEvent.TOUCH_END, onMouseUp);
			}
			if(isMouseMove)
			{
				var hp:Number = SuperMath.getRange(horizontalScrollPosition, 
					0, maxHorizontalScrollPosition);
				var vp:Number = SuperMath.getRange(verticalScrollPosition, 
					0, maxVerticalScrollPosition);
				
				if(hp != horizontalScrollPosition)
				{
					Tween.to(this, 0.3, {horizontalScrollPosition:hp});
				}
				if(vp != verticalScrollPosition)
				{
					Tween.to(this, 0.3, {verticalScrollPosition:vp});
				}
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