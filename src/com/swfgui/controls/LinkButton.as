package com.swfgui.controls
{
	
	public class LinkButton extends Label
	{
		public function LinkButton(viewSource:Object=null)
		{
			super(viewSource);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			defaultTextFormat.underline = true;
			viewText.setTextFormat(defaultTextFormat);
			viewText.defaultTextFormat = defaultTextFormat;
			
			setHandCursor(Button.BUTTON_USE_HAND_CURSOR);
		}
	}
}