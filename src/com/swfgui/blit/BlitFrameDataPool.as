package com.swfgui.blit
{
	import flash.utils.Dictionary;

	public class BlitFrameDataPool extends Object
	{
		public function BlitFrameDataPool()
		{
			super();
		}
				
		private var mapItems:Dictionary = new Dictionary();
		private var mapRefrences:Dictionary = new Dictionary();
		
		/**
		 * 引用项目，如果不存在，则新建
		 * @param key
		 * @return 
		 */
		public function refrenceItem(key:String):Vector.<BlitFrameData>
		{
			var item:Vector.<BlitFrameData> = getItem(key);
			if(!item)
			{
				item = new Vector.<BlitFrameData>();
				addItem(key, item);
			}
			return item;
		}
		
		/**
		 * 去除引用项目，如果引用计数为0，则自动dispose
		 * @param key
		 * @param item
		 */
		public function unrefrenceItem(key:String=null, item:Vector.<BlitFrameData>=null):void
		{
			if(!key)
			{
				key = getKey(item);
			}
			if(key && mapRefrences[key])
			{
				var count:int = int(mapRefrences[key]) - 1;
				if(count <= 0)
				{
					disposeItem(key);
				}
				else
				{
					mapRefrences[key] = count;
				}
			}
		}
		
		public function addItem(key:String, item:Vector.<BlitFrameData>):void
		{
			var org:Vector.<BlitFrameData> = mapItems[key];
			if(org && org != item)
			{
				if(mapRefrences[key] > 0)
				{
					trace("BlitFrameDataPool,禁止替换:" + key);
					return;
				}
				else
				{
					trace("BlitFrameDataPool,项目替换:" + key);
				}
			}
			mapItems[key] = item;
			mapRefrences[key] = 0;
		}
		
		/**
		 * 删除项目，但不销毁
		 * @param key
		 * @return 
		 */
		public function removeItem(key:String):Vector.<BlitFrameData>
		{
			var item:Vector.<BlitFrameData> = mapItems[key];
			delete mapItems[key];
			delete mapRefrences[key];
			return item;
		}
		
		public function hasItem(key:String):Boolean
		{
			return Boolean(mapItems[key]);
		}
		
		/**
		 * 获取项目，但不增加引用次数
		 * @param key
		 * @return 
		 */
		public function getItem(key:String):Vector.<BlitFrameData>
		{
			return mapItems[key] as Vector.<BlitFrameData>;
		}
		
		/**
		 * 销毁项目
		 * @param key
		 * @param item
		 */
		public function disposeItem(key:String=null, item:Vector.<BlitFrameData>=null):void
		{
			if(key)
			{
				item = getItem(key);
			}
			else
			{
				key = getKey(item);
			}
			
			if(item)
			{
				for each(var bfd:BlitFrameData in item)
				{
					bfd.dispose();
				}
			}
			
			if(key)
			{
				removeItem(key);
			}
		}
		
		public function disposeAllItem():void
		{
			for each(var item:Vector.<BlitFrameData> in mapItems)
			{
				for each(var bfd:BlitFrameData in item)
				{
					bfd.dispose();
				}
			}
			
			mapItems = new Dictionary();
			mapRefrences = new Dictionary();
		}
		
		private function getKey(item:Vector.<BlitFrameData>):String
		{
			for(var key:String in mapItems)
			{
				if(mapItems[key] == item)
				{
					return key;
				}
			}
			
			return null;
		}
	}
}