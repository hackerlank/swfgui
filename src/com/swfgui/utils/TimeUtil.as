package com.swfgui.utils
{
	public class TimeUtil
	{
		public function TimeUtil()
		{
		}
		
		/**
		 * value -> xx天xx时xx分xx秒
		 * @param value 单位：秒
		 */
		public static function formatTime1(value:int):String
		{
			var day:int = value / 86400;
			var hour:int = value % 86400 / 3600;
			var minute:int = value % 3600 / 60;
			var second:int = value % 60;
			
			var rtv:String="";
			
			if(day > 0)
			{
				rtv += day.toString() + "天";
			}
			
			if(hour > 0)
			{
				rtv += hour.toString() + "时";
			}
			
			if(minute > 0)
			{
				rtv += minute.toString() + "分";
			}
			
			return rtv + second.toString() + "秒";
		}
		
		/**
		 * value -> xx天 xx:xx:xx
		 * @param value 单位：秒
		 * @return 
		 */
		public static function formatTime2(value:int):String
		{
			var day:int = value / 86400;
			var hour:int = value % 86400 / 3600;
			var minute:int = value % 3600 / 60;
			var second:int = value % 60;
			
			if(day > 0)
			{
				return day.toString() + "天" + hour.toString() + "小时";
			}
			else
			{
				return hour.toString() + ":" + minute.toString() + ":" + second.toString();
			}
		}

	}
}