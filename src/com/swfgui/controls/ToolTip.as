package com.swfgui.controls
{
	import com.swfgui.core.IToolTip;

	public class ToolTip extends TextBase implements IToolTip
	{
		public function ToolTip(viewSource:Object=null)
		{
			super(viewSource);
		}

		override protected function initialize():void
		{
			super.initialize();

			this.width = 200;
			this.fontSize = 13;
			this.backgroundColor = 0xFFFFCC;
			this.backgroundAlpha = 0.7;
			this.autoSize = true;
			this.viewText.wordWrap = true;
		}
	}
}