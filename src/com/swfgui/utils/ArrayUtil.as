package com.swfgui.utils
{
    public class ArrayUtil
    {
        public static function hasItem(item:Object, source:Array):Boolean
        {
            if (!source)
            {
                return false;
            }
            
            return source.indexOf(item) != -1;
        }

        public static function hasItemByProperty(
            propertyName:String, propertyValue:Object, source:Array):Boolean
        {
            if (!source)
            {
                return false;
            }

            for each (var i:Object in source)
            {
                if (i[propertyName] == propertyValue)
                {
                    return true;
                }
            }

            return false;
        }

        public static function getItemIndex(item:Object, source:Array):int
        {
            if (!source)
            {
                return -1;
            }

			return source.indexOf(item);
        }

        public static function getItemIndexByProperty(			
            propertyName:String, propertyValue:Object, source:Array):int
        {
            if (!source)
            {
                return -1;
            }

            var len:int = source.length;

            for (var i:int = 0; i < len; i++)
            {
                if (source[i][propertyName] == propertyValue)
                {
                    return i;
                }
            }

            return -1;
        }

        public static function getItemByProperty(
            propertyName:String, propertyValue:Object, source:Array):Object
        {
            if (!source)
            {
                return null;
            }

            var len:int = source.length;

            for each (var i:Object in source)
            {
                if (i[propertyName] == propertyValue)
                {
                    return i;
                }
            }

            return null;
        }
		
		public static function deleteItem(item:Object, source:Array):void
		{
			if (!source)
			{
				return;
			}
			
			var len:int = source.length;
			
			for (var i:int = 0; i < len; i++)
			{
				if (source[i] == item)
				{
					source.splice(i--, 1);
					len--;
				}
			}
		}
		
		public static function deleteItemByProperty(
			propertyName:String, propertyValue:Object, source:Array):Object
		{
			if (!source)
			{
				return null;
			}
			
			var len:int = source.length;
			var item:Object;
			
			for (var i:int = 0; i < len; i++)
			{
				if (source[i][propertyName] == propertyValue)
				{
					item = source[i];
					source.splice(i--, 1);
					len--;
				}
			}
			
			return item;
		}
    }
}