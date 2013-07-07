package com.swfgui.core
{
	import com.swfgui.controls.ToolTip;
	import com.swfgui.events.MoveEvent;
	import com.swfgui.events.ResizeEvent;
	import com.swfgui.events.UIEvent;
	import com.swfgui.interfaces.IDisposable;
	import com.swfgui.managers.ToolTipManager;
	import com.swfgui.managers.ViewManager;
	import com.swfgui.managers.resources.ResourceManager;
	import com.swfgui.math.SuperMath;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	[Event(name="resize", type="com.swfgui.events.ResizeEvent")]

	/**
	 * 各种组件的基类，把view作为子元素，代替view。缺点是getchild等函数只
	 * 是得到只是view而已。top、left、right、bottom四个属性的行为和html相同，
	 * horizontalCenter、verticalCenter的优先级最高
	 *
	 * @author llj
	 */
	public class UIComponent extends Sprite implements IUIComponent, IValidatable, ILayoutable, 
		IDisplayObject, IListItemRenderer, IDisposable
	{
		public static var traceValidate:Boolean = true;
		protected const $SIZE:String = "$size";
		protected const SKIN:String = "skin";

		protected var _view:DisplayObject;
		protected var _viewSource:Object;
		protected var _initialized:Boolean;
		private var _hasDisposed:Boolean;
		private var _enabled:Boolean = true;
		private var _toolTip:String = null;
		private var _toolTipHandler:Object;

		private var _top:Number = NaN;
		private var _bottom:Number = NaN;
		private var _left:Number = NaN;
		private var _right:Number = NaN;
		private var _horizontalCenter:Number = NaN;
		private var _verticalCenter:Number = NaN;

		private var _maxWidth:Number = 10000;
		private var _maxHeight:Number = 10000;
		private var _minWidth:Number = 0;
		private var _minHeight:Number = 0;

		protected var orgWidth:Number = 0;
		protected var orgHeight:Number = 0;
		private var _width:Number = 0;
		private var _height:Number = 0;
		protected var oldWidth:Number = 0;
		protected var oldHeight:Number = 0;

		private var _measuredWidth:Number;
		private var _measuredHeight:Number;
		private var _autoWidth:Boolean;
		private var _autoHeight:Boolean;

		private var _x:Number = 0;
		private var _y:Number = 0;
		protected var oldX:Number = 0;
		protected var oldY:Number = 0;

		private var _resizeMode:String = ResizeMode.NO_SCALE;

		private var backgroundChanged:Boolean;
		private var _backgroundAlpha:Number = 1;
		private var _backgroundColor:int = -1;
		private var _backgroundSkin:DisplayObject;
		private var _disabledAlpha:Number = 0.6;

		//todo 以后实现
//		private var borderStyle:String;
//		private var borderWeight:Number;
//		private var borderColor:uint;
//		private var borderAlpha:Number;

//		private var upSkin:DisplayObject;
//		private var overSkin:DisplayObject;
//		private var downSkin:DisplayObject;
//		private var disabledSkin:DisplayObject;
//		private var selectedUpSkin:DisplayObject;
//		private var selectedoverSkin:DisplayObject;
//		private var selectedDownSkin:DisplayObject;
//		private var selectedDisabledSkin:DisplayObject;
//		private var focusSkin:DisplayObject;

		private var _selected:Boolean;
		private var _dataIndex:int = -1;
		protected var _data:Object = null;
		public var userData:* = null;

		protected var invalidateLayoutFlag:Boolean;
		protected var invalidateSizeFlag:Boolean;
		protected var invalidatePropertiesFlag:Boolean;
		protected var invalidateDisplayListFlag:Boolean;
		protected var validateNowFlag:Boolean;

		private var _includeInLayout:Boolean = true;
		private var _autoLayout:Boolean = true;
		protected var _layout:ILayout = BasicLayout.instance;
		private var _nestLevel:int;
		private var _updateCompletePendingFlag:Boolean;
		private var _hasParent:Boolean;

		/**
		 * 根据view创建组件，view一般是swf中导出的symbol
		 * @param viewSource 可以是
		 */
		public function UIComponent(viewSource:Object=null)
		{
			//todo 有这个必要判断吗，似乎不管stage，都会触发addedToStage事件。
			if (stage)
			{
				_hasParent = true;
				onAddToStage();
			}
			else
			{
				this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			}
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			this.addEventListener(Event.ADDED, onAdded);

			setView(viewSource);
		}

		public function get className():String
		{
			return "UIComponent";
		}

		/**
		 * 销毁对象：一般需要把属性置null、删除事件监听器……，继承的类应该根据需要来覆盖此方法
		 */
		public function dispose():void
		{
			if (_hasDisposed)
			{
				return;
			}

			this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
			_viewSource = null;
			_view = null;
			toolTip = null;
			toolTipHandler = null;
			_data = null;
			userData = null;
			
			while($numChildren > 0)
			{
				var child:IDisposable = $removeChildAt(0) as IDisposable;
				if(child)
				{
					child.dispose();
				}
			}

			_hasDisposed = true;
		}

		/**
		 * 防止重复Dispose
		 * @return
		 */
		public function get hasDisposed():Boolean
		{
			return _hasDisposed;
		}

		/**
		 * 该方法内部只调用了processView来封装view，默认是抢夺view的子元件，并代替view添加到其父容器中，
		 * 其中processView把initialized设置为true。子类可重写此方法来初始化组件
		 */
		protected function initialize():void
		{
			processView();
		}

		/**
		 * 封装view，默认是抢夺view的子元件，并代替view添加到其父容器中
		 * @param capture 是否抢夺view的子元件到this中，如果view是帧数大于1的mc，抢夺无效
		 * @param replace 是否代替view添加到父容器中，如果view.parent是帧数大于1的mc，代替无效
		 */
		protected function processView(capture:Boolean=true, replace:Boolean=true):void
		{
			if (!_view || _view == this)
			{
				_view = this;
				_initialized = true;
				return;
			}

			this.name = _view.name;
			
			orgWidth = oldWidth = _width = Math.round(_view.width);
			orgHeight = oldHeight = _height = Math.round(_view.height);
			//获取背景、删除填充，不能放到capture之后
			if (viewContainer)
			{
				_backgroundSkin = viewContainer.getChildByName(SKIN);

				var $size:DisplayObject = viewContainer.getChildByName($SIZE);
				if ($size)
				{
					//删除设计时，用户填充的元件
					viewContainer.removeChild($size);
					//设置为不可见，是为了防止删除不掉
					$size.visible = false;
				}
			}

			var viewParent:DisplayObjectContainer = _view.parent;

			var captured:Boolean = capture && viewContainer;
			//&& !(viewMC && viewMC.totalFrames > 1);

			var replaced:Boolean = replace && (!viewParent || (viewParent && viewParent != this && 
				//!(viewParent is MovieClip && MovieClip(viewParent).totalFrames > 1) && 
				!(viewParent is Loader)));

			//抢夺
			if (captured)
			{
				//先设置未缩放大小，然后设置成缩放以后的大小
				var w:Number = _width;
				var h:Number = _height;
				orgWidth = oldWidth = _width = Math.round(w / _view.scaleX);
				orgHeight = oldHeight = _height = Math.round(h / _view.scaleY);
				width = Math.round(w);
				height = Math.round(h);

				// 此属性中带有缩放，故忽略
				//this.transform = _view.transform;
				this.transform.colorTransform = _view.transform.colorTransform;
				this.filters = _view.filters;
				this.cacheAsBitmap = _view.cacheAsBitmap;
				this.visible = _view.visible;
				this.opaqueBackground = _view.opaqueBackground;

				var len:int;
				if (viewMC && viewMC.totalFrames > 1)
				{
					for (var i:int = 0; i < viewMC.totalFrames; i++)
					{
						viewMC.gotoAndStop(i + 1);
						len = viewContainer.numChildren;
						while (len-- > 0)
						{
							$addChild(viewContainer.getChildAt(0));
						}
					}

					viewMC.gotoAndStop(1);
				}
				else
				{
					len = viewContainer.numChildren;
					while (len-- > 0)
					{
						$addChild(viewContainer.getChildAt(0));
					}
				}
			}
			/*else
			{
				orgWidth = oldWidth = _width = Math.round(_view.width);
				orgHeight = oldHeight = _height = Math.round(_view.height);
			}*/

			//代替
			if (replaced)
			{
				oldX = _x = super.x = Math.round(_view.x); //取整处理
				oldY = _y = super.y = Math.round(_view.y);

				if (viewParent)
				{
					viewParent.addChildAt(this, viewParent.getChildIndex(_view));
				}

				if (captured)
				{
					if (viewParent)
					{
						viewParent.removeChild(_view);
					}
				}
				else
				{
					_view.x = 0;
					_view.y = 0;
					$addChild(_view);
				}
			}
			else if (viewContainer && captured)
			{
				//抢夺但不能代替，只能退而求其次，反被view包装
				this.x = 0;
				this.y = 0;
				viewContainer.addChild(this);
			}
			//既不能抢夺，也不能代替，那this就相当于一个控制类了，自身不在显示列表内

			_initialized = true;
		}

		private function onAddToStage(e:Event=null):void
		{
			//防止用户不实例化，Application
			if (!Application.hasInstance)
			{
				stage.addChild(Application.instance);
				Application.instance.alwaysAtStageTop = true;
			}

			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			onAddedToStage();
		}

		/**
		 * 被添加到显示列表时
		 */
		private function onAdded(event:Event):void
		{
			if (event.target==this)
			{
				removeEventListener(Event.ADDED,onAdded);
				addEventListener(Event.REMOVED,onRemoved);
				_hasParent = true;
				checkInvalidateFlag();
					//initialize();//todo 被添加到显示列表的时候，调用初始化函数
			}
		}

		/**
		 * 从显示列表移除时
		 */
		private function onRemoved(event:Event):void
		{
			if (event.target==this)
			{
				removeEventListener(Event.REMOVED,onRemoved);
				addEventListener(Event.ADDED,onAdded);
				_nestLevel = 0;
				_hasParent = false;
			}
		}

		/**
		 * 检查属性失效标记并应用
		 */
		private function checkInvalidateFlag():void
		{
			if (invalidatePropertiesFlag)// && Application.hasInstance)
			{
				ValidateManager.instance.invalidateProperties(this);
			}
			if (invalidateSizeFlag)// && Application.hasInstance)
			{
				ValidateManager.instance.invalidateSize(this);
			}
			if (invalidateDisplayListFlag)// && Application.hasInstance)
			{
				ValidateManager.instance.invalidateDisplayList(this);
			}
			if (validateNowFlag)// && Application.hasInstance)
			{
				ValidateManager.instance.validateClient(this);
				validateNowFlag = false;
			}
		}

		private function onRemoveFromStage(e:Event):void
		{
			onRemovedFromStage();
		}

		/**
		 * 方便子类重载
		 */
		protected function onAddedToStage():void
		{

		}

		/**
		 * 方便子类重载
		 */
		protected function onRemovedFromStage():void
		{

		}

		/**
		 *
		 * @param viewSource 可接受的类型有：DisplayObject、资源url、资源Class、BitmapData
		 */
		public function setView(viewSource:Object):void
		{
			if (viewSource == this)
			{
				return;
			}

			_viewSource = viewSource;
			_initialized = false;

			if (viewSource is DisplayObject)
			{
				_view = DisplayObject(viewSource);
			}
			else if (viewSource is String)
			{
				loadView();
			}
			else if (viewSource is Class)
			{
				_view = new viewSource() as DisplayObject;
			}
			else if (viewSource is BitmapData)
			{
				_view = new Bitmap(BitmapData(viewSource));
			}
			else
			{
				//使用默认值，例如viewSource==null的情况下
				_view = ViewManager.getDefaultView(className);
				if (!_view)
				{
					_view = this;
				}
			}

			this.$removeAllChild();
			if (view)
			{
				this.initialize();
			}
		}

		/**
		 * 当viewSource是资源地址时，加载资源后再初始化组件initialize()
		 */
		protected function loadView():void
		{
			if (ResourceManager.hasResource(String(viewSource)))
			{
				_view = ResourceManager.getDisplayObject(String(viewSource));
			}
			else
			{
				ResourceManager.loadOne(String(viewSource), [viewSource], onLoadViewComplete);
			}
		}

		private function onLoadViewComplete(viewSource:String):void
		{
			_view = ResourceManager.getDisplayObject(viewSource);
			if (view)
			{
				this.initialize();
			}
		}

		/**
		 * 重写addEventListener，默认弱引用
		 * @param type
		 * @param listener
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 */
		override public function addEventListener(type:String, 
			listener:Function, 
			useCapture:Boolean=false, 
			priority:int=0, 
			useWeakReference:Boolean=true):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		/**
		 * 下一周期执行函数，通常下一周期，组件的各种属性值都已计算完毕
		 * @param method
		 * @param args
		 * @param afterFrames 经过几个EnterFrame
		 * @param callOnce 如果method被callLater了多次，是否只调用一次
		 */
		public function callLater(method:Function, 
			args:Array = null, 
			afterFrames:int = 1, 
			callOnce:Boolean = true):void
		{
			CallLater(method, args, afterFrames, callOnce);
		}

		//--------------------------------------------------------------------------
		//
		//  IValidatableComponent
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  validateProperties
		//----------------------------------

		/**
		 * 标记属性失效，下一周期调用validateProperties()，比如Label的text属性、Image的source属性等。
		 */
		public function invalidateProperties():void
		{
			if (!invalidatePropertiesFlag && !_hasDisposed)
			{
				this.invalidatePropertiesFlag = true;
				//if (_hasParent && Application.hasInstance)
				ValidateManager.instance.invalidateProperties(this);
			}
		}

		/**
		 * 立即刷新属性，不要覆盖此方法，应该覆盖updateProperties
		 */
		public function validateProperties():void
		{
			updateProperties();
			invalidatePropertiesFlag = false;
			if(traceValidate)
			{
				//trace(name + "：validateProperties()");
			}
		}

		protected function updateProperties():void
		{
			if(_hasDisposed)
			{
				return;
			}
			if (!_includeInLayout || !parentAutoLayout)
			{
				if (oldWidth != _width || oldHeight != _height)
				{
					dispatchResizeEvent()
				}

				if (oldX != _x || oldY != _y)
				{
					dispatchMoveEvent();
				}
			}

			if (backgroundChanged)
			{
				drawBackground();
			}
		}

		//----------------------------------
		//  validateSize
		//----------------------------------

		/**
		 * 标记大小失效，下一周期调用validateSize()，
		 * 引起大小失效的原因有：位置、大小、最值大小、缩放、布局约束、visible、includeInLayout、父级改变
		 */
		public function invalidateSize():void
		{
			if (!parent || !includeInLayout || !parentAutoLayout)
			{
				return;
			}

			if (!invalidateSizeFlag && !_hasDisposed)
			{
				//其实这里不适用接口，就完全破坏了接口的作用
				var p:UIComponent = parent as UIComponent;
				if (p)
				{
					//size失效必然引起父级更新显示列表，为了节省性能，对于BasicLayout不作刷新子项
					if(!(p._layout is BasicLayout))
					{
						p.invalidateDisplayList();
					}
					if(p.autoWidth || p.autoHeight)
					{
						p.invalidateSize();
					}
				}
				this.invalidateSizeFlag = true;
				//if (_hasParent && Application.hasInstance)
				ValidateManager.instance.invalidateSize(this);
			}
		}

		//todo flex中的validateSize是测量默认大小用的，这里改为获得大小，
		/**
		 * 立即更新大小，不要覆盖此方法，应该覆盖updateSize
		 */
		public function validateSize():void
		{
			updateSize();
			invalidateSizeFlag = false;
			if(traceValidate)
			{
				trace(name + "：validateSize()");
			}
		}

		/**
		 * 
		 */
		protected function updateSize():void
		{
			if(_hasDisposed)
			{
				return;
			}
			//todo 将来改为container
			var layout:ILayout = parent is UIComponent ? UIComponent(parent)._layout : _layout;
			if (layout)
			{
				layout.updateLayout(this);
			}
		}

		//----------------------------------
		//  validateDisplayList
		//----------------------------------

		/**
		 * 标记显示列表失效，下一周期调用validateDisplayList()
		 */
		public function invalidateDisplayList():void
		{
			if (!invalidateDisplayListFlag && !_hasDisposed)
			{
				this.invalidateDisplayListFlag = true;
				//if (_hasParent && Application.hasInstance)
				ValidateManager.instance.invalidateDisplayList(this);
			}
		}

		/**
		 * 刷新子元件的布局，不应该覆盖此方法，应该覆盖updateDisplayList
		 */
		public function validateDisplayList():void
		{
			updateDisplayList(_width, _height);
			invalidateDisplayListFlag = false;
			if(traceValidate)
			{
				trace(name + "：validateDisplayList()");
			}
		}

		protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (_layout && !_hasDisposed)
			{
				_layout.updateDisplayList(this, unscaledWidth, unscaledHeight);
			}
		}

		/**
		 * 立即刷新所有
		 */
		public function validateNow(skinDisplayList:Boolean=false):void
		{
			if (_hasDisposed)
			{
				return;
			} 
			//todo 待优化
			if (!validateNowFlag)// && Application.hasInstance)
			{
				ValidateManager.instance.validateClient(this, skinDisplayList);
			}
			else
			{
				validateNowFlag = true;
			}
		}

		/**
		 * 不会引起失效验证
		 * @param layoutWidth
		 * @param layoutHeight
		 */
		public function setLayoutBoundsSize(layoutWidth:Number, layoutHeight:Number):void
		{
//			layoutWidth /= scaleX;
//			layoutHeight /= scaleY;
//			if(isNaN(layoutWidth))
//			{
//				layoutWidth = _measuredWidth;
//			}
//			if(isNaN(layoutHeight))
//			{
//				layoutHeight = _measuredHeight;
//			}
			setActualSize(layoutWidth,layoutHeight);
		}

		/**
		 * 不会引起失效验证
		 * @param w
		 * @param h
		 */
		public function setActualSize(w:Number, h:Number):void
		{
			var change:Boolean = false;
			if (oldWidth != w)
			{
				_width = w;
				change = true;
			}
			if (oldHeight != h)
			{
				_height = h;
				change = true;
			}
			if (change)
			{
				invalidateDisplayList();
				dispatchResizeEvent();
			}
		}

		private function dispatchResizeEvent():void
		{
			onSizeChanged();
			if (hasEventListener(ResizeEvent.RESIZE))
			{
				dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, oldWidth, oldHeight));
			}

			oldWidth = _width;
			oldHeight = _height;
		}

		protected function onSizeChanged():void
		{
			if (resizeMode == ResizeMode.SCALE)
			{
				for each (var child:DisplayObject in getAllChild())
				{
					child.scaleX = this.scaleX;
					child.scaleY = this.scaleY;
				}
			}

			updateSkin();
			drawBackground();
		}

		protected function updateSkin():void
		{
			if (_backgroundSkin)
			{
				_backgroundSkin.width += width - oldWidth;
				_backgroundSkin.height += height - oldHeight;
			}
		}

		protected function drawBackground():void
		{
			if (_backgroundColor != -1)
			{
				this.graphics.clear();
				this.graphics.beginFill(_backgroundColor, _backgroundAlpha);
				this.graphics.drawRect(0, 0, width, height);
				this.graphics.endFill();
			}
			
			backgroundChanged = false;
		}

		/**
		 * 不会引起失效验证
		 * @param x
		 * @param y
		 */
		public function setLayoutBoundsPosition(x:Number, y:Number):void
		{
			var changed:Boolean = false;
			if (this.x!=x)
			{
				_x = super.x = x;
				changed = true;
			}
			if (this.y!=y)
			{
				_y = super.y = y;
				changed = true;
			}
			if (changed)
			{
				dispatchMoveEvent();
			}
		}

		private function dispatchMoveEvent():void
		{
			onPositionChanged();
			if (hasEventListener(MoveEvent.MOVE))
			{
				dispatchEvent(new MoveEvent(MoveEvent.MOVE, oldX, oldY));
			}

			oldX = _x;
			oldY = _y;
		}

		protected function onPositionChanged():void
		{

		}

		//--------------------------------------------------------------------------
		//
		//  layout constraints
		//
		//--------------------------------------------------------------------------

		public function get includeInLayout():Boolean
		{
			return _includeInLayout;
		}

		public function set includeInLayout(value:Boolean):void
		{
			if (_includeInLayout == value)
			{
				return;
			}

			_includeInLayout = value;
			invalidateSize();
		}

		public function get verticalCenter():Number
		{
			return _verticalCenter;
		}

		public function set verticalCenter(value:Number):void
		{
			if (_verticalCenter == value)
			{
				return;
			}

			_verticalCenter = value;

			if (!isNaN(value))
			{
				_top = NaN;
				_bottom = NaN;
			}
			invalidateSize();
		}

		public function get horizontalCenter():Number
		{
			return _horizontalCenter;
		}

		public function set horizontalCenter(value:Number):void
		{
			if (_horizontalCenter == value)
			{
				return;
			}

			_horizontalCenter = value;

			if (!isNaN(value))
			{
				_left = NaN;
				_right = NaN;
			}
			invalidateSize();
		}

		public function get right():Number
		{
			return _right;
		}

		public function set right(value:Number):void
		{
			if (_right == value)
			{
				return;
			}

			_right = value;

			if (!isNaN(value))
			{
				_horizontalCenter = NaN;
			}
			invalidateSize();
		}

		public function get left():Number
		{
			return _left;
		}

		public function set left(value:Number):void
		{
			if (_left == value)
			{
				return;
			}

			_left = value;

			if (!isNaN(value))
			{
				_horizontalCenter = NaN;
			}
			invalidateSize();
		}

		public function get bottom():Number
		{
			return _bottom;
		}

		public function set bottom(value:Number):void
		{
			if (_bottom == value)
			{
				return;
			}

			_bottom = value;

			if (!isNaN(value))
			{
				_verticalCenter = NaN;
			}
			invalidateSize();
		}

		public function get top():Number
		{
			return _top;
		}

		public function set top(value:Number):void
		{
			if (_top == value)
			{
				return;
			}

			_top = value;

			if (!isNaN(value))
			{
				_verticalCenter = NaN;
			}
			invalidateSize();
		}

		//--------------------------------------------------------------------------
		//
		//  size
		//
		//--------------------------------------------------------------------------

		public function get maxWidth():Number
		{
			return _maxWidth;
		}

		public function set maxWidth(value:Number):void
		{
			if (_maxWidth == value)
			{
				return;
			}

			_maxWidth = value;
			if (width > _maxWidth)
			{
				width = _maxWidth;
			}
		}

		public function get maxHeight():Number
		{
			return _maxHeight;
		}

		public function set maxHeight(value:Number):void
		{
			if (_maxHeight == value)
			{
				return;
			}

			_maxHeight = value;
			if (height > _maxHeight)
			{
				height = _maxHeight;
			}
		}

		public function get minWidth():Number
		{
			return _minWidth;
		}

		public function set minWidth(value:Number):void
		{
			if (_minWidth == value)
			{
				return;
			}

			_minWidth = value;
			if (width < _minWidth)
			{
				width = _minWidth;
			}
		}

		public function get minHeight():Number
		{
			return _minHeight;
		}

		public function set minHeight(value:Number):void
		{
			if (_minHeight == value)
			{
				return;
			}

			_minHeight = value;
			if (height < _minHeight)
			{
				height = _minHeight;
			}
		}

		override public function get width():Number
		{
			return _width;
		}

		override public function set width(value:Number):void
		{
			if (_width == value || isNaN(value))
			{
				return;
			}
			_width = SuperMath.getRange(value, minWidth, maxWidth);
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}

		override public function get height():Number
		{
			return _height;
		}

		override public function set height(value:Number):void
		{
			if (_height == value || isNaN(value))
			{
				return;
			}
			_height = SuperMath.getRange(value, minHeight, maxHeight);
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}

		override public function set scaleX(value:Number):void
		{
			if (super.scaleX == value)
			{
				return;
			}
			super.scaleX = value;
			invalidateSize();
		}
		
		override public function set scaleY(value:Number):void
		{
			if (super.scaleY == value)
			{
				return;
			}
			super.scaleY = value;
			invalidateSize();
		}

		/**
		 * 设置组件的宽高
		 * @param width
		 * @param height
		 */
		public function setSize(width:Number, height:Number):void
		{
			this.width = width;
			this.height = height;
		}

		protected function get $width():Number
		{
			return super.width;
		}

		protected function set $width(value:Number):void
		{
			super.width = value;
		}

		protected function get $height():Number
		{
			return super.height;
		}

		protected function set $height(value:Number):void
		{
			super.height = value;
		}

		protected function get $scaleX():Number
		{
			return super.scaleX;
		}

		protected function set $scaleX(value:Number):void
		{
			super.scaleX = value;
		}

		protected function get $scaleY():Number
		{
			return super.scaleY;
		}

		protected function set $scaleY(value:Number):void
		{
			super.scaleY = value;
		}

		//--------------------------------------------------------------------------
		//
		//  position
		//
		//--------------------------------------------------------------------------

		override public function get x():Number
		{
			return _x;
		}

		override public function set x(value:Number):void
		{
			if (_x == value)
			{
				return;
			}
			_x = super.x = value;
			//super.x = Math.round(value);
			invalidateProperties();
			invalidateSize();
		}

		override public function get y():Number
		{
			return _y;
		}

		override public function set y(value:Number):void
		{
			if (_y == value)
			{
				return;
			}
			_y = super.y = value;
			//super.x = Math.round(value);
			invalidateProperties();
			invalidateSize();
		}

		public function move(x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
		}

		protected function childPositionChanged(child:DisplayObject):void
		{

		}

		override public function set visible(value:Boolean):void
		{
			if (this.visible != value)
			{
				super.visible = value;
				invalidateSize();
			}
		}

		public function get $x():Number
		{
			return super.x;
		}

		protected function set $x(value:Number):void
		{
			super.x = value;
		}

		public function get $y():Number
		{
			return super.y;
		}

		protected function set $y(value:Number):void
		{
			super.y = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: DisplayObjectContainer
		//
		//--------------------------------------------------------------------------

		override public function addChild(child:DisplayObject):DisplayObject
		{
			addingChild(child);
			invalidateDisplayList();
			//todo 这个数有问题
			//trace(frontHideNumChildren);
			var index:int = super.numChildren - frontHideNumChildren;
			return super.addChildAt(child, index < 0 ? 0 : index);
		}

		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			addingChild(child);
			invalidateDisplayList();
			return super.addChildAt(child, index + backHideNumChildren);
		}

		protected function addingChild(child:DisplayObject):void
		{
			if (child is IValidatable)
			{
				(child as IValidatable).nestLevel = _nestLevel+1;
			}
			if (child is InteractiveObject)
			{
				//todo 父亲双击启用，子也启用
				if (doubleClickEnabled)
					InteractiveObject(child).doubleClickEnabled = true;
			}
		}

		override public function removeChild(child:DisplayObject):DisplayObject
		{
			invalidateDisplayList();
			return super.removeChild(child);
		}

		override public function removeChildAt(index:int):DisplayObject
		{
			invalidateDisplayList();
			return super.removeChildAt(index + backHideNumChildren);
		}

		override public function getChildIndex(child:DisplayObject):int
		{
			return super.getChildIndex(child) - backHideNumChildren;
		}

		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			invalidateDisplayList();
			if (index > this.numChildren - 1)
			{
				index = this.numChildren - 1;
			}
			super.setChildIndex(child, index + backHideNumChildren);
		}

		override public function getChildAt(index:int):DisplayObject
		{
			return super.getChildAt(index + backHideNumChildren);
		}

		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			invalidateDisplayList();
			super.swapChildren(child1, child2);
		}

		override public function swapChildrenAt(index1:int, index2:int):void
		{
			invalidateDisplayList();
			if (index1 > this.numChildren - 1)
			{
				index1 = this.numChildren - 1;
			}
			if (index2 > this.numChildren - 1)
			{
				index2 = this.numChildren - 1;
			}
			index1 += backHideNumChildren;
			index2 += backHideNumChildren;
			super.swapChildrenAt(index1, index2);
		}

		override public function get numChildren():int
		{
			return (super.numChildren - frontHideNumChildren - backHideNumChildren);
		}

		/**
		 * 容器顶层对使用者隐藏的元件数量，比如Canvas要把两个ScrollBar隐藏掉，
		 * 那么这里就应该返回2
		 * @return
		 */
		protected function get frontHideNumChildren():uint
		{
			return 0;
		}

		/**
		 * 容器底层对使用者隐藏的元件数量，比如要把backgroundSkin隐藏掉，
		 * 那么这里就应该返回1
		 * @return
		 */
		protected function get backHideNumChildren():uint
		{
			return _backgroundSkin && _backgroundSkin.parent == this ? 1 : 0;
		}

		protected function $addChild(child:DisplayObject):DisplayObject
		{
			return super.addChild(child);
		}

		protected function $addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			return super.addChildAt(child, index);
		}

		protected function $removeChild(child:DisplayObject):DisplayObject
		{
			return super.removeChild(child);
		}

		protected function $removeChildAt(index:int):DisplayObject
		{
			return super.removeChildAt(index);
		}

		protected function $getChildIndex(child:DisplayObject):int
		{
			return super.getChildIndex(child);
		}

		protected function $setChildIndex(child:DisplayObject, index:int):void
		{
			super.setChildIndex(child, index);
		}

		protected function $getChildAt(index:int):DisplayObject
		{
			return super.getChildAt(index);
		}

		protected function $swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			super.swapChildren(child1, child2);
		}

		protected function $swapChildrenAt(index1:int, index2:int):void
		{
			super.swapChildrenAt(index1, index2);
		}

		protected function get $numChildren():int
		{
			return super.numChildren;
		}

		//--------------------------------------------------------------------------
		//
		//  children layout
		//
		//--------------------------------------------------------------------------

		/**
		 * 如果为 true，则在更改子项的位置或大小时完成度量和布局。
		 * @return
		 */
		public function get autoLayout():Boolean
		{
			return _autoLayout;
		}

		public function set autoLayout(value:Boolean):void
		{
			_autoLayout = value;
		}

		private function get parentAutoLayout():Boolean
		{
			return parent is IUIComponent ? IUIComponent(parent).autoLayout : true;
		}
		
		public function getAllChild():Array
		{
			var rtv:Array = [];
			var len:int = numChildren;

			for (var i:int = 0; i < len; i++)
			{
				rtv.push(getChildAt(i));
			}

			return rtv;
		}

		public function removeAllChild():void
		{
			var len:int = this.numChildren;
			while (len-- > 0)
			{
				this.removeChildAt(0);
			}
		}

		protected function $removeAllChild():void
		{
			var len:int = this.$numChildren;
			while (len-- > 0)
			{
				this.$removeChildAt(0);
			}
		}

		/**
		 * 不论child==null或者child.parent==null，都能安全的删除
		 * @param child
		 * @return
		 */
		public function safeRemoveChild(child:DisplayObject):DisplayObject
		{
			if (child && child.parent == this)
			{
				return this.removeChild(child);
			}

			return null;
		}

		//--------------------------------------------------------------------------
		//
		//  properties
		//
		//--------------------------------------------------------------------------

		/**
		 * 返回view，UIComponent本身不是DisplayObject，所以
		 * 和显示相关的操作，都由view来承担
		 * @return
		 */
		public function get view():DisplayObject
		{
			return _view;
		}

		/**
		 * 如果view是MovieClip，则viewMC不为空
		 * @return
		 */
		public function get viewMC():MovieClip
		{
			return _view as MovieClip;
		}

		/**
		 * 如果view是DisplayObjectContainer，则viewContainer不为空
		 * @return
		 */
		public function get viewContainer():DisplayObjectContainer
		{
			return _view as DisplayObjectContainer;
		}

		/**
		 * 绑定或者存储数据用的
		 * @return
		 */
		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

		/**
		 * @inheritDoc
		 */
		override public function get doubleClickEnabled():Boolean
		{
			return super.doubleClickEnabled;
		}

		/**
		 * @inheritDoc
		 */
		override public function set doubleClickEnabled(value:Boolean):void
		{
			super.doubleClickEnabled = value;
			//todo 父亲双击启用，子也启用
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:InteractiveObject = getChildAt(i) as InteractiveObject;
				if (child)
					child.doubleClickEnabled = value;
			}
		}

		/**
		 * 禁用后，view及其子元素不能响应鼠标事件
		 * @return
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}

		private var _mouseEnabled:Boolean;
		private var _mouseChildren:Boolean;
		private var _alpha:Number;

		//todo 这种禁用方法待优化
		public function set enabled(value:Boolean):void
		{
			if (_enabled == value)
			{
				return;
			}

			_enabled = value;

			if (value)
			{
				mouseEnabled = _mouseEnabled;
				mouseChildren = _mouseChildren;
				alpha = _alpha;
			}
			else
			{
				//把原先的值记录下来
				_mouseEnabled = mouseEnabled;
				_mouseChildren = mouseChildren;
				_alpha = alpha;

				mouseEnabled = false;
				mouseChildren = false;
				alpha = disabledAlpha;
			}
		}

		public function setHandCursor(show:Boolean=true):void
		{
			this.buttonMode = show;
			this.useHandCursor = show;
		}

		private var _handCursorEnabled:Boolean;

		public function get handCursorEnabled():Boolean
		{
			return _handCursorEnabled;
		}

		public function set handCursorEnabled(value:Boolean):void
		{
			_handCursorEnabled = value;
			this.buttonMode = value;
			this.useHandCursor = value;
		}

		//--------------------------------------------------------------------------
		//
		//  tooltip
		//
		//--------------------------------------------------------------------------

		public function get toolTip():String
		{
			return _toolTip;
		}

		public function set toolTip(value:String):void
		{
			if (_toolTip == value)
			{
				return;
			}

			_toolTip = value;
			updateToolTip();
		}

		/**
		 * 可接受的类型有：IToolTip、DisplayObject。当传入的是DisplayObject
		 * 类型时，this.toolTip属性将无效，具体显示什么由该DisplayObject本身
		 * 决定。置空toolTipHandler以后，this.toolTip属性又有效果了。
		 * @return
		 */
		public function get toolTipHandler():Object
		{
			return _toolTipHandler;
		}

		public function set toolTipHandler(value:Object):void
		{
			if (_toolTipHandler != value)
			{
				_toolTipHandler = value;
				if (value)
				{
					ToolTipManager.registerToolTip(this, value as DisplayObject);
				}
				else
				{
					ToolTipManager.deleteToolTipFrom(this);
				}

				updateToolTip();
			}
		}

		private function updateToolTip():void
		{
			if ((!toolTip || toolTip == "") && toolTipHandler is IToolTip)
			{
				ToolTipManager.deleteToolTipFrom(this);
				return;
			}

			if (!toolTipHandler)
			{
				_toolTipHandler = Object(new ToolTip());
				ToolTipManager.registerToolTip(this, _toolTipHandler as DisplayObject);
			}

			if (toolTipHandler is IToolTip)
			{
				(toolTipHandler as IToolTip).text = _toolTip;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  background
		//
		//--------------------------------------------------------------------------

		/**
		 * 代表backgroundColor和backgroundSkin的透明度，默认1。
		 * @return
		 */
		public function get backgroundAlpha():Number
		{
			return _backgroundAlpha;
		}

		public function set backgroundAlpha(value:Number):void
		{
			if (_backgroundAlpha != value)
			{
				_backgroundAlpha = value;
				backgroundChanged = true;
				invalidateProperties();
			}
		}

		/**
		 * 默认-1，代表没有背景色。
		 * @return
		 */
		public function get backgroundColor():int
		{
			return _backgroundColor;
		}

		public function set backgroundColor(value:int):void
		{
			if (_backgroundColor != value)
			{
				_backgroundColor = value;
				backgroundChanged = true;
				invalidateProperties();
			}
		}

		/**
		 * 背景皮肤
		 * @return
		 */
		public function get backgroundSkin():DisplayObject
		{
			return _backgroundSkin;
		}

		public function set backgroundSkin(value:DisplayObject):void
		{
			if (_backgroundSkin != value)
			{
				safeRemoveChild(_backgroundSkin);
				$addChildAt(value, 0);

				_backgroundSkin = value;
				_backgroundSkin.width = width;
				_backgroundSkin.height = height;
				_backgroundSkin.alpha = _backgroundAlpha;
			}
		}

		override public function toString():String
		{
			return className;
		}

		/**
		 * 缩放模式，默认ResizeMode.NO_SCALE。最好在组件初始化的时候设置此值，后来设置可能导致尺寸不正常。
		 * @return
		 */
		public function get resizeMode():String
		{
			return _resizeMode;
		}

		public function set resizeMode(value:String):void
		{
			_resizeMode = value;
		}

		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			_selected = value;
		}

		public function get dataIndex():int
		{
			return _dataIndex;
		}

		public function set dataIndex(value:int):void
		{
			_dataIndex = value;
		}

		/**
		 * 禁用的时候，透明显示，默默0.6
		 * @default
		 */
		public function get disabledAlpha():Number
		{
			return _disabledAlpha;
		}

		/**
		 * @private
		 */
		public function set disabledAlpha(value:Number):void
		{
			_disabledAlpha = value;
		}

		/**
		 * 当view加载完成，调用initialize初始化以后，此值才为true
		 */
		public function get initialized():Boolean
		{
			return _initialized;
		}

		public function set initialized(value:Boolean):void
		{
			if (_initialized == value)
			{
				return;
			}
			_initialized = value;
			if (value)
			{
				onSizeChanged();
				onPositionChanged();
				//todo initialized标志被设置的时候，触发创建完成事件。
				dispatchEvent(new UIEvent(UIEvent.CREATION_COMPLETE));
			}
		}

		public function get viewSource():Object
		{
			return _viewSource;
		}

		public function get nestLevel():int
		{
			return _nestLevel;
		}

		public function set nestLevel(value:int):void
		{
			_nestLevel = value;
			for (var i:int=numChildren-1; i>=0; i--)
			{
				var child:IValidatable = getChildAt(i) as IValidatable;
				if (child!=null)
				{
					child.nestLevel = _nestLevel+1;
				}
			}
		}

		public function get updateCompletePendingFlag():Boolean
		{
			return _updateCompletePendingFlag;
		}

		public function set updateCompletePendingFlag(value:Boolean):void
		{
			_updateCompletePendingFlag = value;
		}

		public function get hasParent():Boolean
		{
			return _hasParent || parent;
		}

		public function get measuredWidth():Number
		{
			return _measuredWidth;
		}

		public function set measuredWidth(value:Number):void
		{
			_measuredWidth = value;
		}

		public function get measuredHeight():Number
		{
			return _measuredHeight;
		}

		public function set measuredHeight(value:Number):void
		{
			_measuredHeight = value;
		}

		public function get autoWidth():Boolean
		{
			return _autoWidth;
		}

		public function set autoWidth(value:Boolean):void
		{
			_autoWidth = value;
		}

		public function get autoHeight():Boolean
		{
			return _autoHeight;
		}

		public function set autoHeight(value:Boolean):void
		{
			_autoHeight = value;
		}
	}
}