package com.swfgui.utils.display
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;

	public class LayoutUtil
	{
		public function LayoutUtil()
		{
		}

		public static function center(child:DisplayObject, parent:DisplayObjectContainer = null,
			hcenter:Number = 0, vcenter:Number = 0):void
		{
			if(!child)
			{
				return;
			}
			if(!parent)
			{
				parent = child.parent;
			}
			if(!parent)
			{
				return;
			}
			
			var parentWidth:Number = parent.width;
			var parentHeight:Number = parent.height;
			if (parent is Stage)
			{
				parentWidth = parent.stage.stageWidth;
				parentHeight = parent.stage.stageHeight;
			}
			
			child.x = Math.round((parentWidth - child.width) * 0.5) + hcenter;
			child.y = Math.round((parentHeight - child.height) * 0.5) + vcenter;
		}

		public static function updateLayout(child:DisplayObject, parent:DisplayObjectContainer, 
			constraint:LayoutConstraint):void
		{
			if (!child || !parent || 
				(isNaN(constraint.left) && 
				constraint.left == constraint.right && 
				constraint.left == constraint.top && 
				constraint.left == constraint.bottom))
			{
				return;
			}

			var xx:Number = child.x;
			var yy:Number = child.y;
			var ww:Number = child.width;
			var hh:Number = child.height;

			var parentWidth:Number = parent.width;
			var parentHeight:Number = parent.height;

			if (parent is Stage)
			{
				parentWidth = parent.stage.stageWidth;
				parentHeight = parent.stage.stageHeight;
			}

			if (!isNaN(constraint.left))
			{
				xx = constraint.left;

				if (!isNaN(constraint.right))
				{
					if (parentWidth > 0)
					{
						ww = parentWidth - constraint.right - constraint.left;
					}
				}
			}
			else if (!isNaN(constraint.right))
			{
				xx = parentWidth - constraint.right - child.width;
			}
			else if (!isNaN(constraint.horizontalCenter))
			{
				xx = Math.round((parentWidth - child.width) / 2 + constraint.horizontalCenter);
			}


			if (!isNaN(constraint.top))
			{
				yy = constraint.top;

				if (!isNaN(constraint.bottom))
				{
					if (parentHeight > 0)
					{
						hh = parentHeight - constraint.top - constraint.bottom;
					}
				}
			}
			else if (!isNaN(constraint.bottom))
			{
				yy = parentHeight - constraint.bottom - child.height;
			}
			else if (!isNaN(constraint.verticalCenter))
			{
				yy = Math.round((parentHeight - child.height) / 2 + constraint.verticalCenter);
			}

			if (xx != child.x)
			{
				child.x = xx;
			}

			if (yy != child.y)
			{
				child.y = yy;
			}

			if (ww != child.width)
			{
				child.width = ww;
			}

			if (hh != child.height)
			{
				child.height = hh;
			}
		}
	}
}