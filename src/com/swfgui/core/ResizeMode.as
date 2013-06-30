package com.swfgui.core
{
	public class ResizeMode
	{
		/**
		 * 更改width和height，不影响子元件的大小
		 * @default 
		 */
		public static const NO_SCALE:String = "noScale";
		
		/**
		 * 更改width和height，影响子元件的大小，这是flash的默认模式,也即是说，
		 * width和height是根据实际内容来决定的
		 * @default 
		 */
		public static const SCALE:String = "scale";
	}
}