package  com.swfgui.blit 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	/**
	 * ...
	 * @author ｋａｋａ
	 * 位图帧信息
	 */
	public class BlitFrameData
	{
		/**
		 * x轴偏移
		 */
		public var x:Number;
		
		/**
		 * y轴偏移
		 */
		public var y:Number;
		
		/**
		 * 位图数据
		 */
		public var bitmapData:BitmapData;
		
		/**
		 * 帧标签
		 */
		public var frameLabel:String;
		
		public function BlitFrameData(bitmapData:BitmapData=null, frameLabel:String=null):void
		{
			this.bitmapData = bitmapData;
			this.frameLabel = frameLabel;
		}
		
		public function applyBitmap(bmp:Bitmap):void
		{
			if(bmp)
			{
				bmp.bitmapData = bitmapData;
				bmp.x = x;
				bmp.y = y;
			}
		}
				
		public function dispose():void
		{
			if(bitmapData)
			{
				bitmapData.dispose();
				bitmapData = null;
			}
		}
	}

}