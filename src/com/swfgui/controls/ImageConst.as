package com.swfgui.controls
{
	public class ImageConst
	{
		
		public static const  ALIGN_LEFT:String = "left";
		public static const  ALIGN_CENTER:String = "center";
		public static const  ALIGN_RIGHT:String = "right";
		
		public static const  ALIGN_TOP:String = "top";
		public static const  ALIGN_MIDDLE:String = "middle";
		public static const  ALIGN_BOTTOM:String = "bottom";
		
		/**
		 * 宽高比缩放，尽量填满容器，不会超出容器
		 * @default 
		 */
		public static const  FILL_MODE_LETTERBOX : String = "letterbox";
		
		/**
		 * 宽高比缩放，填满容器，多余部分被裁剪，不会超出容器
		 * @default 
		 */
		public static const  FILL_MODE_ZOOM : String = "zoom";
		
		/**
		 * 拉伸内容，填满容器，不会超出容器
		 * @default 
		 */
		public static const  FILL_MODE_STRETCH : String = "stretch";
		
		/**
		 * 不缩放内容，多余部分被裁剪
		 * @default 
		 */
		public static const  FILL_MODE_CLIP : String = "clip";
		
		/**
		 * 不缩放内容，多余部分不裁剪，会超出容器
		 * @default 
		 */
		public static const  FILL_MODE_NOSCALE : String = "noscale";
		
	}
}