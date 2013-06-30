package com.swfgui.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.geom.Matrix;
	import flash.sampler.getSize;
	import flash.utils.getQualifiedClassName;

	import com.swfgui.debug.Logger;

	public class Utils
	{
		public function Utils()
		{
		}


		/**
		 *  取得标准输出格式
		 * @param obj  当前对象
		 * @param stringLength  输出字符串长度
		 * @return
		 *
		 */
		public static function getClassName(obj:Object, stringLength:int=40):String
		{

			var tmpString:String = "";

			//Class Name
			var classString:String = getQualifiedClassName(obj);
			var tmpArr:Array = classString.split(".");
			classString = tmpArr[tmpArr.length-1];


			//Date string
			var date:Date = new Date();
			//var date:Date = GlobalData.getServerDate();

			var strHours:String = String(date.getHours());
			while (strHours.length < 2)
			{
				strHours = "0" + strHours;
			}

			var strMinutes:String = String(date.getMinutes());
			while (strMinutes.length<2)
			{
				strMinutes = "0" + strMinutes;
			}

			var strSeconds:String = String(date.getSeconds());
			while (strSeconds.length<2)
			{
				strSeconds = "0" + strSeconds;
			}

			var strMilliseconds:String = String(date.getMilliseconds());
			while (strMilliseconds.length<3)
			{
				strMilliseconds = "0" + strMilliseconds;
			}

			var dateString:String = strHours + ":" + strMinutes + ":" + strSeconds + "." + strMilliseconds;


			tmpString = "[" + dateString + "] - " + "[" + classString + "]   ";

			return tmpString;
		}
		
		/**
		 * 将字符串分隔成需要的属性
		 * 返回的数组中, 偶数index为普通字符串, 奇数index为tag
		 * @param strSour
		 * @param beginDelimitter
		 * @param endDelimiter
		 * 
		 */		
		public static function SeparateIntoTags(strSour:String, 
												beginDelimitter:String = "{", 
												endDelimiter:String = "}"):Array
		{
			var arrReturn:Array = [];
			
			var arr1:Array = strSour.split(beginDelimitter);
			var i:int;
			
			arrReturn.push(arr1[0]);//	<- {
			
			for(i = 1; i < arr1.length; i++)
			{
				var arr2:Array = arr1[i].toString().split(endDelimiter);
				if(arr2.length == 2)
				{
					arrReturn.push(arr2[0]);
					arrReturn.push(arr2[1]);
				}
				else
				{
					Logger.Throwing(Utils, "SeparateIntoTags compiler error at [" + arr1[i] + "]");
				}
			}
			
			return arrReturn;
		}


		/**
		 * 取得当前时间(s:ms)
		 * @return
		 *
		 */
		public static function getNow():String
		{
			var tmpDate:Date = new Date();
			return (tmpDate.getSeconds() + ":" + tmpDate.getMilliseconds());
		}


		/**
		 * 由int转boolean数组
		 * @param num
		 * @return [Boolean]
		 */
		public static function getBooleanArrayByInt(num:int):Array
		{
			return [
				int((num%0x02)/0x01)==1,
				int((num%0x04)/0x02)==1,
				int((num%0x08)/0x04)==1,
				int((num%0x10)/0x08)==1,
				int((num%0x20)/0x10)==1,
				int((num%0x40)/0x20)==1,
				int((num%0x80)/0x40)==1,
				int((num%0x100)/0x80)==1
				];
		}


		/**
		 * 由boolean数组转int
		 * @param arr
		 */
		public static function getIntByBooleanArray(arr:Array):int
		{
			var num:int = 0;
			for (var i:int = 0; i < arr.length; i++)
			{
				num += arr[i] ? Math.pow(2, i) : 0;
			}
			return num;
		}


		/**
		 * 转由";"分隔的字符串配制, 到object的配制
		 * @param string
		 */
		public static function getConfigByString(string:String):Object
		{
			var obj:Object = new Object();
			var arr:Array = string.split(";");
			var i:int;
			for (i = 0; i < arr.length; i++)
			{
				var tagName:String = String(arr[i]).split("=")[0];
				obj[tagName] = String(arr[i]).substring(tagName.length + 1, String(arr[i]).length);
			}
			return obj;
		}


		/**
		 *  取得某一displayObjectContainer下所有子对象的数量
		 * @param displayObjectContainer
		 */
		public static function getAllChildrenNum(displayObjectContainer:DisplayObjectContainer):int
		{
			var num:int = 0;
			var i:int = 0;
			num += displayObjectContainer.numChildren;
			for (i = 0; i < displayObjectContainer.numChildren; i++)
			{
				if (displayObjectContainer.getChildAt(i) is DisplayObjectContainer)
				{
					num += getAllChildrenNum(displayObjectContainer.getChildAt(i) as DisplayObjectContainer);
				}
			}
			return num;
		}


		/**
		 *  取得某一displayObjectContainer下所有mouseEnabled子对象的数量
		 * @param displayObjectContainer
		 */
		public static function getAllMouseEnabledChildrenNum(displayObjectContainer:DisplayObjectContainer):int
		{
			if (displayObjectContainer.mouseChildren == false)
				return 1;
			var num:int = 0;
			var i:int = 0;
			for (i=0; i<displayObjectContainer.numChildren; i++)
			{
				if ((displayObjectContainer.getChildAt(i) is InteractiveObject) 
					&& (displayObjectContainer.getChildAt(i) as InteractiveObject).mouseEnabled)
				{
					num += 1;
				}
				if ((displayObjectContainer.getChildAt(i) is DisplayObjectContainer) 
					&& (displayObjectContainer.getChildAt(i) as DisplayObjectContainer).mouseChildren)
				{
					num += getAllMouseEnabledChildrenNum(displayObjectContainer.getChildAt(i) as DisplayObjectContainer);
				}
			}
			return num;
		}


		/**
		 * 取得某一displayObjectContainer下所有子对象的字符输出
		 * @param displayObjectContainer
		 * @param space
		 */
		public static function getAllChildrenOutputString(displayObjectContainer:DisplayObjectContainer, space:int=1):String
		{
			var spaceString:String = "\n*   ";

			var spaceNum:int = space;
			while (spaceNum > 0)
			{
				spaceString += "   ";
				spaceNum --;
			}

			var string:String = "";
			var i:int = 0;
			for (i = 0; i < displayObjectContainer.numChildren; i++)
			{
				var obj:DisplayObject = displayObjectContainer.getChildAt(i);
				var tmpArr:Array = String(displayObjectContainer.getChildAt(i)).split(".");
				var mem:Number = getSize(displayObjectContainer.getChildAt(i));
				string += (spaceString + tmpArr[tmpArr.length - 1]) + "(" + mem + ")";
//			if (obj is InteractiveObject)
//				string += "enable " + (obj as InteractiveObject).mouseEnabled + ", ";
				if (displayObjectContainer.getChildAt(i) is DisplayObjectContainer)
				{
					//string += "children " + (obj as DisplayObjectContainer).mouseChildren + ", ";
					string += getAllChildrenOutputString((displayObjectContainer.getChildAt(i) as DisplayObjectContainer), (space+1));
				}
			}
			return string;
		}


		/**
		 * 取得某一displayObjectContainer下所有mouseEnabled子对象的字符输出
		 * @param displayObjectContainer
		 * @param space
		 */
		public static function getAllMouseEnabledChildrenOutputString(displayObjectContainer:DisplayObjectContainer, space:int=1):String
		{
			var spaceString:String = "\n*   ";

			var spaceNum:int = space;
			while (spaceNum > 0)
			{
				spaceString += "   ";
				spaceNum --;
			}

			var string:String = "";
			var i:int = 0;
			for (i = 0; i < displayObjectContainer.numChildren; i++)
			{
				if ((displayObjectContainer.getChildAt(i) is InteractiveObject) 
					&& (displayObjectContainer.getChildAt(i) as InteractiveObject).mouseEnabled)
				{
					var tmpArr:Array = String(displayObjectContainer.getChildAt(i)).split(".");
					string += (spaceString+tmpArr[tmpArr.length-1]);
				}
				if ((displayObjectContainer.getChildAt(i) is DisplayObjectContainer) 
					&& (displayObjectContainer.getChildAt(i) as DisplayObjectContainer).mouseChildren)
				{
					string += getAllMouseEnabledChildrenOutputString((displayObjectContainer.getChildAt(i) as DisplayObjectContainer), (space+1));
				}
			}
			return string;
		}


		/**
		 * 判断a是否为b的子对象(叠代到最root)
		 * @param child
		 * @param parent
		 */
		public static function checkParent(child:DisplayObject, parent:DisplayObjectContainer):Boolean
		{
			if (child.parent)
			{
				if (child.parent == parent)
				{
					return true;
				}
				else
				{
					return checkParent(child.parent, parent);
				}
			}
			return false;
		}


		public static function CheckParentAllEnabled(child:DisplayObject):Boolean
		{
			if (child.parent)
			{
				if (!(child.parent as DisplayObjectContainer).visible)
				{
					return false;
				}
				else if ((child.parent as DisplayObjectContainer).hasOwnProperty("enabled")
					&& child.parent["enabled"] == false)
				{
					return false;
				}
				else
				{
					return CheckParentAllEnabled(child.parent);
				}
			}
			return true;
		}


		/* public static function getVertices(x:Number, y:Number, w:Number, h:Number, rotation:Number):Vector.<Number>{
		   var vertices:Vector.<Number> = new Vector.<Number>();

		   var xx1:Number = w*Math.cos(-rotation)/2;
		   var yy1:Number = w*Math.sin(-rotation)/2;

		   var xx2:Number = h*Math.sin(-rotation);
		   var yy2:Number = h*Math.cos(-rotation);

		   var x1:Number = x-xx1;
		   var y1:Number = y+yy1;

		   var x2:Number = x+xx1;
		   var y2:Number = y-yy1;

		   var x3:Number = x+xx2+xx1;
		   var y3:Number = y+yy2-yy1;

		   var x4:Number = x+xx2-xx1;
		   var y4:Number = y+yy2+yy1;

		   vertices.push(x1,y1, x2,y2, x3,y3, x4,y4);
		   return vertices;
		   }
		   public static function get indices():Vector.<int>{
		   var indices:Vector.<int> = new Vector.<int>();
		   indices.push(0, 1, 3, 1, 2, 3);
		   return indices;
		   }
		   public static function get uvtData():Vector.<Number>{
		   var uvtData:Vector.<Number> = new Vector.<Number>();
		   uvtData.push(0,0,1, 1,0,1, 1,1,1, 0,1,1);
		   return uvtData;
		 } */


		/**
		 * 判断某一array中是否存在某一对象
		 * @param value
		 * @param arr
		 */
		public static function isValueInArray(value:Object, arr:Array):Boolean
		{
			var i:int;
			for (i = 0; i < arr.length; i++)
			{
				if (value == arr[i])
				{
					return true;
				}
			}
			return false;
		}


		public static function sameMatrixs(aMatrix:Matrix, bMatrix:Matrix):Boolean
		{
			if (aMatrix.a!=bMatrix.a)
			{
				return false;
			}
			if (aMatrix.b!=bMatrix.b)
			{
				return false;
			}
			if (aMatrix.c!=bMatrix.c)
			{
				return false;
			}
			if (aMatrix.d!=bMatrix.d)
			{
				return false;
			}
			if (aMatrix.tx!=bMatrix.tx)
			{
				return false;
			}
			if (aMatrix.ty!=bMatrix.ty)
			{
				return false;
			}
			return true;
		}

		public static function SameArray(arrayA:Array, arrayB:Array):Boolean
		{
			if (arrayA.length != arrayB.length)
				return false;

			for (var i:int = 0; i< arrayA.length; i++)
			{
				if (arrayA[i] != arrayB[i])
					return false;
			}

			return true;
		}


		public static function AppendText(text:String, args:Array):String
		{
			var sReturn:String = "";
			var arrSep:Array=SeparateIntoTags(text);
			var i:int;
			sReturn = arrSep[0];
			for (i = 1; i < arrSep.length / 2; i++)
			{
				try
				{
					var sLabel:String = arrSep[i * 2];
					var nReplace:int = arrSep[i * 2 - 1];
					var sArg:String = args[nReplace];
					sReturn += ((sArg == null ? "" : sArg) + sLabel);
				}
				catch (err:Error)
				{
					Logger.Throwing(Utils, err.message);
				}
			}
			return sReturn;
		}

		public static function GetChildByPath(root:DisplayObjectContainer, path:String):DisplayObject
		{
			var arr:Array = path.split(".");

			if (!root.hasOwnProperty(arr[0]))
				return null;

			var comp:DisplayObject = root[arr[0]] as DisplayObject;
			arr.shift();

			if (comp == null)
				return root;

			while (arr.length > 0)
			{
				if (comp.hasOwnProperty(arr[0]))
				{
					comp = comp[arr[0]] as DisplayObject;
					arr.shift();
				}
				else if (comp is DisplayObjectContainer
					&& (comp as DisplayObjectContainer).getChildByName(arr[0]))
				{
					comp = (comp as DisplayObjectContainer).getChildByName(arr[0]);
					arr.shift();
				}
				else if (comp is DisplayObjectContainer
					&& !isNaN(arr[0])
					&& (comp as DisplayObjectContainer).numChildren > int(arr[0]))
				{
					comp = (comp as DisplayObjectContainer).getChildAt(arr[0]);
					arr.shift();
				}
				else
				{
					Logger.Throwing(Utils, "Wrong Path [patch:" + path+ ", " + 
						"lastPath:" + arr + "]");
					return comp;
				}
			}

			return comp;
		}
		
		/**
		 * 搜索容器中指定类型的对象并以数组方式返回
		 */
		public static function searchChild(container:DisplayObjectContainer, searchType:Class):Array
		{
			
			var list_child:Array = [];
			
			var i:int = 0;
			var c:int = container.numChildren;
			while (i < c) 
			{
				
				var child:DisplayObject = container.getChildAt(i);
				
				if (child is searchType)
				{
					list_child.push(child);
				}
				else
					if (child is DisplayObjectContainer)
					{
						list_child = list_child.concat(searchChild(child as DisplayObjectContainer, searchType));
					}
				
				i++;
			}
			
			return list_child;
		}

	}
}