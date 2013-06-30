package com.swfgui.controls
{
	import com.swfgui.core.UIComponent;
	import com.swfgui.loader.SLoader;
	import com.swfgui.loader.SLoaderEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	/**
	 * 可以加载图片、swf等，此类也相当于SWFLoader，没有单独的SWFLoader
	 * @author llj
	 */
	public class Image extends UIComponent
	{
		protected static const LOADING_BAR:String = "loadingBar";
		protected static const ERROR_IMAGE:String = "errorImage";

		private var _content:DisplayObject;
		private var _contentHeight:Number;
		private var _contentWidth:Number;

		private var _fillMode:String;
		private var _source:Object;
		private var _horizontalAlign:String = "center";
		private var _verticalAlign:String = "middle";
		private var _errorImageVisible:Boolean = true;

		private var _clearOnLoad:Boolean = true;
		private var _trustedSource:Boolean = true;

		private var _loadingBar:DisplayObject;
		private var _errorImage:DisplayObject;

		private var loader:SLoader;
		private var imgMask:Rectangle;

		private var _isLoaded:Boolean;
		private var _smooth:Boolean;

		private var waitLoad:Boolean;

		public function Image(viewSource:Object=null)
		{
			super(viewSource);
		}

		override public function dispose():void
		{
			if (hasDisposed)
			{
				return;
			}

			_source = null;
			safeRemoveChild(_content);
			_content = null;
			loader.removeEventListener(SLoaderEvent.COMPLETE, onLoadCpt);
			loader.removeEventListener(SLoaderEvent.ERROR, onLoadError);

			super.dispose();
		}

		override protected function initialize():void
		{
			this.mouseChildren = false;
			processView();
			_fillMode = ImageConst.FILL_MODE_STRETCH;
			_loadingBar = this.getChildByName(LOADING_BAR);
			safeRemoveChild(_loadingBar);
			_errorImage = this.getChildByName(ERROR_IMAGE);
			safeRemoveChild(_errorImage);

			imgMask = new Rectangle(0, 0, this.width, this.height);
			loader = new SLoader();
			loader.addEventListener(SLoaderEvent.COMPLETE, onLoadCpt);
			loader.addEventListener(SLoaderEvent.ERROR, onLoadError);
		}
		
		protected function load():void
		{
			waitLoad = false;
			_isLoaded = false;

			if (clearOnLoad)
			{
				safeRemoveChild(_content);
				_content = null;
			}
			safeRemoveChild(errorImage);

			if (source is String)
			{
				//资源路径
				if (loadingBar)
				{
					this.addChild(loadingBar);
				}
				loader.loadOne(source as String);
			}
			else if (source is Class)
			{
				setContent(new (source as Class)());
			}
			else if (source is DisplayObject)
			{
				//显示对象
				setContent(source as DisplayObject);
			}
			else if (source is BitmapData)
			{
				setContent(new Bitmap(source as BitmapData, "auto", smooth));
			}
			else
			{
				if (errorImage && errorImageVisible)
				{
					errorImage.x = errorImage.y = 0;
					errorImage.width = this.width;
					errorImage.height = this.height;
					this.addChild(errorImage);
				}
			}
		}

		private function onLoadCpt(e:SLoaderEvent):void
		{
			safeRemoveChild(loadingBar);

			if (loader.loaderInfo.childAllowsParent)
			{
				_trustedSource = true;
				setContent(loader.content);
			}
			else
			{
				//加载未经授权的图片，则不能访问content
				_trustedSource = false;
				setContent(loader.loader);
			}
		}
		
		protected function onLoadError(event:SLoaderEvent):void
		{
			safeRemoveChild(loadingBar);
			safeRemoveChild(_content);
			if (errorImage && errorImageVisible)
			{
				errorImage.x = errorImage.y = 0;
				errorImage.width = this.width;
				errorImage.height = this.height;
				this.addChild(errorImage);
			}
		}

		private function setContent(content:DisplayObject):void
		{
			if (!content)
			{
				return;
			}
			safeRemoveChild(_content);
			_isLoaded = true;
			_content = content;
			_contentWidth = _content.width;
			_contentHeight = _content.height;
			this.addChild(_content);
			this.invalidateProperties();
		}

		override protected function updateProperties():void
		{
			super.updateProperties();

			if (!isLoaded)
			{
				return;
			}
			
			if(_content && _content.parent != this)
			{
				return;
			}

			var containerWH:Number = this.width / this.height;
			var contentWH:Number = contentWidth / contentHeight;

			imgMask.width = width;
			imgMask.height = height;
			this.scrollRect = null;

			if (content is Bitmap)
			{
				(content as Bitmap).smoothing = smooth;
			}

			switch (fillMode)
			{
				case ImageConst.FILL_MODE_STRETCH:
					content.width = this.width;
					content.height = this.height;
					break;
				case ImageConst.FILL_MODE_NOSCALE:
					content.width = contentWidth;
					content.height = contentHeight;
					break;
				case ImageConst.FILL_MODE_LETTERBOX:
					if (containerWH == contentWH)
					{
						content.width = this.width;
						content.height = this.height;
					}
					else if (containerWH > contentWH)
					{
						content.width = this.width;
						content.height = int(content.width / contentWH);
						this.scrollRect = imgMask;
					}
					else
					{
						content.height = this.height;
						content.width = int(content.height * contentWH);
						this.scrollRect = imgMask;
					}
					break;
				case ImageConst.FILL_MODE_ZOOM:
					if (containerWH == contentWH)
					{
						content.width = this.width;
						content.height = this.height;
					}
					else if (containerWH < contentWH)
					{
						content.width = this.width;
						content.height = int(content.width / contentWH);
						this.scrollRect = imgMask;
					}
					else
					{
						content.height = this.height;
						content.width = int(content.height * contentWH);
						this.scrollRect = imgMask;
					}
					break;
				case ImageConst.FILL_MODE_CLIP:
					content.width = contentWidth;
					content.height = contentHeight;
					this.scrollRect = imgMask;
					break;
			}

			if (_horizontalAlign == ImageConst.ALIGN_CENTER)
			{
				content.x = int((this.width - content.width) * 0.5);
			}
			else if (_horizontalAlign == ImageConst.ALIGN_RIGHT)
			{
				content.x = this.width - content.width;
			}
			else
			{
				content.x = 0;
			}

			if (_verticalAlign == ImageConst.ALIGN_MIDDLE)
			{
				content.y = int((this.height - content.height) * 0.5);
			}
			else if (_verticalAlign == ImageConst.ALIGN_BOTTOM)
			{
				content.y = this.height - content.height;
			}
			else
			{
				content.y = 0;
			}
		}

		/**
		 * 返回加载的内容
		 * @return
		 */
		public function get content():DisplayObject
		{
			return _content;
		}

		/**
		 * 加载的内容的高度，未缩放
		 * @return
		 */
		public function get contentHeight():Number
		{
			return _contentHeight;
		}

		/**
		 * 加载的内容的宽度，未缩放
		 * @return
		 */
		public function get contentWidth():Number
		{
			return _contentWidth;
		}

		/**
		 * 如果加载的内容是图像，则返回BitmapData对象（未缩放）。
		 * @return
		 */
		public function get bitmapData():BitmapData
		{
			if (content is Bitmap)
			{
				return (content as Bitmap).bitmapData;
			}

			return null;
		}

		/**
		 * 可以是：资源路径、显示对象、显示对象类、BitmapData。
		 * @return
		 */
		public function get source():Object
		{
			return _source;
		}

		public function set source(value:Object):void
		{
			if (_source != value)
			{
				_source = value;
				//防止多次赋值
				if (!waitLoad)
				{
					waitLoad = true;
					callLater(load);
				}
			}
		}

		/**
		 * 加载的内容如何填充，默认ImageConst.FILL_MODE_STRETCH，
		 * 拉伸内容，填满容器
		 * @return
		 */
		public function get fillMode():String
		{
			return _fillMode;
		}

		public function set fillMode(value:String):void
		{
			if (_fillMode == value)
			{
				return;
			}

			_fillMode = value;
			invalidateProperties();
		}

		/**
		 * 如果资源未加载成功，则显示错误图片，默认true
		 * @return
		 */
		public function get errorImageVisible():Boolean
		{
			return _errorImageVisible;
		}

		public function set errorImageVisible(value:Boolean):void
		{
			if (_errorImageVisible != value)
			{
				_errorImageVisible = value;
				if (!value)
				{
					safeRemoveChild(errorImage);
				}
			}
		}

		/**
		 * 内容有没有加载完毕
		 * @return
		 */
		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}

		/**
		 * 内容在水平方向的对齐，默认ImageConst.ALIGN_CENTER
		 * @return
		 */
		public function get horizontalAlign():String
		{
			return _horizontalAlign;
		}

		public function set horizontalAlign(value:String):void
		{
			if (_horizontalAlign == value)
			{
				return;
			}

			_horizontalAlign = value;
			invalidateProperties();
		}

		/**
		 * 内容在垂直方向的对齐，默认ImageConst.ALIGN_MIDDLE
		 * @return
		 */
		public function get verticalAlign():String
		{
			return _verticalAlign;
		}

		public function set verticalAlign(value:String):void
		{
			if (_verticalAlign == value)
			{
				return;
			}

			_verticalAlign = value;
			invalidateProperties();
		}

		/**
		 * 是否在加载新内容之前清除以前的内容，默认true
		 * @default true
		 */
		public function get clearOnLoad():Boolean
		{
			return _clearOnLoad;
		}

		/**
		 * @private
		 */
		public function set clearOnLoad(value:Boolean):void
		{
			_clearOnLoad = value;
		}

		/**
		 * 加载的图像是否允许跨域访问，如果true，则能访问其Bitmap及bitmapData，
		 * 否则，只能使用Loader作为content来显示。在加载图像完毕后设置此标志，
		 * 此值根据loaderInfo.childAllowsParent来设置。默认true。
		 * @default
		 */
		public function get trustedSource():Boolean
		{
			return _trustedSource;
		}

		/**
		 * 内容未加载完毕前显示的loadingBar
		 * @return
		 */
		public function get loadingBar():DisplayObject
		{
			return _loadingBar;
		}

		/**
		 * 内容加载失败后显示的错误图像
		 * @return
		 */
		public function get errorImage():DisplayObject
		{
			return _errorImage;
		}

		public function get smooth():Boolean
		{
			return _smooth;
		}

		public function set smooth(value:Boolean):void
		{
			_smooth = value;
		}
	}
}