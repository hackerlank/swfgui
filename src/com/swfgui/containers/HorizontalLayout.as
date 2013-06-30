package com.swfgui.containers
{
	import com.swfgui.core.ILayout;
	import com.swfgui.core.IUIComponent;
	import com.swfgui.core.UIComponent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	public class HorizontalLayout implements ILayout
	{
		public static const LEFT:int = 1;
		public static const CENTER:int = 2;
		public static const RIGHT:int = 3;

		public var gap:int = 0;
		public var align:int = 1;

		public function HorizontalLayout()
		{
		}

		public function updateLayout(child:UIComponent):void
		{
			//updateDisplayList(child.parent);
		}

		public function updateDisplayList(container:DisplayObjectContainer, unscaledWidth:Number, unscaledHeight:Number):void 
		{
			if(!container)
			{
				return;
			}
			
			var i:int;
			var len:int;
			var arr:Array = [];
			var totalWidth:Number = 0;
			var startX:int;

			len = container.numChildren;
			for (i = 0; i < len; i++)
			{
				var child:DisplayObject = container.getChildAt(i) as DisplayObject;
				if (child.visible)
				{
					arr.push(child);
					totalWidth += child.width + gap;
				}
			}

			totalWidth -= gap;
			
			if (totalWidth < container.width)
			{
				if (align == CENTER)
				{
					startX = (container.width - totalWidth) * 0.5;
				}
				else if (align == RIGHT)
				{
					startX = container.width - totalWidth;
				}
			}

			len = arr.length;
			for (i = 0; i < len; i++)
			{
				child = arr[i] as DisplayObject;
				child.x = startX;
				startX += child.height + gap;
			}
		}
	}
}