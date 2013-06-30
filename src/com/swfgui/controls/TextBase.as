package com.swfgui.controls
{
	import com.swfgui.core.ResizeMode;
	import com.swfgui.core.UIComponent;

	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class TextBase extends UIComponent
	{
		protected const VIEW_TEXT:String = "viewText";

		protected var _viewText:TextField;
		protected var _text:String;
		private var _htmlText:String;
		private var _selectable:Boolean;
		private var _color:int;
		private var _fontSize:int;
		private var _fontStyle:String;
		private var _fontWeight:String;
		private var _textAlign:String;
		protected var _defaultTextFormat:TextFormat;

		protected var orgViewTextWidth:Number;
		protected var orgViewTextHeight:Number;

		protected var isHtmlText:Boolean;
		private var _autoSize:Boolean;

		public function TextBase(viewSource:Object=null)
		{
			super(viewSource);
		}

		override public function get className():String
		{
			return "TextBaes";
		}

		override protected function initialize():void
		{
			if (view is TextField)
			{
				_viewText = view as TextField;
			}
			else if (viewContainer)
			{
				//找名为VIEW_TEXT的TextField
				_viewText = viewContainer.getChildByName(VIEW_TEXT) as TextField;
				if (!_viewText)
				{
					//找一个TextField
					for (var i:int = 0; i < viewContainer.numChildren; i++)
					{
						if (viewContainer.getChildAt(i) is TextField)
						{
							_viewText = TextField(viewContainer.getChildAt(i));
							break;
						}
					}
				}
			}

			if (!_viewText)
			{
				_viewText = new TextField();
				_viewText.width = _view ? _view.width : 100;
				_viewText.height = _view ? _view.height : 20;
				if (viewContainer)
				{
					//虽然是自己new的，但也要加到view上，如果view不是容器，
					//则在super.initialize()后加到this里面
					viewContainer.addChild(_viewText);
				}
			}

			super.initialize();

			if (!_viewText.parent)
			{
				this.addChild(_viewText);
			}

			orgWidth = width;
			orgHeight = height;
			orgViewTextWidth = _viewText.width;
			orgViewTextHeight = _viewText.height;

			_viewText.type = TextFieldType.DYNAMIC;
			_viewText.selectable = false;
			_viewText.multiline = true;
			_viewText.wordWrap = true;

			_defaultTextFormat = _viewText.defaultTextFormat;
			_color = int(_defaultTextFormat.color);
			_fontSize = int(_defaultTextFormat.size);
			_fontStyle = _defaultTextFormat.italic ? 
				TextConst.FONTSTYLE_ITALIC : TextConst.FONTSTYLE_NORMAL;
			_fontWeight =  _defaultTextFormat.bold ? 
				TextConst.FONTWEIGHT_BOLD : TextConst.FONTWEIGHT_NORMAL;
			_textAlign = _defaultTextFormat.align;

			_text = _viewText.text;
			_htmlText = _viewText.htmlText;
		}

		override protected function updateProperties():void
		{
			super.updateProperties();

			_defaultTextFormat.align = _textAlign;
			_defaultTextFormat.color = _color;
			_defaultTextFormat.size = _fontSize;
			_defaultTextFormat.bold = 
				(_fontWeight == TextConst.FONTWEIGHT_BOLD ? true : false);
			_defaultTextFormat.italic = 
				(_fontStyle == TextConst.FONTSTYLE_ITALIC ? true : false);

			//setTextFormat和htmlText会互相覆盖掉对方的样式
			_viewText.setTextFormat(_defaultTextFormat);
			_viewText.defaultTextFormat = _defaultTextFormat;

			invalidateSize();
		}

		override protected function onSizeChanged():void
		{
			super.onSizeChanged();

			if (resizeMode == ResizeMode.NO_SCALE)
			{
				var child:DisplayObject;
				if (!autoSize)
				{
					for each (child in this.getAllChild())
					{
						child.width += width - oldWidth;
						child.height += height - oldHeight;
					}
				}
				else
				{
					for each (child in this.getAllChild())
					{
						if (child != _viewText)
						{
							child.width += width - oldWidth;
							child.height += height - oldHeight;
						}
					}
				}
			}
		}

		override protected function updateSize():void
		{
			if (autoSize)
			{
				if (_view == _viewText)
				{
					width = _viewText.width;
					height = _viewText.height;
				}
				else
				{
					width = orgWidth + viewText.width - orgViewTextWidth;
					height = orgHeight + viewText.height - orgViewTextHeight;
				}
			}

			super.updateSize();
		}

		/**
		 * view或者view中包含的TextField
		 * @return
		 */
		public function get viewText():TextField
		{
			return _viewText;
		}

		public function get defaultTextFormat():TextFormat
		{
			return _defaultTextFormat;
		}

		public function set defaultTextFormat(value:TextFormat):void
		{
			if (!_defaultTextFormat)
			{
				return;
			}

			_defaultTextFormat = value;
			this.invalidateProperties();
		}

		public function get textAlign():String
		{
			return _textAlign;
		}

		public function set textAlign(value:String):void
		{
			if (_textAlign == value)
			{
				return;
			}

			_textAlign = value;
			this.invalidateProperties();
		}

		/**
		 * 确定文本是否使用粗体。可识别的值为 normal 和 bold
		 * 详见TextConst
		 * @return
		 */
		public function get fontWeight():String
		{
			return _fontWeight;
		}

		public function set fontWeight(value:String):void
		{
			if (_fontWeight == value)
			{
				return;
			}

			_fontWeight = value;
			this.invalidateProperties();
		}

		/**
		 * 确定文本是否使用斜体。可识别的值为 "normal" 和 "italic"。 默认值为 "normal".
		 * 详见TextConst
		 * @return
		 */
		public function get fontStyle():String
		{
			return _fontStyle;
		}

		public function set fontStyle(value:String):void
		{
			if (_fontStyle == value)
			{
				return;
			}

			_fontStyle = value;
			this.invalidateProperties();
		}

		public function get fontSize():int
		{
			return _fontSize;
		}

		public function set fontSize(value:int):void
		{
			if (_fontSize == value)
			{
				return;
			}

			_fontSize = value;
			this.invalidateProperties();
		}

		public function get color():int
		{
			return _color;
		}

		public function set color(value:int):void
		{
			if (_color == value)
			{
				return;
			}

			_color = value;
			this.invalidateProperties();
		}

		public function get text():String
		{
			return viewText.text;
		}

		public function set text(value:String):void
		{
			if (_viewText.text == value)
			{
				return;
			}

			if (!value)
			{
				value = "";
			}

			isHtmlText = false;
			_text = value;
			_viewText.text = value;

			invalidateSize();
		}

		public function get htmlText():String
		{
			return viewText.htmlText;
		}

		public function set htmlText(value:String):void
		{
			if (_htmlText == value)
			{
				return;
			}

			if (!value)
			{
				value == "";
			}

			isHtmlText = true;
			_htmlText = value;
			_viewText.htmlText = value;

			invalidateSize();
		}

		public function get selectable():Boolean
		{
			return _selectable;
		}

		public function set selectable(value:Boolean):void
		{
			if (_selectable == value)
			{
				return;
			}

			_selectable = value;
			_viewText.selectable = _selectable;
		}

		public function get textHeight():Number
		{
			return _viewText.textHeight;
		}

		public function get textWidth():Number
		{
			return _viewText.textWidth;
		}

		public function get autoSize():Boolean
		{
			return _autoSize;
		}

		public function set autoSize(value:Boolean):void
		{
			_autoSize = value;
			viewText.autoSize = _autoSize ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
			invalidateSize();
		}
	}
}