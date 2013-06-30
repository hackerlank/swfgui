package com.swfgui.managers
{
	import com.swfgui.core.Application;
	import com.swfgui.debug.Logger;
	import com.swfgui.events.DragEvent;
	import com.swfgui.queue.MethodQueueElement;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/**
	 * 详见IDragManagerImpl
	 * @author llj
	 */
	public class DragManagerImpl extends EventDispatcher implements IDragManagerImpl
	{
		protected static var list:Dictionary = new Dictionary(); //物品对应拖动管理器的临时字典
		protected static var regObject:Dictionary = new Dictionary(); //注册的拖动物品字典

		protected var trigger:DisplayObject;
		protected var target:DisplayObject;
		protected var dragImage:Object;
		protected var bounds:Rectangle;
		protected var dragData:Object;
		protected var params:Array;
		protected var onDragStart:Function;
		protected var onDragStop:Function;
		protected var onDragIng:Function;
		protected var lockCenter:Boolean;
		protected var imageAlpha:Number;

		protected var dragIcon:DisplayObject;
		/**
		 * 拖拽开始时候，鼠标在dragLayer中的位置
		 */
		protected var orgDragLayerMousePos:Point;
		/**
		 * 拖拽开始时，被拖拽元件target在dragLayer中的位置
		 */
		protected var orgDragIconPos:Point;
		/**
		 * dragIcon所在的层
		 */
		protected var dragLayer:DisplayObjectContainer;
		protected var dragOverObj:DisplayObject;
		protected var orgDragIconAlpha:Number;

		protected var outline:Shape = new Shape();

		public function DragManagerImpl()
		{

		}

		public function startDrag(target:DisplayObject, 
			dragImage:Object = "outline",
			bounds:Rectangle = null, 
			dragData:Object = null,
			params:Array = null, 
			onDragStart:Function = null,
			onDragStop:Function = null,
			onDragIng:Function = null,
			lockCenter:Boolean = false,
			imageAlpha:Number = 0.5):void
		{
			
			var dm:DragManagerImpl = new DragManagerImpl();
			dm.target = target;
			dm.dragImage = dragImage;
			dm.bounds = bounds;
			dm.dragData = dragData;
			dm.params = params;
			dm.onDragStart = onDragStart;
			dm.onDragIng = onDragIng;
			dm.onDragStop= onDragStop;
			dm.lockCenter = lockCenter;
			dm.imageAlpha = imageAlpha;

			list[target] = dm;
			dm._startDrag();
		}
		
		
		
		public function stopDrag(target:DisplayObject):void
		{
			if (list[target])
			{
				(list[target] as DragManagerImpl)._stopDrag();
			}
		}
		
		public function register(trigger:DisplayObject,
								 target:DisplayObject = null, 
								 dragImage:Object = "outline",
								 bounds:Rectangle = null, 
								 dragData:Object = null,
								 params:Array = null, 
								 onDragStart:Function = null,
								 onDragStop:Function = null,
								 onDragIng:Function = null,
								 lockCenter:Boolean = false,
								 imageAlpha:Number = 0.5):void
		{
			if(!target)
			{
				target = trigger;
			}
			
			regObject[trigger] = new MethodQueueElement(startDrag,
				[target, dragImage, bounds,dragData, params, onDragStart,
					onDragStop, onDragIng, lockCenter, imageAlpha]);
			
			trigger.addEventListener(MouseEvent.MOUSE_DOWN, onTriggerMouseDown);
		}
		
		public function unregister(trigger:DisplayObject):void
		{
			trigger.removeEventListener(MouseEvent.MOUSE_DOWN, onTriggerMouseDown);
			delete regObject[trigger];
		}
		
		public function acceptDragDrop(target:DisplayObject, cursor:DisplayObject=null):void
		{
			
		}
		
		public function rejectDragDrop(target:DisplayObject, cursor:DisplayObject=null):void
		{
			
		}
		
		protected function _startDrag():void
		{
			var e:DragEvent = new DragEvent(DragEvent.DRAG_START, target, dragData, false, true);
			target.dispatchEvent(e);
			if (e.isDefaultPrevented())
			{
				return;
			}

			if (onDragStart != null)
			{
				onDragStart.apply(null, params);
			}

			if (dragImage == DragManager.SNAPSHOT)
			{
				dragIcon = createBitmap(target);
				dragLayer = Application.instance.dragLayer;
				dragLayer.addChild(dragIcon);
			}
			else if (dragImage == DragManager.DIRECT)
			{
				dragIcon = target;
				dragLayer = target.parent;
			}
			else
			{
				if (dragImage is DisplayObject)
				{
					dragIcon = dragImage as DisplayObject;
				}
				else
				{
					outline.graphics.clear();
					outline.graphics.lineStyle(1, 0x999999);
					outline.graphics.beginFill(0xCCCCCC);
					outline.graphics.drawRect(0, 0, target.width, target.height);
					outline.graphics.endFill();
					dragIcon = outline;
				}
				
				dragLayer = Application.instance.dragLayer;
				dragLayer.addChild(dragIcon);
			}
			
			orgDragIconAlpha = dragIcon.alpha;
			dragIcon.alpha = imageAlpha;
			
			var rect:Rectangle = target.getBounds(dragLayer);
			if (lockCenter)
			{
				orgDragLayerMousePos = new Point(rect.x + rect.width / 2, rect.y + rect.height / 2);
			}
			else
			{
				orgDragLayerMousePos = new Point(dragLayer.mouseX, dragLayer.mouseY);
			}

			if (dragIcon != target)
			{
				var bd:Rectangle = target.getBounds(target);
				orgDragLayerMousePos.x -= bd.x;
				orgDragLayerMousePos.y -= bd.y;
				dragIcon.x = rect.x;
				dragIcon.y = rect.y;
			}

			orgDragIconPos = new Point(dragIcon.x, dragIcon.y);
			
			target.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			Application.instance.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Application.instance.stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			Application.instance.stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}

		protected function _stopDrag():void
		{
			var e:DragEvent = new DragEvent(DragEvent.DRAG_START, target, dragData, false, true);
			target.dispatchEvent(e);
			if (e.isDefaultPrevented())
			{
				return;
			}
			
			if(onDragStop != null)
			{
				onDragStop.apply(null, params);
			}

			target.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			Application.instance.stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			Application.instance.stage.removeEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			Application.instance.stage.removeEventListener(MouseEvent.MOUSE_OUT,onMouseOut);

			orgDragIconPos = null;
			orgDragLayerMousePos = null;
			
			dragIcon.alpha = orgDragIconAlpha;
			
			if (dragIcon != target && dragIcon.parent)
			{
				dragIcon.parent.removeChild(dragIcon);
			}

			delete list[target];
		}

		private function onTriggerMouseDown(event:MouseEvent):void
		{
			var mqe:MethodQueueElement = regObject[event.currentTarget];
			if (mqe)
			{
				mqe.method.apply(null, mqe.args);
			}
		}

		private function onEnterFrame(event:Event):void
		{
			dragIcon.x = orgDragIconPos.x + dragLayer.mouseX - orgDragLayerMousePos.x;
			dragIcon.y = orgDragIconPos.y + dragLayer.mouseY - orgDragLayerMousePos.y;
			
			forceInside(dragIcon, bounds ? bounds : 
				new Rectangle(0,0,dragLayer.width, dragLayer.height));

			if(target.hasEventListener(DragEvent.DRAG_ING))
			{
				target.dispatchEvent(new DragEvent(DragEvent.DRAG_ING, target, dragData));
			}
			
			if(onDragIng != null)
			{
				onDragIng.apply(null, params);
			}
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			_stopDrag();

			if (dragOverObj)
			{
				dragOverObj.dispatchEvent(new DragEvent(DragEvent.DRAG_DROP, target, dragData));
				dragOverObj = null;
			}

			target.dispatchEvent(new DragEvent(DragEvent.DRAG_DROP, target, dragData));
		}

		private function onMouseOver(event:MouseEvent):void
		{
			dragOverObj = event.target as DisplayObject;
			event.target.dispatchEvent(new DragEvent(DragEvent.DRAG_DROP, target, dragData));
		}

		private function onMouseOut(event:MouseEvent):void
		{
			dragOverObj = null;
			event.target.dispatchEvent(new DragEvent(DragEvent.DRAG_DROP, target, dragData));
		}

		private function createBitmap(displayObj:DisplayObject):Bitmap
		{
			var bmpd:BitmapData;
			var bounds:Rectangle = displayObj.getBounds(displayObj);

			try
			{
				if (displayObj is Bitmap)
				{
					bmpd = Bitmap(displayObj).bitmapData;
				}
				else
				{
					var matrix:Matrix = new Matrix();
					matrix.tx -= bounds.x;
					matrix.ty -= bounds.y;
					bmpd = new BitmapData(Math.ceil(bounds.width), Math.ceil(bounds.height), true, 0);
					bmpd.draw(displayObj, matrix);
				}
			}
			catch (e:Error)
			{
				bmpd = new BitmapData(100, 200, true, 0x666666);
				Logger.Warning(this, "createBitmap:" + e.message);
			}

			return new Bitmap(bmpd);
		}
		
		private function localToContent(pt:Point, source:DisplayObject, target:DisplayObject):Point
		{
			return target.globalToLocal(source.localToGlobal(pt));
		}
		
		public function forceInside(obj:DisplayObject, cotainRect:Rectangle):Boolean
		{
			var rect:Rectangle = obj.getBounds(obj.parent);
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
			
			obj.x += topLeft.x - rect.x;
			obj.y += topLeft.y - rect.y;
			
			return out;
		}
	}
}