package com.swfgui.controls
{
	import flash.events.Event;
	import flash.text.TextFieldType;
	
	[Event(name="change", type="flash.events.Event")]
	
	public class TextInput extends TextBase
	{
	
		private var _editable:Boolean;
		
		public function TextInput(viewSource:Object=null)
		{
			super(viewSource);
		}
		
		override public function get className():String
		{
			return "TextInput";
		}
		
		override public function dispose():void
		{
			if(hasDisposed)
			{
				return;
			}
			
			_viewText.removeEventListener(Event.CHANGE, onTextChange);
			
			super.dispose();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			this.viewText.type = TextFieldType.INPUT;
			this.selectable = true;
			this._editable = true;
			this.viewText.multiline = false;
			this.viewText.wordWrap = false;
			
			_viewText.addEventListener(Event.CHANGE, onTextChange);
		}
		
		private function onTextChange(event:Event):void
		{
			event.stopPropagation();
			this.dispatchEvent(event);
		}
		
		public function get displayAsPassword():Boolean
		{
			return viewText.displayAsPassword;
		}

		public function set displayAsPassword(value:Boolean):void
		{			
			viewText.displayAsPassword = value;
		}

		public function get maxChars():int
		{
			return viewText.maxChars;
		}

		public function set maxChars(value:int):void
		{
			viewText.maxChars = value;
		}

		public function get restrict():String
		{
			return viewText.restrict;
		}

		public function set restrict(value:String):void
		{
			viewText.restrict = value;
		}

		public function get editable():Boolean
		{
			return _editable;
		}

		public function set editable(value:Boolean):void
		{
			if(_editable == value)
			{
				return;
			}
			
			_editable = value;
			
			viewText.type = _editable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
		}
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			if(!value)
			{
				viewText.type = TextFieldType.DYNAMIC;
			}
			else
			{
				viewText.type = _editable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			}
		}
		
	}
}