package com.swfgui.controls
{
	import com.swfgui.core.Application;
	import com.swfgui.core.IScrollable;
	import com.swfgui.core.UIComponent;
	import com.swfgui.math.SuperMath;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class ScrollBar extends UIComponent
	{
		public static const HORIZONTAL:String = "horizontal";
		public static const VERTICAL:String = "vertical";

		private var _scrollTarget:IScrollable;

		private var _scrollSize:Number = 10;

		private var _direction:String = "vertical";

		private var _scrollPosition:Number = 0;
		private var _minScrollPosition:Number = 0;
		private var _maxScrollPosition:Number = 0;
		private var isExternalMaxScrollPosition:Boolean;

		protected var thumb:Button;
		protected var downArrow:Button;
		protected var upArrow:Button;

		private var thumbDragRange:Rectangle;

		/**
		 * view必须有子元件:thumb downArrow upArrow
		 * @param view
		 */
		public function ScrollBar(viewSource:Object=null)
		{
			super(viewSource);
		}

		override protected function initialize():void
		{
			//this.autoLayout = false;
			
			thumb = new Button(viewContainer.getChildByName("thumb"));
			downArrow = new Button(viewContainer.getChildByName("downArrow"));
			upArrow = new Button(viewContainer.getChildByName("upArrow"));

			//todo 将来要实现长按箭头不停的的滚动
			thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
			downArrow.addEventListener(MouseEvent.MOUSE_DOWN, onArrowMouseDown);
			upArrow.addEventListener(MouseEvent.MOUSE_DOWN, onArrowMouseDown);
			
			super.initialize();
		}

		override public function dispose():void
		{
			if (hasDisposed)
			{
				return;
			}

			thumb.removeEventListener(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
			downArrow.removeEventListener(MouseEvent.MOUSE_DOWN, onArrowMouseDown);
			upArrow.removeEventListener(MouseEvent.MOUSE_DOWN, onArrowMouseDown);

			if (Application.instance.stage.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				Application.instance.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}

			super.dispose();
		}
		
		override protected function updateSize():void
		{
			super.updateSize();
			
			for each(var child:DisplayObject in getAllChild())
			{
				if(child != upArrow && child != downArrow)
				{
					child.width += width - oldWidth;
					child.height += height - oldHeight;
				}
			}
			
			if(_direction == HORIZONTAL)
			{
				downArrow.x += width - oldWidth;
			}
			else
			{
				downArrow.y += height - oldHeight;
			}
			
			updateThumb();
		}

		private function onThumbMouseDown(e:MouseEvent):void
		{
			e.stopPropagation();
			Application.instance.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			thumb.startDrag(false, thumbDragRange);
		}

		private function onMouseMove(e:MouseEvent):void
		{
			if (e.buttonDown)
			{
				var rate:Number;

				if (_direction == HORIZONTAL)
				{
					rate = (thumb.$x - thumbDragRange.x) / thumbDragRange.width;
				}
				else
				{
					rate = (thumb.$y - thumbDragRange.y) / thumbDragRange.height;
				}
				
				//拖动滚动条的时候，不知为何，拖不到最下面
				if(rate > 0.99)
				{
					rate = 1;
				}
				
				//更新滚动
				scrollPosition = rate * totalScrollSize + _minScrollPosition;
			}
			else
			{
				Application.instance.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				thumb.stopDrag();
			}
		}

		private function onArrowMouseDown(e:MouseEvent):void
		{
			e.stopPropagation();
			//更新滚动
			scrollPosition += (e.currentTarget == downArrow ? _scrollSize : -_scrollSize);
			updateThumbPosion();
		}

		override protected function updateProperties():void
		{
			super.updateProperties();
			
			updateThumb();
			updateThumbPosion();
		}

		/**
		 * 无论是拖动滑块、点击箭头，还是程序赋值，最终都是通过改变scrollTarget
		 * 的scrollPosition，由scrollTarget再来刷新滑块位置等。
		 */
		public function updateThumbPosion(position:Number=NaN):void
		{
			if(_scrollPosition == position || !thumb || !thumbDragRange || !_scrollTarget)
			{
				return;
			}
			
			if (!isNaN(position))
			{
				_scrollPosition = position;
			}
			
			if (_direction == HORIZONTAL)
			{
				thumb.x = thumbDragRange.x + (_scrollPosition - _minScrollPosition) / 
					totalScrollSize * thumbDragRange.width;
			}
			else
			{
				thumb.y = thumbDragRange.y + (_scrollPosition - _minScrollPosition) / 
					totalScrollSize * thumbDragRange.height;
			}
			
		}

		/**
		 * 更新滑块大小
		 */
		protected function updateThumb():void
		{
			if (!thumb || !_scrollTarget)
			{
				return;
			}
			
			if(!isExternalMaxScrollPosition)
			{
				_maxScrollPosition = (_direction == HORIZONTAL ?
					_scrollTarget.contentWidth - _scrollTarget.viewportWidth :
					_scrollTarget.contentHeight - _scrollTarget.viewportHeight);
				
				if(_maxScrollPosition < 0)
				{
					_maxScrollPosition = 0;
				}
			}
			
			if (_maxScrollPosition > _minScrollPosition)
			{
				thumb.visible = true;
				upArrow.enabled = true;
				downArrow.enabled = true;

				var trackRange:Rectangle = getTrackRange();

				if (_direction == HORIZONTAL)
				{
					thumb.height = thumb.view.height;
					thumb.width = _scrollTarget.viewportWidth / 
						_scrollTarget.contentWidth * trackRange.width;
					//－1是因为拖动滑块的时候，拖不到最下端
					trackRange.width -= thumb.width - 1;
				}
				else
				{
					thumb.width = thumb.view.width;
					thumb.height = _scrollTarget.viewportHeight / 
						_scrollTarget.contentHeight * trackRange.height;
					trackRange.height -= thumb.height - 1;
				}

				//滑块的拖动范围
				thumbDragRange = trackRange;
			}
			else
			{
				thumb.visible = false;
				upArrow.enabled = false;
				downArrow.enabled = false;
			}
		}

		private function getTrackRange():Rectangle
		{
			var rect:Rectangle = new Rectangle();
			var upArrowRect:Rectangle = upArrow.getBounds(this);
			var downArrowRect:Rectangle = downArrow.getBounds(this);
			if (_direction == HORIZONTAL)
			{
				rect.x = upArrowRect.right;
				rect.y = thumb.y;
				rect.width = downArrowRect.left - upArrowRect.right;
				rect.height = 0;
			}
			else
			{
				rect.x = thumb.x;
				rect.y = upArrowRect.bottom;
				rect.width = 0;
				rect.height = downArrowRect.top - upArrowRect.bottom;
			}

			return rect;
		}

		private function get totalScrollSize():Number
		{
			return _maxScrollPosition - _minScrollPosition;
		}

		public function get scrollTarget():IScrollable
		{
			return _scrollTarget;
		}

		public function set scrollTarget(value:IScrollable):void
		{
			if (!value || _scrollTarget == value)
			{
				return;
			}

			if (_scrollTarget)
			{
				_scrollTarget.removeEventListener(MouseEvent.MOUSE_WHEEL, onScrollTargetMouseWheel);
			}

			_scrollTarget = value;
			value.addEventListener(MouseEvent.MOUSE_WHEEL, onScrollTargetMouseWheel);

			invalidateProperties();
		}

		private function onScrollTargetMouseWheel(e:MouseEvent):void
		{
			if(this.visible)
			{
				//更新滚动
				scrollPosition += (e.delta > 0 ? -_scrollSize : _scrollSize);
				updateThumbPosion();
			}
		}

		/**
		 * 单击箭头或者滚动条轨道时的移动量
		 * @default
		 */
		public function get scrollSize():Number
		{
			return _scrollSize;
		}

		public function set scrollSize(value:Number):void
		{
			_scrollSize = value;
		}

		public function get scrollPosition():Number
		{
			return _scrollPosition;
		}

		public function set scrollPosition(value:Number):void
		{
			if (isNaN(value) || !_scrollTarget)
			{
				return;
			}

			//取整是为了考虑_scrollTarget可能是TextField或者List
			//取整以后，滚动条不会晃动
			value = value > _scrollPosition ? Math.floor(value) : Math.ceil(value);
			value = SuperMath.getRange(value, _minScrollPosition, _maxScrollPosition);
			if (_scrollPosition == value)
			{
				return;
			}

			_scrollPosition = value;
			
			if (_direction == HORIZONTAL)
			{
				_scrollTarget.horizontalScrollPosition = value;
			}
			else
			{
				_scrollTarget.verticalScrollPosition = value;
			}
		}

		public function get direction():String
		{
			return _direction;
		}

		public function set direction(value:String):void
		{
			if(_direction != value)
			{
				_direction = value;
				invalidateProperties();
			}
		}

		public function get minScrollPosition():Number
		{
			return _minScrollPosition;
		}

		public function set minScrollPosition(value:Number):void
		{
			if(_minScrollPosition != value)
			{
				_minScrollPosition = value;
				scrollPosition = _scrollPosition;
				invalidateProperties();
			}
		}

		public function get maxScrollPosition():Number
		{
			return _maxScrollPosition;
		}

		public function set maxScrollPosition(value:Number):void
		{
			if(_maxScrollPosition != value)
			{
				_maxScrollPosition = value;
				scrollPosition = _scrollPosition;
				isExternalMaxScrollPosition = true;
				invalidateProperties();
			}
		}
	}
}