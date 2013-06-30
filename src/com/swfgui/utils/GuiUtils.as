package com.swfgui.utils
{
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;

	public class GuiUtils
	{

		public function GuiUtils()
		{
			
		}

		public static function movieClipContainsLabel(clip:MovieClip, label:String):Boolean
		{
			return indexOfLabel(clip, label) >= 0;
		}

		public static function indexOfLabel(clip:MovieClip, label:String):int
		{
			var labels:Array = clip.currentLabels;
			var i:uint;
			while (i < labels.length)
			{
				if (labels[i].name == label)
				{
					return labels[i].frame - 1;
				}
				i++;
			}

			return -1;
		}

		public static function removeAllChildren(container:DisplayObjectContainer):void
		{
			var len:int = container.numChildren;
			
			while (len-- > 0)
			{
				container.removeChildAt(0);
			}
		}

		public static function bringToFront(container:DisplayObjectContainer, mc:DisplayObject):void
		{
			container.setChildIndex(mc, container.numChildren - 1);
		}

		public static function copyDisplayObject(target:DisplayObject, autoAdd:Boolean=false):DisplayObject
		{
			var rect:Rectangle;
			var targetTextField:TextField;
			var duplicateTextField:TextField;
			var targetClass:Class = Object(target).constructor;
			
			var duplicate:DisplayObject = new targetClass();
			duplicate.transform = target.transform;
			duplicate.filters = target.filters;
			duplicate.cacheAsBitmap = target.cacheAsBitmap;
			duplicate.opaqueBackground = target.opaqueBackground;
			
			if (target.scale9Grid)
			{
				rect = target.scale9Grid;
				duplicate.scale9Grid = rect;
			}

			if (target is TextField)
			{
				targetTextField = target as TextField;
				duplicateTextField = duplicate as TextField;
				duplicateTextField.defaultTextFormat = targetTextField.defaultTextFormat;
				duplicateTextField.embedFonts = targetTextField.embedFonts;
			}

			if (autoAdd && target.parent)
			{
				target.parent.addChild(duplicate);
			}

			return duplicate;
		}

	}
}