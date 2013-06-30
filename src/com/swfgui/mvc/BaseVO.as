package com.swfgui.mvc
{
	import com.swfgui.interfaces.IDisposable;

	public class BaseVO extends Object implements IDisposable
	{
		private var _hasDisposed:Boolean;
		private var _id:int;
		private var _name:String;
		private var _desc:String;
		
		public function BaseVO()
		{
			super();
		}
		
		/**
		 * 销毁对象：一般需要把属性置null，删除事件监听器……
		 */
		public function dispose():void
		{
			_hasDisposed = true;
		}
		
		/**
		 * 防止重复Dispose
		 * @return
		 */
		public function get hasDisposed():Boolean
		{
			return _hasDisposed;
		}

		public function get id():int
		{
			return _id;
		}

		public function set id(value:int):void
		{
			_id = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get desc():String
		{
			return _desc;
		}

		public function set desc(value:String):void
		{
			_desc = value;
		}


	}
}