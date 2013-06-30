package com.swfgui.controls
{
	public class Label extends TextBase
	{
		private var _truncateToFit:Boolean=false;

		public function Label(viewSource:Object=null)
		{
			super(viewSource);
		}

		override public function get className():String
		{
			return "Label";
		}

		override protected function updateSize():void
		{
			super.updateSize();
			
			if (!autoSize)
			{
				checkTruncation();
			}
		}

		/**
		 * 为了裁剪显示
		 */
		protected function checkTruncation():void
		{
			if (!truncateToFit || isHtmlText)
			{
				return;
			}
			
			_viewText.text = _text;
			var truncation:Boolean = false;

			while (_viewText.text != "" && _viewText.textWidth > _viewText.width)
			{
				_viewText.text = _viewText.text.substr(0, _viewText.text.length - 1);
				truncation = true;
			}
			
			var noToolTip:Boolean = (!toolTip && !toolTipHandler) || (toolTip == _text);
			if (truncation)
			{
				_viewText.text = _viewText.text.substr(0, _viewText.text.length - 2) + "...";
				if (noToolTip)
				{
					toolTip = _text;
				}
			}
			else
			{
				_viewText.text = _text;
				if (noToolTip)
				{
					toolTip = null;
				}
			}
		}

		override public function set text(value:String):void
		{
			if(toolTip == text)
			{
				toolTip = value;
			}

			super.text = value;
		}
		
		public function get truncateToFit():Boolean
		{
			return _truncateToFit;
		}

		public function set truncateToFit(value:Boolean):void
		{
			if (_truncateToFit == value)
			{
				return;
			}

			_truncateToFit = value;
			invalidateSize();
		}
	}
}