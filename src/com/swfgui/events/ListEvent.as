package com.swfgui.events
{
	import com.swfgui.core.IListItemRenderer;
	
	import flash.events.Event;
	
	public class ListEvent extends Event
	{
		/**
		 * 
		 * @default 
		 */
		public static const CHANGE:String = "change";
		
		private var _newDataIndex:int;
		private var _oldDataIndex:int;
		private var _newItem:IListItemRenderer;
		private var _oldItem:IListItemRenderer;
			
		public function ListEvent(type:String, 
								  newDataIndex:int, 
								  oldDataIndex:int, 
								  newItem:IListItemRenderer=null, 
								  oldItem:IListItemRenderer=null,
								  bubbles:Boolean=false, 
								  cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_newDataIndex = newDataIndex;
			_oldDataIndex = oldDataIndex;
			_newItem = newItem;
			_oldItem = oldItem;
		}
		
		override public function clone():Event
		{
			return new ListEvent(type,newDataIndex,oldDataIndex,
				newItem,oldItem,bubbles,cancelable);
		}

		public function get newDataIndex():int
		{
			return _newDataIndex;
		}

		public function get oldDataIndex():int
		{
			return _oldDataIndex;
		}

		public function get newItem():IListItemRenderer
		{
			return _newItem;
		}

		public function get oldItem():IListItemRenderer
		{
			return _oldItem;
		}

	}
}