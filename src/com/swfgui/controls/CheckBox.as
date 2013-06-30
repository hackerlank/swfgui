package com.swfgui.controls
{
	import flash.display.DisplayObject;
	
	public class CheckBox extends ToggleButton
	{
		public function CheckBox(viewSource:Object=null)
		{
			super(viewSource);
		}
		
		override public function get className():String
		{
			return "CheckBox";
		}
	}
}