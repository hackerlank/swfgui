package com.swfgui.containers
{
	import com.swfgui.core.ILayout;
	import com.swfgui.core.IUIComponent;
	import com.swfgui.core.UIComponent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	public class VerticalLayout implements ILayout
	{
		public static const TOP:int = 1;
		public static const MIDDLE:int = 2;
		public static const BOTTOM:int = 3;

		public var gap:int = 2;
		public var align:int = 1;

		public function VerticalLayout()
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
			var totalHeight:Number = 0;
			var startY:int;
			var child:DisplayObject;

			len = container.numChildren;
			for (i = 0; i < len; i++)
			{
				child = container.getChildAt(i) as DisplayObject;
				if (child.visible)
				{
					arr.push(child);
					totalHeight += child.height + gap;
				}
			}

			totalHeight -= gap;
			
			if (totalHeight < container.height)
			{
				if (align == MIDDLE)
				{
					startY = (container.height - totalHeight) * 0.5;
				}
				else if (align == BOTTOM)
				{
					startY = container.height - totalHeight;
				}
			}

			len = arr.length;
			for (i = 0; i < len; i++)
			{
				child = arr[i] as DisplayObject;
				
				if(child is UIComponent)
				{
					UIComponent(child).setLayoutBoundsPosition(child.x, startY);
				}
				else
				{
					child.y = startY;
				}
				//child.x = (container.width - child.width) * 0.5;
				startY += child.height + gap;
			}
		}
	}
}