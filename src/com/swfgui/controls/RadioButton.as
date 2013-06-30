package com.swfgui.controls
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	public class RadioButton extends ToggleButton
	{
		private var _group:RadioButtonGroup;
		private var _groupName:String = "radioGroup";
		private var _value:Object;

		public function RadioButton(viewSource:Object=null)
		{
			super(viewSource);
			
			_group = RadioButtonGroup.getGroupByName(_groupName);
			_group.addItem(this);
		}
		
		override protected function onMouseClk(e:MouseEvent):void
		{
			this.selected = true;
		}
		
		override public function set selected(value:Boolean):void
		{
			if(value && group && group.selectedItem != this)
			{
				group.selectedItem = this;
			}
			
			super.selected = value;
		}

		public function get group():RadioButtonGroup
		{
			return _group;
		}
		
		public function get groupName():String
		{
			return _groupName;
		}

		public function set groupName(value:String):void
		{
			if (_groupName == value)
			{
				return;
			}

			//从以前的组中删除
			if(group)
			{
				group.removeItem(this);
			}
			
			_groupName = value;
			_group = RadioButtonGroup.getGroupByName(value);
			
			//添加到新组中
			if (group)
			{
				group.addItem(this);
			}
		}

		public function get value():Object
		{
			return _value;
		}

		public function set value(value:Object):void
		{
			_value = value;
		}
	}
}