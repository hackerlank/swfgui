package com.swfgui.utils
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**/ /**
	 * 滤镜生成器
	 *
	 * <p>
	 * 用于生成黑白照、水彩、模糊、膨胀、挤压等滤镜。
	 * </p>
	 *
	 * <p>
	 * 部分代码源自rakuto:http://code.google.com/p/as3filters/
	 * </p>
	 *
	 * @author laan
	 * @createTime 2008.11
	 *
	 * @see http://www.laaan.cn
	 * @see http://code.google.com/p/as3filters/
	 *
	 */
	public class FilterFactory
	{
		/**/ /**
		 * 水彩滤镜
		 *
		 * @param size        目标对象范围
		 * @param region    滤镜作用范围
		 * @param factor    接收一个0-1的Number数据，指定水彩化系数
		 *
		 * @return 返回一个<code>DisplacementMapFilter</code>滤镜
		 *
		 */
		public static function aquarelleFilter(size:Rectangle, region:Rectangle = null, factor:Number = 0.5):DisplacementMapFilter
		{
			if (!region)
				region = new Rectangle(0, 0, size.width, size.height);

			if (factor > 1)
				factor = 1;
			if (factor < 0)
				factor = 0;



			var bd:BitmapData = new BitmapData(size.width, size.height, false, 0x000000);
			var no:BitmapData = new BitmapData(size.width, size.height);
			no.noise(factor * 10, 0, 255, BitmapDataChannel.RED);

			bd.copyPixels(no, region, new Point(region.x, region.y));

			var chanel:uint = BitmapDataChannel.RED;
			var filter:DisplacementMapFilter = new DisplacementMapFilter(bd, new Point(0, 0), chanel, chanel, factor * 5, factor * 5);

			return filter;
		}

		/**/ /**
		 * 模糊滤镜
		 *
		 * @param factor    接收一个0-1的Number数据，指定水彩化系数
		 *
		 * @return 返回一个<code>ConvolutionFilter</code>滤镜
		 *
		 */
		public static function FuzzyFilter(factor:Number = 0.5):ConvolutionFilter
		{
			if (factor > 1)
				factor = 1;
			if (factor < 0)
				factor = 0;

			factor *= 10;

			var matrix:Array = [];
			var i:uint = 0;
			while (i++ < factor * factor)
			{
				matrix.push(1);
			}

			var filter:ConvolutionFilter = new ConvolutionFilter(factor, factor, matrix, factor * factor);

			return filter;
		}

		/**/ /**
		 * 灰度滤镜
		 *
		 *
		 * @return 返回一个<code>ColorMatrixFilter</code>滤镜
		 *
		 */
		public static function grayFilter():ColorMatrixFilter
		{
			var matrix:Array = [0, 1, 0, 0, 0,
				0, 1, 0, 0, 0,
				0, 1, 0, 0, 0,
				0, 0, 0, 1, 0];

			return new ColorMatrixFilter(matrix);
		}

		/**/ /**
		 * 浮雕滤镜
		 *
		 * @return 返回一个<code>ConvolutionFilter</code>滤镜
		 *
		 */
		public static function reliefFilter():ConvolutionFilter
		{
			var matrix:Array = [-2,-1,0,-1,1,1,0,1,2];

			var filter:ConvolutionFilter = new ConvolutionFilter(3, 3, matrix, 1);
			return filter;
		}

		/**/ /**
		 * 木雕滤镜
		 *
		 * @param factor 0-1
		 *
		 * @return 返回一组滤镜
		 *
		 */
		public static function woodCarvingFilter(factor:Number = 0.5):Array
		{
			if (factor > 1)
				factor = 1;
			if (factor < 0)
				factor = 0;

			factor *= 10;

			var matrix:Array = [0, 1, 0, 0, -127,
				0, 1, 0, 0, -127,
				0, 1, 0, 0, -127,
				0, 0, 0, 1, 0];

			var matrix2:Array = [0, factor, 0, 0, 0,
				0, factor, 0, 0, 0,
				0, factor, 0, 0, 0,
				0, 0, 0, 1, 0];

			return [new ColorMatrixFilter(matrix), new ColorMatrixFilter(matrix2)];
		}

		/**/ /**
		 * 扭曲滤镜
		 *
		 * @param size
		 * @param region
		 * @param rotation
		 *
		 * @return
		 *
		 */
		public static function twirlFilter(size:Rectangle, region:Rectangle=null, rotation:Number=0):DisplacementMapFilter
		{
			if (!region)
				region = new Rectangle(0, 0, size.width, size.height);

			rotation ||= Math.PI / 2;

			var width:int = size.width;
			var height:int = size.height;

			var dbmd:BitmapData = new BitmapData(size.width, size.height, false, 0x8080);
			var radius:Number = Math.min(region.width, region.height) / 2;
			var centerX:int = region.x + region.width / 2;
			var centerY:int = region.y + region.height / 2;

			for (var y:int = 0; y < height; ++y)
			{
				var ycoord:int = y - centerY;
				for (var x:int = 0; x < width; ++x)
				{
					var xcoord:int = x - centerX;
					var dr:Number = radius - Math.sqrt(xcoord * xcoord + ycoord * ycoord);
					if (dr > 0)
					{
						var angle:Number = dr / radius * rotation;
						var dx:Number = xcoord * Math.cos(angle) - ycoord * Math.sin(angle) - xcoord;
						var dy:Number = xcoord * Math.sin(angle) + ycoord * Math.cos(angle) - ycoord;
						var blue:int = 0x80 + Math.round(dx / width * 0xff);
						var green:int = 0x80 + Math.round(dy / height * 0xff);
						dbmd.setPixel(x, y, green << 8 | blue);
					}
				}
			}
			return new DisplacementMapFilter(dbmd,
				new Point(0, 0),
				BitmapDataChannel.BLUE,
				BitmapDataChannel.GREEN,
				width,
				height,
				DisplacementMapFilterMode.IGNORE);
		}

		/**/ /**
		 * 挤压滤镜
		 *
		 * @param size
		 * @param region
		 * @param amount
		 * @return
		 *
		 */
		public static function squeezeFilter(size:Rectangle, region:Rectangle = null, factor:Number = 0.5):DisplacementMapFilter
		{
			var width:int = size.width;
			var height:int = size.height;

			region ||= new Rectangle(0, 0, width, height);

			var radius:Number = Math.min(region.width, region.height) / 2;
			var centerX:int = region.x + region.width / 2;
			var centerY:int = region.y + region.height / 2;
			var dbmd:BitmapData = new BitmapData(width, height, false, 0x8080);

			for (var y:int = 0; y < height; ++y)
			{
				var ycoord:int = y - centerY;
				for (var x:int = 0; x < width; ++x)
				{
					var xcoord:int = x - centerX;
					var d:Number = Math.sqrt(xcoord * xcoord + ycoord * ycoord);
					if (d < radius)
					{
						var t:Number = d == 0 ? 0 : Math.pow(Math.sin(Math.PI / 2 * d / radius), -factor);
						var dx:Number = xcoord * (t - 1) / width;
						var dy:Number = ycoord * (t - 1) / height;
						var blue:int = 0x80 + dx * 0xff;
						var green:int = 0x80 + dy * 0xff;
						dbmd.setPixel(x, y, green << 8 | blue);
					}
				}
			}

			return new DisplacementMapFilter(dbmd,
				new Point(0, 0),
				BitmapDataChannel.BLUE,
				BitmapDataChannel.GREEN,
				width,
				height,
				DisplacementMapFilterMode.CLAMP);
		}

		/**/ /**
		 * 膨胀滤镜
		 *
		 * @param size
		 * @param region
		 * @param factor
		 *
		 * @return
		 *
		 */
		public static function bulgeFilter(size:Rectangle, region:Rectangle = null, factor:Number = 0.5):DisplacementMapFilter
		{
			return squeezeFilter(size, region, Math.min(-factor, -1));
		}

		/**/ /**
		 * 鱼眼滤镜
		 *
		 * @param size
		 * @param region
		 * @param factor
		 *
		 * @return
		 *
		 */
		public static function fisheyeFilter(size:Rectangle, region:Rectangle = null, factor:Number = 0.8):DisplacementMapFilter
		{
			var width:int = size.width;
			var height:int = size.height;

			region ||= new Rectangle(0, 0, width, height);

			var dbmd:BitmapData = new BitmapData(width, height, false, 0x8080);

			var centerX:int = region.x + region.width / 2;
			var centerY:int = region.y + region.height / 2;

			var radius:Number = Math.sqrt(region.width * region.width + region.height * region.height);

			for (var y:int = 0; y < height; ++y)
			{
				var ycoord:int = y - centerY;
				for (var x:int = 0; x < width; ++x)
				{
					var xcoord:int = x - centerX;
					var d:Number = Math.sqrt(xcoord * xcoord + ycoord * ycoord);
					if (d < radius)
					{
						var t:Number = d == 0 ? 0 : Math.pow(Math.sin(Math.PI / 2 * d / radius), factor);
						var dx:Number = xcoord * (t - 1) / width;
						var dy:Number = ycoord * (t - 1) / height;
						var blue:int = 0x80 + dx * 0xff;
						var green:int = 0x80 + dy * 0xff;
						dbmd.setPixel(x, y, green << 8 | blue);
					}
				}
			}

			return new DisplacementMapFilter(dbmd,
				new Point(0, 0),
				BitmapDataChannel.BLUE,
				BitmapDataChannel.GREEN,
				width,
				height,
				DisplacementMapFilterMode.CLAMP);
		}
	}
}