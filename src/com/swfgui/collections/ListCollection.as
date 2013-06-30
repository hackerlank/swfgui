package com.swfgui.collections
{
	import mx.charts.AreaChart;

	public class ListCollection implements ICollection
	{
		private var data:Object;
		
		public function get array():Array
		{
			return data as Array;
		}
		
		/**
		 * 要求xmlList中xml的节点名都一样
		 */
		public function get xmlList():XMLList
		{
			return data as XMLList;
		}
		
		public function get xml():XML
		{
			return xmlList ? xmlList.parent() : null;
		}
		
		public function get vector():Object
		{
			return data;
		}
		
		
		
		public function ListCollection()
		{
		}
		
		
		
		public function get length():int
		{
			if(array)
			{
				return array.length;
			}
			else if(xmlList)
			{
				return xmlList.length();
			}
			else if(vector)
			{
				return vector.length;
			}
			
			return 0;
		}
		
		/**
		 * 向列表末尾添加指定项目
		 */
		public function addItem(item:Object):void
		{
			if(array)
			{
				array.push(item);
			}
			else if(xml)
			{
				xml.appendChild(item);
				data = xml.elements(item.name());
			}
			else if(vector)
			{
				vector.push(item);
			}
		}
		
		/**
		 * 在指定的索引处添加项目
		 */
		public function addItemAt(item:Object, index:int):void
		{
			if(array)
			{
				array.splice(index, 0, item);
			}
			else if(xml)
			{
				var target:XML = getItemAt(index) as XML;
				if(target)
				{
					xml.insertChildBefore(target, item);
					data = xml.elements(item.name());
				}
			}
			else if(vector)
			{
				if(index < length)
				{
					vector.splice(index, 0, item);
				}
			}
		}
		
		/**
		 * 返回指示视图是否包含指定对象的信息
		 */
		public function contains(item:Object):Boolean
		{
			return getItemIndex(item) != -1;
		}
		
		/**
		 * 获取指定索引处的项目
		 */
		public function getItemAt(index:int):Object
		{
			if(index < 0)
			{
				return null;
			}
			
			if(array)
			{
				return array[index];
			}
			else if(xmlList)
			{
				return xmlList[index];
			}
			else if(vector)
			{
				if(index < length)
				{
					return vector[index];
				}
			}
			
			return null;
		}
		
		/**
		 * 果项目位于列表中（这样的话 getItemAt(index) == item），则返回该项目的索引。
		 */
		public function getItemIndex(item:Object):int
		{
			if(array)
			{
				return array.indexOf(item);
			}
			else if(xmlList)
			{
				var i:int;
				for each(var x:XML in xmlList)
				{
					if(x == item)
					{
						return i;
					}
					i++;
				}
			}
			else if(vector)
			{
				return vector.indexOf(item);
			}
			
			return -1;
		}
				
		/**
		 * 删除指定索引处的项目并返回该项目
		 */
		public function removeItem(item:Object):Object
		{
			var index:int = getItemIndex(item);
			return removeItemAt(index);
		}
		
		/**
		 * 删除指定索引处的项目并返回该项目
		 */
		public function removeItemAt(index:int):Object
		{
			if(index < 0 || index >= length)
			{
				return null;
			}
			
			if(array)
			{
				return array.splice(index, 1);
			}
			else if(xmlList)
			{
				var x:XML = xmlList[index];
				delete xmlList[index];
				return x;
			}
			else if(vector)
			{
				return vector.splice(index, 1);
			}
			
			return null;
		}
		
		/**
		 * 在指定的索引处放置项目，返回被替换的项目
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			if(index < 0)
			{
				return null;
			}
			
			var obj:Object;
			if(array)
			{
				obj = array[index];
				array[index] = item;
			}
			else if(xmlList)
			{
				if(index < length)
				{
					obj = xmlList[index];
					xmlList[index] = item;
				}
			}
			else if(vector)
			{
				if(index < length)
				{
					obj = array[index];
					array[index] = item;
				}
			}
			
			return obj;
		}
		
		public function hasItemByProperty(propertyName:String, propertyValue:String):Boolean
		{
			return getItemIndexByProperty(propertyName, propertyValue) != -1;
		}
		
		public function getItemByProperty(propertyName:String, propertyValue:String):Object
		{
			return getItemAt(getItemIndexByProperty(propertyName, propertyValue));
		}
		
		public function removeItemByProperty(propertyName:String, propertyValue:String):Object
		{
			return removeItemAt(getItemIndexByProperty(propertyName, propertyValue));
		}
		
		public function getItemIndexByProperty(propertyName:String, propertyValue:String):int
		{
			var item:Object;
			var i:int;
			if(array)
			{
				for each(item in array)
				{
					if(item[propertyName] == propertyValue)
					{
						return i;
					}
					i++;
				}
			}
			else if(xmlList)
			{
				for each(var x:XML in xmlList)
				{
					if(x.attribute(propertyName) == propertyValue)
					{
						return i;
					}
					i++
				}
			}
			else if(vector)
			{
				for each(item in vector)
				{
					if(item[propertyName] == propertyValue)
					{
						return i;
					}
					i++
				}
			}
			
			return -1;
		}
		
		public function addAll(items:Object):void
		{
			if(array)
			{
				data = array.concat(items);
			}
			else if(xml)
			{
				for each(var x:XML in items)
				{
					xml.appendChild(x);
				}
				data = xml.elements(x.name());
			}
			else if(vector)
			{
				data = vector.concat(items);
			}
		}
		
		public function removeAll():void
		{
			if(array)
			{
				array.length = 0;
			}
			else if(xmlList)
			{
				var n:int = length;
				while(n-- > 0)
				{
					delete xmlList[0];
				}
			}
			else if(vector)
			{
				vector.length = 0;
			}
		}
	}
}