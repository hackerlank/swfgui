package com.swfgui.core
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	
	public class BasicLayout implements ILayout
	{
		private static var _instance:BasicLayout;
		
		public static function get instance():BasicLayout
		{
			return _instance || (_instance = new BasicLayout());
		}
		
		//felx中measure是测量大小，这里是确定大小，
		public function updateLayout(child:UIComponent):void
		{
			if(!child || !child.parent)
			{
				return;
			}
			
			var xx:Number = child.x;
			var yy:Number = child.y;
			var ww:Number = child.width;
			var hh:Number = child.height;
			
			var parentWidth:Number = child.parent.width;
			var parentHeight:Number = child.parent.height;
			
			if(child.parent is Stage)
			{
				parentWidth = child.parent.stage.stageWidth;
				parentHeight = child.parent.stage.stageHeight;
			}
			
			if (!isNaN(child.left))
			{
				xx = child.left;
				if (!isNaN(child.right))
				{
					ww = parentWidth - child.right - child.left;
					//超过最值，按left、right计算出距离中心的距离，然后确定位置
					if(ww > child.maxWidth)
					{
						xx = Math.round((parentWidth - child.maxWidth) / 2 + (child.left - child.right) / 2);
					}
					else if(ww < child.minWidth)
					{
						xx = Math.round((parentWidth - child.minWidth) / 2 + (child.left - child.right) / 2);
					}
				}
			}
			else if (!isNaN(child.right))
			{
				xx = parentWidth - child.right - child.width;
			}
			else if (!isNaN(child.horizontalCenter))
			{
				xx = Math.round((parentWidth - child.width) / 2 + child.horizontalCenter);
			}
			
			if (!isNaN(child.top))
			{
				yy = child.top;
				
				if (!isNaN(child.bottom))
				{
					hh = parentHeight - child.top - child.bottom;
					if(hh > child.maxHeight)
					{
						yy = Math.round((parentHeight - child.maxHeight) / 2 + (child.top - child.bottom) / 2);
					}
					else if(hh < child.minHeight)
					{
						yy = Math.round((parentHeight - child.minHeight) / 2 + (child.top - child.bottom) / 2);
					}
				}
			}
			else if (!isNaN(child.bottom))
			{
				yy = parentHeight - child.bottom - child.height;
			}
			else if (!isNaN(child.verticalCenter))
			{
				yy = Math.round((parentHeight - child.height) / 2 + child.verticalCenter);
			}
			
			if (ww > child.maxWidth)
			{
				ww = child.maxWidth;
			}
			if(ww < child.minWidth)
			{
				ww = child.minWidth;
			}
			
			if (hh > child.maxHeight)
			{
				hh = child.maxHeight;
			}
			if(hh < child.minHeight)
			{
				hh = child.minHeight;
			}
			
			child.measuredWidth = ww;
			child.measuredHeight = hh;
			child.setLayoutBoundsSize(ww, hh);
			child.setLayoutBoundsPosition(xx, yy);
		}
		
		public function updateDisplayList(container:DisplayObjectContainer, unscaledWidth:Number, unscaledHeight:Number):void
		{
			var len:int = container.numChildren;
			for (var i:int = 0; i < len; i++)
			{
				var child:UIComponent = container.getChildAt(i) as UIComponent;
				if (child)
				{
					updateLayout(child);
				}
			}
		}
	}
}