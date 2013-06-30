package com.swfgui.controls
{
	import com.swfgui.utils.ArrayUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	[Event(name="change",type="flash.events.Event")]
	
	/**
	 * 请使用getGroupByName获取实例
	 * @author llj
	 */
	public class RadioButtonGroup extends EventDispatcher
	{
		private static var groups:Dictionary = new Dictionary();
		
		/**
		 * 获取单选框组
		 *  
		 * @param groupName
		 * @return 
		 */
		public static function getGroupByName(groupName:String):RadioButtonGroup
		{
			if(!groupName || groupName == "")
			{
				return null;
			}
			
			if (!groups[groupName])
			{
				var group:RadioButtonGroup= new RadioButtonGroup(new ForbidClass());
				group.groupName = groupName;
				groups[groupName] = group;
			}
			
			return groups[groupName];
		}
		
		private var _groupName:String;
		
		private var _items:Array = [];
		
		private var _selectedItem:RadioButton;
		
		
		/**
		 * 手动执行构造方法是无效的，应当使用getGroupByName方法创建
		 */
		public function RadioButtonGroup(forbidClass:ForbidClass)
		{
			
		}
		
		/**
		 * 当前选中的RadioButton
		 */
		public function get selectedItem():RadioButton
		{
			return _selectedItem;
		}
		
		public function set selectedItem(value:RadioButton):void
		{
			if (_selectedItem == value)
			{
				return;
			}
			
			_selectedItem = value;
			
			var hasItem:Boolean;
			var n:int = items.length;
			for (var i:int = 0; i < n; i++)
			{
				var item:RadioButton = items[i] as RadioButton;
				if(item == value)
				{
					hasItem = true;
					item.selected = true;
				}
				else
				{
					item.selected = false;
				}
			}

			_selectedItem = hasItem ? value : null;
			if(hasEventListener(Event.CHANGE))
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		/**
		 * 当前选中的RadioButton的值
		 */
		public function get selectedValue():Object
		{
			return _selectedItem ? _selectedItem.value : null;
		}
		
		public function set selectedValue(value:Object):void
		{
			if(selectedValue == value)
			{
				return;
			}
			
			selectedItem = ArrayUtil.getItemByProperty("value", value, items) as RadioButton;
		}
		
		/**
		 * 增加RadioButton
		 * @param item
		 */
		public function addItem(item:RadioButton):void
		{
			if(!item || ArrayUtil.hasItem(item, items))
			{
				return;
			}
			
			if(item.groupName != groupName)
			{
				item.groupName = groupName;
			}
			
			if (items)
			{
				items.push(item);
			}
			else
			{
				items = [item];
			}
		}
		
		/**
		 * 删除RadioButton
		 * @param item
		 */
		public function removeItem(item:RadioButton):void
		{
			if (item && items)
			{
				ArrayUtil.deleteItem(item, items);
				if (items.length == 0)
				{
					delete groups[groupName];
				}
			}
		}

		/**
		 * 组名，可以赋值给RadioButton.groupName
		 * @default 
		 */
		public function get groupName():String
		{
			return _groupName;
		}

		/**
		 * @private
		 */
		public function set groupName(value:String):void
		{
			_groupName = value;
		}

		/**
		 * 该RadioButtonGroup管理的所有RadioButton
		 */
		public function get items():Array
		{
			return _items;
		}

		/**
		 * @private
		 */
		public function set items(value:Array):void
		{
			_items = value;
			for each(var item:RadioButton in value)
			{
				if(item && item.groupName != groupName)
				{
					item.groupName = groupName;
				}
			}
		}
	}
}

class ForbidClass{}