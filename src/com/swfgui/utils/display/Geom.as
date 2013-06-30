package com.swfgui.utils.display
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 显示对象的坐标、矩形的方法。特别说明，“像素”表示元件实际显示的区域，“逻辑”代表元件的x、y、
	 * width和height等。目标坐标系target，如果不作说明，一般为父坐标系
	 */
	public final class Geom extends Object
	{
		public static function getLogicRect(source:DisplayObject, target:DisplayObject=null):Rectangle
		{
			var sourceWidth:Number;
			var sourceHeight:Number;
			
			if (source is Stage)
			{
				sourceWidth = Stage(source).stageWidth;
				sourceHeight = Stage(source).stageHeight;
			}
			else
			{
				sourceWidth = source.width;
				sourceHeight = source.height;
			}
			
			if (!target)
			{
				target = target.parent;
			}
			
			//如果使用source.getBounds(target)，则获取的x和y会很大(x=6711088, y=6711010)
			//使用source.getBounds(source)是正常的
			if (sourceWidth == 0 || sourceHeight == 0)
			{
				var pt:Point = localToTarget(new Point(), source, target);
				return new Rectangle(pt.x, pt.y, 0, 0);
			}
			else
			{
				return localRectToTarget(new Rectangle(0,0,sourceWidth, sourceHeight),
					source, target);
			}
		}
		
		/**
		 * 获得像素矩形，默认坐标系是父容器。
		 * 当源是stage时，获取的将不是像素矩形，而是舞台范围
		 * @param source 显示对象
		 * @param target 目标坐标系，默认值为父坐标系
		 * @return
		 */
		public static function getPxRect(source:DisplayObject, target:DisplayObject=null):Rectangle
		{
			if (source is Stage)
			{
				//目标为舞台则取舞台矩形
				var stageRect:Rectangle = new Rectangle(0, 0, 
					Stage(source).stageWidth, Stage(source).stageHeight);
				if (target)
				{
					return localRectToTarget(stageRect, source, target);
				}
				else
				{
					return stageRect;
				}
			}

			if (!target)
			{
				target = target.parent;
			}

			//如果使用source.getBounds(target)，则获取的x和y会很大(x=6711088, y=6711010)
			//使用source.getBounds(source)是正常的
			if (source.width == 0 || source.height == 0)
			{
				var pt:Point = localToTarget(new Point(), source, target);
				return new Rectangle(pt.x, pt.y, 0, 0);
			}

			//scrollRect要等到下一周期才会起作用
			if (source.scrollRect)
			{
				return localRectToTarget(source.scrollRect, source, target);
			}
			else
			{
				//target==null，则取source坐标系
				return source.getBounds(target);
			}
		}

		/**
		 * 获取像素上的原点，默认父亲坐标系
		 */
		public static function getPxOriginPoint(source:DisplayObject, target:DisplayObject=null):Point
		{
			if (!target)
			{
				target = source.parent;
			}

			return getPxRect(source, target).topLeft;
		}
		
		/**
		 * 获取像素中心点，默认父亲坐标系
		 * @param source
		 * @param target
		 * @return 
		 */
		public static function getPxCenterPoint(source:DisplayObject, target:DisplayObject=null):Point
		{
			if (!target)
			{
				target = source.parent;
			}
			var bound:Rectangle = getPxRect(source, target);
			return new Point(bound.x + bound.width * 0.5, bound.y + bound.height * 0.5)
		}

		//--------------------------------------------------------------------------
		//
		//  坐标系转换
		//
		//--------------------------------------------------------------------------

		/**
		 * 坐标点转换
		 * @param point 坐标点
		 * @param source 源坐标系
		 * @param target 目标坐标系，为null，则代表全局坐标系
		 * @return
		 */
		public static function localToTarget(point:Point, source:DisplayObject, target:DisplayObject=null):Point
		{
			if (target && source)
			{
				return target.globalToLocal(source.localToGlobal(point));
			}
			else if (source)
			{
				return source.localToGlobal(point);
			}

			return point;
		}
		
		public static function localXYToTarget(x:Number, y:Number, 
											   source:DisplayObject, target:DisplayObject=null):Point
		{
			var point:Point = new Point(x, y);
			if (target && source)
			{
				return target.globalToLocal(source.localToGlobal(point));
			}
			else if (source)
			{
				return source.localToGlobal(point);
			}

			return point;
		}

		/**
		 * 矩形转换
		 * @param rect 矩形
		 * @param source 源坐标系
		 * @param target 目标坐标系，为null，则代表全局坐标系
		 * @return
		 */
		public static function localRectToTarget(rect:Rectangle, source:DisplayObject, target:DisplayObject=null):Rectangle
		{
			if (source == target)
			{
				return rect;
			}

			var topLeft:Point = localToTarget(rect.topLeft, source, target);
			var bottomRight:Point = localToTarget(rect.bottomRight, source, target);
			return new Rectangle(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
		}


		public static function centerChild(child:DisplayObject):void
		{
			if (!child.parent)
			{
				return;
			}

			var bound:Rectangle = child.getBounds(child);
			child.x += bound.x;
			child.y += bound.y;
		}

		/**
		 * 由中心点开始创建一个矩形
		 *
		 * @param p	中心点
		 * @param w	宽度
		 * @param h	高度
		 * @return
		 *
		 */
		public static function createCenterRect(p:Point, w:Number, h:Number):Rectangle
		{
			return new Rectangle(p.x - w / 2, p.y - h / 2, w, h);
		}

		/**
		 * 在原点居中（当父容器长宽为0时）
		 * @param content
		 *
		 */
		public static function centerAtZero(content:DisplayObject):void
		{
			var rect:Rectangle = Geom.getPxRect(content);
			var offest:Point = new Point(content.x - rect.x,content.y - rect.y);

			content.x = - rect.width/2 + offest.x;
			content.y = - rect.height/2 + offest.y;
		}

		/**
		 * 将某个矩形限定在另一个矩形的范围内（矩形大小不变）。左上的优先度较高。
		 *
		 * @param obj	显示对象或者矩形
		 * @param cotainer	矩形的限定范围
		 * @return 是否已经移出范围
		 *
		 */
		public static function forceRectInside(obj:*, cotainer:*):Boolean
		{
			var rect:Rectangle = getPxRect(obj);
			var cotainRect:Rectangle = getPxRect(cotainer,(obj is DisplayObject) ? obj.parent : cotainer);
			var topLeft:Point = rect.topLeft;
			var out:Boolean = false;
			if (rect.right > cotainRect.right)
			{
				topLeft.x = cotainRect.right - rect.width;
				out = true;
			}
			if (rect.x < cotainRect.x)
			{
				topLeft.x = cotainRect.x;
				out = true;
			}
			if (rect.bottom > cotainRect.bottom)
			{
				topLeft.y = cotainRect.bottom - rect.height;
				out = true;
			}
			if (rect.y < cotainRect.y)
			{
				topLeft.y = cotainRect.y;
				out = true;
			}
			moveTopLeftTo(obj,topLeft);
			return out;
		}

		/**
		 * 将某个点限定在另一个矩形的范围内。
		 *
		 * @param obj	显示对象或者点
		 * @param cotainer	点的限定范围
		 * @return 是否已经移出范围
		 *
		 */
		public static function forcePointInside(obj:*, cotainer:*):Boolean
		{
			var cotainRect:Rectangle = getPxRect(cotainer,(obj is DisplayObject) ? obj.parent : cotainer);
			var out:Boolean = false;
			if (obj.x > cotainRect.right)
			{
				obj.x = cotainRect.right;
				out = true;
			}
			if (obj.x < cotainRect.x)
			{
				obj.x = cotainRect.x;
				out = true;
			}
			if (obj.y > cotainRect.bottom)
			{
				obj.y = cotainRect.bottom;
				out = true;
			}
			if (obj.y < cotainRect.y)
			{
				obj.y = cotainRect.y;
				out = true;
			}
			return out;
		}

		/**
		 * 缩放点
		 * @param p
		 * @param scale
		 * @return
		 *
		 */
		public static function scalePoint(p:Point,scale:Number):Point
		{
			p.x *= scale;
			p.y *= scale;
			return p;
		}

		/**
		 * 以中心点为基准放大矩形
		 *
		 * @param obj	显示对象或者矩形
		 * @param scale	缩放比
		 * @return
		 *
		 */
		public static function scaleByCenter(obj:*, scale:Number):void
		{
			var rect:Rectangle = getPxRect(obj);
			obj.width = obj.width * scale;
			obj.height = obj.height * scale;
			obj.x -= (obj.width - rect.width)/2;
			obj.y -= (obj.height - rect.height)/2;
		}

		/**
		 * 移动中心点至某个坐标
		 *
		 * @param obj	显示对象或者矩形
		 * @param target	目标父对象坐标
		 *
		 */
		public static function moveCenterTo(obj:*,target:Point):void
		{
			var center:Point = getPxCenterPoint(obj,obj.parent);
			obj.x += target.x - center.x;
			obj.y += target.y - center.y;
		}

		/**
		 * 移动左上角坐标到某个坐标
		 *
		 * @param obj
		 * @param target
		 *
		 */
		public static function moveTopLeftTo(obj:*,target:Point,space:DisplayObjectContainer = null):void
		{
			if (!space && (obj is DisplayObject))
				space = obj.parent;

			var topLeft:Point = getPxRect(obj,space).topLeft;
			obj.x += target.x - topLeft.x;
			obj.y += target.y - topLeft.y;
		}

		/**
		 * 让对象在范围内居中
		 *
		 * @param obj	显示对象或者矩形
		 * @param cotainer	容器区域
		 *
		 */
		public static function centerIn(obj:*,cotainer:*,space:DisplayObjectContainer = null):void
		{
			if (!space && (obj is DisplayObject))
				space = obj.parent;

			moveCenterTo(obj, getPxCenterPoint(cotainer,space));
		}

		/**
		 * 拷贝坐标
		 *
		 * @param source	源数据
		 * @param target	目标对象
		 *
		 */
		public static function copyPosition(source:*,target:*):void
		{
			target.x = source.x;
			target.y = source.y;
		}

		/**
		 * 扩展一个矩形的范围，将一个点包括在矩形内
		 *
		 * @param source
		 * @param x
		 * @param y
		 *
		 */
		public static function unionPoint(source:*,x:Number=NaN,y:Number=NaN):void
		{
			var rect:Rectangle = getPxRect(source);
			if (!isNaN(x))
			{
				if (x < rect.x)
				{
					source.x = x;
					source.width = rect.right - x;
				}
				else if (x > rect.right)
				{
					source.width = x - rect.x;
				}
			}
			if (!isNaN(y))
			{
				if (y < rect.y)
				{
					source.y = y;
					source.height = rect.bottom - y;
				}
				else if (y > rect.bottom)
				{
					source.height = y - rect.y;
				}
			}
		}
		
		public static const TOP:int = 1;
		public static const BOTTOM:int = 7;
		public static const LEFT:int = 3;
		public static const RIGHT:int = 5;
		public static const CENTER:int = 4;
		public static const MIDDLE:int = 4;
		public static const LEFT_TOP:int = 0;
		public static const RIGHT_TOP:int = 2;
		public static const LEFT_BOTTOM:int = 6;
		public static const RIGHT_BOTTOM:int = 8;

		/**
		 * 获得第一个矩形相对与第二个矩形的位置，
		 * 参见XXX常量
		 * @param v1
		 * @param v2
		 * @return 返回值为九宫格方向，即：
		 * 0.左上 1.上 2.右上
		 * 3.左 4.中 5.右
		 * 6.左下 7.下 8.右下
		 *
		 * 边界优先级为 包含>边线>角线
		 *
		 */
		public static function getRelativeLocation(v1:*,v2:*=null):int
		{
			var r1:Rectangle = getPxRect(v1);
			var r2:Rectangle = getPxRect(v2);
			return (r1.right <= r2.left ? 0 : r1.left >= r2.right ? 2 : 1) +
				(r1.bottom <= r2.top ? 0 : r1.top >= r2.bottom ? 6 : 3);
		}
		
		/**
		 * 在父容器的位置，结果参见XXX常量
		 * @param source
		 * @return 
		 */
		public static function getInParentLocation(source:DisplayObject):int
		{
			var r1:Rectangle = getPxRect(source);
			var r2:Rectangle = getPxRect(source.parent, source.parent);
			return (r1.left <= r2.right - r1.right ? 0 : 2) +
				(r1.top <= r2.bottom - r1.bottom ? 0 : 6);
		}
		
		public static function getHAlin(source:DisplayObject):int
		{
			var cc:int = getPxCenterPoint(source).x;
			var r2:Rectangle = getPxRect(source.parent, source.parent);
			var pc:int = r2.x + r2.width * 0.5;
			
			if(cc < pc)
			{
				return cc < pc - cc ? LEFT : CENTER;
			}
			else
			{
				return r2.right - cc < cc - pc ? RIGHT : CENTER;
			}
		}
		
		public static function getVAlin(source:DisplayObject):int
		{
			var cc:int = getPxCenterPoint(source).y;
			var r2:Rectangle = getPxRect(source.parent, source.parent);
			var pc:int = r2.y + r2.height * 0.5;
			
			if(cc < pc)
			{
				return cc < pc - cc ? TOP : MIDDLE;
			}
			else
			{
				return r2.bottom - cc < cc - pc ? BOTTOM : MIDDLE;
			}
		}

		/**
		 * 与getRelativeLocation在边界上判断有所差异
		 * 边界优先级为 角线>边线>包含
		 *
		 * 两个方法综合便可判断出所有情况
		 *
		 * @param v1
		 * @param v2
		 * @return
		 *
		 */
		public static function getRelativeLocation2(v1:*,v2:*):int
		{
			var r1:Rectangle = getPxRect(v1);
			var r2:Rectangle = getPxRect(v2);
			return (r1.left < r2.left ? 0 : r1.right > r2.right ? 2 : 1) +
				(r1.top < r2.top ? 0 : r1.bottom > r2.bottom ? 6 : 3)
		}
	}
}


