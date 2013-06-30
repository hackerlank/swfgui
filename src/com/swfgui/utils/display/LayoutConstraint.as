package com.swfgui.utils.display
{

	public class LayoutConstraint
	{
		public function LayoutConstraint(
			top:Number = NaN, bottom:Number = NaN, 
			left:Number = NaN, right:Number = NaN,
			horizontalCenter:Number = NaN, 
			verticalCenter:Number = NaN)
		{
			this.top = top;
			this.bottom = bottom;
			this.left = left;
			this.right = right;
			this.horizontalCenter = horizontalCenter;
			this.verticalCenter = verticalCenter;
		}

		public var left:Number;

		public var right:Number;

		public var top:Number;

		public var bottom:Number;

		public var horizontalCenter:Number;

		public var verticalCenter:Number;
	}
}