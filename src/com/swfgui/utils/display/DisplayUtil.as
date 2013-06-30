package com.swfgui.utils.display
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class DisplayUtil
	{
		public function DisplayUtil()
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  child
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 添加到对象之后
		 * @param container
		 * @param child
		 * @param target
		 */
		public static function addChildAfter(child:DisplayObject,target:DisplayObject):void
		{
			target.parent.addChildAt(child,target.parent.getChildIndex(target) + 1);
		}
		
		/**
		 * 添加到对象之前
		 * @param container
		 * @param child
		 * @param target
		 */
		public static function addChildBefore(child:DisplayObject,target:DisplayObject):void
		{
			target.parent.addChildAt(child,target.parent.getChildIndex(target));
		}
		
		/**
		 * 获得子对象数组 
		 * @param container
		 */
		public static function getAllChild(container:DisplayObjectContainer):Array
		{
			var result:Array = [];
			var n:int = container.numChildren;
			for (var i:int = 0; i < n; i++)
			{
				result.push(container.getChildAt(i));
			}
			
			return result;
		}
		
		public static function safeRemoveChild(child:DisplayObject):void
		{
			if(child && child.parent)
			{
				child.parent.removeChild(child);
			}
		}
		
		/**
		 * 移除所有子对象
		 * @param container	目标
		 */
		public static function removeAllChild(container:DisplayObjectContainer):void
		{
			while (container.numChildren) 
			{
				container.removeChildAt(0);
			}
		}
		
		/**
		 * 批量增加子对象 
		 */
		public static function addAllChild(container:DisplayObjectContainer,children:Array):void
		{
			var n:int = children.length;
			for (var i:int = 0; i < n; i++)
			{
				if (children[i] is DisplayObject)
				{
					container.addChild(children[i]);
				}
			}
		}
		
		/**
		 * 将显示对象移至顶端
		 * @param displayObj 目标
		 */        
		public static function moveTop(displayObj:DisplayObject):void
		{
			var parent:DisplayObjectContainer = displayObj.parent;
			if (parent)
			{
				var lastIndex:int = parent.numChildren - 1;
				if (parent.getChildIndex(displayObj) < lastIndex)
				{
					parent.setChildIndex(displayObj, lastIndex);
				}
			}
		}
		
		/**
		 * 同时设置mouseEnabled以及mouseChildren
		 */        
		public static function setMouseEnabled(container:DisplayObjectContainer, value:Boolean):void
		{
			container.mouseChildren = container.mouseEnabled = value;
		}
		
		/**
		 * 同时设置buttonMode和useHandCursor
		 */
		public static function setHandCursor(sprite:Sprite, value:Boolean):void
		{
			sprite.buttonMode = sprite.useHandCursor = value;
		}
		
		/**
		 * 复制显示对象。是获取value["constructor"]进行复制的，所以如果constructor是Sprte或MovieClip等
		 * 就不能实现真正的复制了。
		 */
		public static function cloneDisplayObject(displayObj:DisplayObject):DisplayObject
		{
			var result:DisplayObject = displayObj["constructor"]();
			result.filters = result.filters;
			result.transform.colorTransform = displayObj.transform.colorTransform;
			result.transform.matrix = displayObj.transform.matrix;
			if (result is Bitmap)
			{
				Bitmap(result).bitmapData = Bitmap(displayObj).bitmapData;
			}
			return result;
		}
		
		/**
		 * 获取显示rotation，从自身开始遍历到顶层的rotation之和
		 */        
		public static function getDisplayRotation(displayObj:DisplayObject):Number
		{
			var currentTarget:DisplayObject = displayObj;
			var r:Number = 1.0;
			
			while (currentTarget && currentTarget.parent != currentTarget)
			{
				r += currentTarget.rotation;
				currentTarget = currentTarget.parent;
			}
			return r;
		}
		
		/**
		 * 获取显示scale，从自身开始遍历到顶层的scale之积
		 */ 
		public static function getDisplayScale(displayObj:DisplayObject):Point
		{
			var currentTarget:DisplayObject = displayObj;
			var scale:Point = new Point(1.0, 1.0);
			
			while (currentTarget && currentTarget.parent != currentTarget)
			{
				scale.x *= currentTarget.scaleX;
				scale.y *= currentTarget.scaleY;
				currentTarget = currentTarget.parent;
			}
			return scale;
		}
		
		/**
		 * 获取显示visible，从自身开始遍历到顶层的visible之与
		 */       
		public static function getDisplayVisible(displayObj:DisplayObject):Boolean
		{
			var currentTarget:DisplayObject = displayObj;
			while (currentTarget && currentTarget.parent != currentTarget)
			{
				if (currentTarget.visible == false)
				{
					return false;
				}
				currentTarget = currentTarget.parent;
			}
			return true;
		}
		
		/**
		 * 判断对象是否在某个容器中，广义的包含：子容器包含也算
		 */
		public static function isInContainer(displayObj:DisplayObject,
											 container:DisplayObjectContainer):Boolean
		{
			var currentTarget:DisplayObject = displayObj;
			while (currentTarget && currentTarget.parent != currentTarget)
			{
				if (currentTarget == container)
				{
					return true;
				}
				currentTarget = currentTarget.parent;
			}
			return false;
		}
		
		/**
		 * 检测对象是否在屏幕中
		 */
		public static function inScreen(displayObj:DisplayObject):Boolean
		{
			if (displayObj.stage == null)
				return false;
			
			var screen:Rectangle = Geom.getPxRect(displayObj.stage);
			return screen.containsRect(displayObj.getBounds(displayObj.stage));
		}
	}
}