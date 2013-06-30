package com.swfgui.controls
{
	import com.swfgui.events.ListEvent;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	public class ComboBox extends DropDownListBase
	{
		protected static const TEXT_INPUT:String = "textInput";
		
		private var _textInput:TextInput;
		private var _editable:Boolean = false;
		private var _restrict:String;
		private var _text:String;
		private var _labelFunc:Function;
		
		public function ComboBox(viewSource:Object=null)
		{
			super(viewSource);
		}
		
		override protected function initialize():void
		{
			var txt:DisplayObject = viewContainer.getChildByName(TEXT_INPUT);
			_textInput = new TextInput(txt);
			_textInput.editable = false;
			_textInput.selectable = false;
			_textInput.left = _textInput.right = 0;
			_textInput.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			super.initialize();
			
			this.listRendererClass = ComboBoxRenderer;
			this.itemBindFunc = onItemBind;
		}
		
		private function onItemBind(item:ComboBoxRenderer):void
		{
			item.viewText.text = _labelFunc != null ? _labelFunc(item.data) : String(item.data);
		}
		
		override protected function onListChange(event:ListEvent):void
		{
			super.onListChange(event);

			if(_textInput)
			{
				_textInput.text = _labelFunc != null ? _labelFunc(list.selectedData) : String(list.selectedData);
			}
		}
		
		override protected function updateSize():void
		{
			super.updateSize();
		}

		public function get textInput():TextInput
		{
			return _textInput;
		}

		public function get editable():Boolean
		{
			return _textInput.editable;
		}

		public function set editable(value:Boolean):void
		{
			_textInput.editable = value;
			_textInput.selectable = value;
			if(value)
			{
				_textInput.removeEventListener(MouseEvent.CLICK, onMouseClick);
			}
			else
			{
				_textInput.addEventListener(MouseEvent.CLICK, onMouseClick);
			}
		}
		
		public function get restrict():String
		{
			return _textInput.restrict;
		}

		public function set restrict(value:String):void
		{
			_textInput.restrict = value;
		}

		public function get text():String
		{
			return _textInput.text;
		}

		public function set text(value:String):void
		{
			_textInput.text = value;
		}

		public function get labelFunc():Function
		{
			return _labelFunc;
		}

		public function set labelFunc(value:Function):void
		{
			_labelFunc = value;
		}

	}
}
import com.swfgui.controls.ListItemRenderer;

import flash.display.DisplayObject;
import flash.text.TextField;

class ComboBoxRenderer extends ListItemRenderer
{
	public function ComboBoxRenderer(view:Object=null)
	{
		super(view);
	}
	
	public var viewText:TextField;
	
	override protected function initialize():void
	{
		super.initialize();
		
		this.left = this.right = 0;
		
		if(view is TextField)
		{
			viewText = view as TextField;
		}
		else
		{
			for each(var child:DisplayObject in getAllChild())
			{
				if(child is TextField)
				{
					viewText = child as TextField;
					break;
				}
			}
		}
	}
	
	override protected function updateSize():void
	{
		super.updateSize();
		viewText.width += width - oldWidth;
	}
}