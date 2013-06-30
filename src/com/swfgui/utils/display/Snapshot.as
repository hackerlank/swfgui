package com.swfgui.utils.display
{
	import com.swfgui.debug.Logger;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Snapshot
	{
		public static function drawBitmapData(
			source:DisplayObject, 
			scaleX:Number = NaN,
			scaleY:Number = NaN,
			rotation:Number = NaN, 
			keepBlankEdge:Boolean = true,
			transparent:Boolean = true, 
			fillColor:uint = 0x00000000):BitmapData
		{
			//try是为了防止安全域以外的图像不能draw
			try
			{
				var src:DisplayObject = source;
				if (! isNaN(scaleX) || ! isNaN(scaleY) || ! isNaN(rotation))
				{
					var sx:Number = isNaN(scaleX) ? source.scaleX:scaleX;
					var sy:Number = isNaN(scaleY) ? source.scaleY:scaleY;
					var rt:Number = isNaN(rotation) ? source.rotation:rotation;
					var sRect:Rectangle = source.getBounds(source);
					var copy:Shape = new Shape();
					copy.x = source.x;
					copy.y = source.y;
					copy.graphics.beginFill(0);
					copy.graphics.drawRect(sRect.x, sRect.y, sRect.width, sRect.height);
					copy.graphics.endFill();
					copy.transform.matrix = source.transform.matrix.clone();
					copy.scaleX = sx;
					copy.scaleY = sy;
					copy.rotation = rt;
					src = copy;
				}
				
				var ref:Shape = new Shape();
				ref.x = src.x;
				ref.y = src.y;
				var rect:Rectangle = src.getBounds(ref);
				var x:int = Math.round(rect.x);
				var y:int = Math.round(rect.y);
				//防止"无效的BitmapData"异常
				var width:int = rect.width > 0 ? Math.ceil(rect.width) : 1;
				var height:int = rect.height > 0 ? Math.ceil(rect.height) : 1;
				var mt:Matrix = src.transform.matrix.clone();
				mt.tx =  -x;
				mt.ty =  -y;
				
				var bitData:BitmapData = new BitmapData(width, height, transparent, fillColor);
				bitData.draw(source, mt, null, null, null, true);

				if (!keepBlankEdge)
				{
					//剔除边缘空白像素
					var realRect:Rectangle = bitData.getColorBoundsRect(0xFF000000, 0x00000000, false);
					if (!realRect.isEmpty() && (bitData.width != realRect.width || 
						bitData.height != realRect.height))
					{
						var realBitData:BitmapData = new BitmapData(realRect.width, 
							realRect.height, transparent, fillColor);
						realBitData.copyPixels(bitData, realRect, new Point());
						bitData.dispose();
						bitData = realBitData;
						x += realRect.x;
						y += realRect.y;
					}
				}
			}
			catch (e:Error)
			{
				bitData = new BitmapData(width, height, true, 0x666666);
				Logger.Warning(Snapshot, "drawBitmapData:" + e.message);
			}

			bmpPoint.x = src.x + x;
			bmpPoint.y = src.y + y;
			return bitData;
		}
		
		private static var bmpPoint:Point = new Point();
		
		public static function drawBitmap(
			source:DisplayObject, 
			scaleX:Number = NaN,
			scaleY:Number = NaN,
			rotation:Number = NaN, 
			keepBlankEdge:Boolean = true,
			transparent:Boolean = true, 
			fillColor:uint = 0x00000000):Bitmap
		{
			var bmpd:BitmapData = drawBitmapData(source, scaleX, scaleY, 
				rotation, keepBlankEdge, transparent, fillColor);
			var bmp:Bitmap = new Bitmap(bmpd);
			bmp.x = bmpPoint.x;
			bmp.y = bmpPoint.y;
			return bmp;
		}
	}
}