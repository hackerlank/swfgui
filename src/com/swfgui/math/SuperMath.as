package com.swfgui.math
{
	import flash.geom.Point;
	
	/**
	 * 
	 * @author llj
	 * 
	 */	
	public class SuperMath
	{
		public function SuperMath()
		{
		}
		
		
		/**
		 * 计算两点连线角度
		 * @param sour	起始点
		 * @param dest	目标点
		 * @return 		角度，范围是 -180 ~ +180 .x轴向右，y轴向下
		 * 
		 */		
		public static function Rotate(sour:Point, dest:Point):Number 
		{

			var quadrant:Number = dest.x>sour.x ? 0 : (dest.y<=sour.y ? -Math.PI : Math.PI);
			var atan:Number = quadrant + Math.atan((dest.y-sour.y)/(dest.x-sour.x));
		
			return 180 * atan / Math.PI;
		}
		
		
		/**
		 *	2D速度分解到x和y轴
		 * @param point			起始点
		 * @param destination	目标点
		 * @param speed			移动速度
		 * @return 				水平和垂直方向的速度
		 * 
		 */		
		public static function axialSpeed(point:Point, destination:Point, speed:Number):Point
		{
			
			var ank:Number = Math.atan((destination.y - point.y)/(destination.x - point.x));
			var dt:Number = Math.sqrt((destination.y-point.y)*(destination.y-point.y)+(destination.x-point.x)*(destination.x-point.x));
			
			var xSpeed:Number = Math.abs(speed*Math.cos(ank));
			xSpeed = destination.x>point.x ? xSpeed : -xSpeed;
			
			var ySpeed:Number = Math.abs(speed * Math.sin(ank));
			ySpeed = destination.y>point.y ? ySpeed : -ySpeed;
			
			return new Point(xSpeed,ySpeed);
		}
		
		/**
		 * 返回value的符号，0 1 -1
		 * @param value
		 * @return 
		 */
		public static function getSign(value:Number):int
		{
			if(value == 0)
			{
				return 0;
			}
			return value > 0 ? 1 : -1;
		}
				
		/**
		 * 随机范围值
		 * @param min
		 * @param max
		 * @return 
		 */
		public static function randRange(min:Number, max:Number):Number
		{
			return Math.random() * (max - min) + min;
		}
		
		public static function randIntRange(min:int, max:int):int
		{
			return Math.round(Math.random() * (max - min)) + min;
		} 
		
		/**
		 * 根据value返回两者之间的值
		 * @param value
		 * @param min
		 * @param max
		 * @return 
		 */
		public static function getRange(value:Number, min:Number, max:Number):Number
		{
			if (value > max)
			{
				return max;
			}
			if (value < min)
			{
				return min;
			}
			return value;
		}
		
		public static function getDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		/**
		 * 随机一个bits位的数字
		 * @param bits
		 * @return 
		 */
		public static function randNumber(bits:int):Number
		{
			return Math.round(Math.random() * Math.pow(10, bits));
		}
	}
}