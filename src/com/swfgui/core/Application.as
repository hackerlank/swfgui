package com.swfgui.core
{
	import com.swfgui.loader.SLoader;
	import com.swfgui.managers.resources.ResourceManager;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * 应用程序基类，使用者应该继承此类，但不是必须的。此类只有一个实例。
	 * 建议把此类实例添加到舞台上，而不是别的容器中，或者直接当作文档类。
	 * @author llj
	 */
	public class Application extends UIComponent implements IStartup
	{
		private var _stageWidth:int;
		private var _stageHeight:int;
		private var _alwaysAtStageTop:Boolean;
		private var _scrollRect:Rectangle = new Rectangle();
		/**
		 * 里面添加了popUpLayer、toolTipLayer...
		 * @default 
		 */
		protected var systemContainer:UIComponent;
		
		private var _popUpLayer:UIComponent;
		private var _maskLayer:UIComponent;
		private var _guideLayer:UIComponent;
		private var _debugLayer:UIComponent;
		private var _dragLayer:UIComponent;
		private var _toolTipLayer:UIComponent;
		private var _cursorLayer:UIComponent;
		
		private static var _instance:Application;
		
		public static function get instance():Application
		{
			return _instance ? _instance : _instance = new Application();
		}
		
		public static function get hasInstance():Boolean
		{
			return Boolean(_instance);
		}
		
		public function Application()
		{
			var hasInstance:Boolean = Boolean(_instance);
			super();
			if(hasInstance)
			{
				throw new Error("禁止创建多个实例，请使用Application.instance");
				return;
			}
			_instance = this;
		}
		
		override public function setView(viewSource:Object):void
		{
			if (_initialized)
			{
				return;
			}
			
			_view = this;
			_initialized = true;
			
			top = bottom = left = right = 0;
			
			_popUpLayer = new UIComponent();
			_popUpLayer.mouseEnabled = false;
			
			_maskLayer = new UIComponent();
			_maskLayer.mouseEnabled = false;
			
			_guideLayer = new UIComponent();
			_guideLayer.autoLayout = false;
			_guideLayer.mouseEnabled = false;
			
			_debugLayer = new UIComponent();
			_debugLayer.mouseEnabled = false;
			
			_dragLayer = new UIComponent();
			_dragLayer.autoLayout = false;
			_dragLayer.mouseEnabled = false;
			_dragLayer.mouseChildren = false;
			
			_toolTipLayer = new UIComponent();
			_toolTipLayer.autoLayout = false;
			_toolTipLayer.mouseEnabled = false;
			_toolTipLayer.mouseChildren = false;
			
			_cursorLayer = new UIComponent();
			_cursorLayer.autoLayout = false;
			_cursorLayer.mouseEnabled = false;
			_cursorLayer.mouseChildren = false;
			
			systemContainer = new UIComponent();
			systemContainer.mouseEnabled = false;
			systemContainer.autoLayout = false;
			with(systemContainer)
			{
				addChild(_popUpLayer);
				addChild(_maskLayer);
				addChild(_guideLayer);
				addChild(_debugLayer);
				addChild(_dragLayer);
				addChild(_toolTipLayer);
				addChild(_cursorLayer);
			}
			$addChild(systemContainer);
			
			initialize();
		}
		
		override protected function onAddedToStage():void
		{
			super.onAddedToStage();
			
			stage.showDefaultContextMenu = false;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			width = _stageWidth = stage.stageWidth;
			height = _stageHeight = stage.stageHeight;
			
			//stage.quality = StageQuality.LOW;
			stage.addEventListener(Event.RESIZE, onStageResize);
		}
		
		
		protected function onStageResized():void
		{
			
		}
		
		private function onStageResize(e:Event):void
		{
			_stageWidth = stage.stageWidth;
			_stageHeight = stage.stageHeight;
			if(parent is Stage)
			{
				validateSize();
			}
			onStageResized();
		}
		
		override protected function onSizeChanged():void
		{
			super.onSizeChanged();
			
			_scrollRect.width = width;
			_scrollRect.height = height;
			this.scrollRect = _scrollRect;
			
			//始终能点击到
			if(!alwaysAtStageTop && backgroundColor < 0)
			{
				this.graphics.clear();
				this.graphics.beginFill(0, 0);
				this.graphics.drawRect(0,0,width,height);
				this.graphics.endFill();
			}
			
			systemContainer.setSize(width, height);
			_popUpLayer.setSize(width, height);
			_maskLayer.setSize(width, height);
			_guideLayer.setSize(width, height);
			_debugLayer.setSize(width, height);
			_dragLayer.setSize(width, height);
			_toolTipLayer.setSize(width, height);
			_cursorLayer.setSize(width, height);
			
//			if(!parent)
//			{
//				return;
//			}
			//BasicLayout中已经处理
//			//由于maxWidth、maxHeight的缘故，当小于父容器的时候居中显示
//			if(!isNaN(left) && left == right)
//			{
//				this.x = Math.round(((parent == stage ? stage.stageHeight : parent.height) - height) * 0.5);
//			}
//			if(!isNaN(top) && top == bottom)
//			{
//				this.y = Math.round(((parent == stage ? stage.stageWidth : parent.width) - width) * 0.5);
//			}
		}
		
		/**
		 * 把组件的坐标转换为应用程序的坐标
		 * @param component
		 * @param pt
		 * @return 
		 */
		public function componentToApp(component:DisplayObject, pt:Point):Point
		{
			return globalToLocal(component.localToGlobal(pt));
		}
		
		public function appToComponent(component:DisplayObject, pt:Point):Point
		{
			return component.globalToLocal(localToGlobal(pt));
		}
		
		public function get stageWidth():int
		{
			return _stageWidth;
		}

		public function get stageHeight():int
		{
			return _stageHeight;
		}

		public function get frameRate():int
		{
			return stage ? stage.frameRate : 30;
		}
		
		/**
		 * 因为要保持systemContainer在最上面，所以比父类+1
		 * @return 
		 */
		override protected function get frontHideNumChildren():uint
		{
			return super.frontHideNumChildren + 1;
		}

		/**
		 * 弹出窗口层
		 * @default 
		 */
		public function get popUpLayer():UIComponent
		{
			return _popUpLayer;
		}

		/**
		 * 引导遮罩层
		 * @default 
		 */
		public function get maskLayer():UIComponent
		{
			return _maskLayer;
		}

		/**
		 * 引导层
		 * @default 
		 */
		public function get guideLayer():UIComponent
		{
			return _guideLayer;
		}

		/**
		 * 显示debug、log等信息
		 * @default 
		 */
		public function get debugLayer():UIComponent
		{
			return _debugLayer;
		}

		public function get dragLayer():UIComponent
		{
			return _dragLayer;
		}

		public function get toolTipLayer():UIComponent
		{
			return _toolTipLayer;
		}

		public function get cursorLayer():UIComponent
		{
			return _cursorLayer;
		}

		/**
		 * 保持自身始终在舞台的顶端
		 * @return 
		 */
		public function get alwaysAtStageTop():Boolean
		{
			return _alwaysAtStageTop;
		}

		public function set alwaysAtStageTop(value:Boolean):void
		{
			if(_alwaysAtStageTop == value)
			{
				return;
			}
			_alwaysAtStageTop = value;
			if(!stage)
			{
				return;
			}
			
			if(value)
			{
				stage.addEventListener(Event.ADDED, onStageAdded);
			}
			else
			{
				stage.removeEventListener(Event.ADDED, onStageAdded);
			}
		}
		
		private function onStageAdded(event:Event):void
		{
			if(parent == stage)
			{
				stage.setChildIndex(this, stage.numChildren - 1);
			}
		}
		
		public function startup(config:Object, sloader:SLoader, loadingBar:DisplayObject):void
		{
			ResourceManager.addResource(sloader);
			loadingBar.stage.addChild(this);
			if(loadingBar.parent)
			{
				loadingBar.parent.removeChild(loadingBar);
			}
		}
	}
}