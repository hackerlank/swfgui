package com.swfgui.math
{
	import flash.geom.Point;
	
	
	/**
	 * 
	 * @author allen
	 * 
	 */	
	public class Curve
	{
		public function Curve()
		{
		}
		
		 
		/**
		 *	三点Bezier曲线
		 * @param p1	起始点
		 * @param p2	Bezier参照点（相对于起始点位移）
		 * @param p3	结束点（相对于起始点位移）
		 * @param t		0到1 取点位置
		 * @return 
		 * 
		 */		
		public static function Bezier2(p1:Point, p2:Point, p3:Point, t:Number):Point
		{
			var temp:Point
			var tp1:Point = ((1-t)*(1-t), p1);
			var tp2:Point = multiply(2*t*(1-t), p2);
			var tp3:Point = multiply(t*t, p3);
			temp = p1.add(tp2);
			temp = temp.add(tp3); 
			return temp;
		}
		private static function multiply(num:Number, p:Point):Point{
			var temp:Point = new Point();
			temp.x = p.x*num;
			temp.y = p.y*num;
			return temp;
		}
	}
}