package com.swfgui.controls
{
	import com.swfgui.containers.Canvas;
	import com.swfgui.core.IListItemRenderer;
	import com.swfgui.events.ListEvent;
	import com.swfgui.utils.ArrayUtil;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	[Event(name="change", type="com.swfgui.events.ListEvent")]

	/**
	 * 常用的属性有：itemRendererClass、direction、maxRows、maxColumns等。
	 * 容器被划分成横竖方向很多网格(tile)，每个tile上可以放置一个item，tile.width = item.width + hgap,
	 * tile.height = item.height + vgap;
	 *
	 * @author llj
	 */
	public class List extends Canvas
	{
		/**
		 * 纵向List：列数最大等于maxColumns，行数随数据量变化
		 * @default
		 */
		public static const DIR_VERTICAL:String = "vertical";
		/**
		 * 横向List：行数最大等于maxRows，列数随数据量变化
		 * @default
		 */
		public static const DIR_HORIZONTAL:String = "horizontal";

		public static const ALIGN_TOP:String = "top";
		public static const ALIGN_MIDDLE:String = "middle";
		public static const ALIGN_BOTTOM:String = "bottom";
		public static const ALIGN_LEFT:String = "left";
		public static const ALIGN_CENTER:String = "center";
		public static const ALIGN_RIGHT:String = "right";

		protected static const UP:String = "up";
		protected static const DOWN:String = "down";
		protected static const LEFT:String = "left";
		protected static const RIGHT:String = "right";

		private var _direction:String = "vertical";
		private var _dataProvider:Object;
		private var _itemRendererClass:Class;

		private var _itemBindFunc:Function;
		private var _showNullItem:Boolean;
		private var baseItemView:DisplayObject;
		private var itemWidth:Number;
		private var itemHeight:Number;

		/**
		 * true:自动item，即根据itemRendererClass自动创建所需要的item，
		 * false：手动item，view中预先放置了固定数量的item
		 */
		protected var autoItem:Boolean;
		private var initItemsFlag:Boolean;
		public var autoSize:Boolean;

		private var _items:Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>();
		protected var curItems:Dictionary = new Dictionary(true);
		protected var itemPool:Array = [];

		private var _selectable:Boolean = true;
		private var _allowMultipleSelection:Boolean = false;
		private var _selectedDatas:Array = [];
		private var _selectedDataIndices:Array = [];
		private var _selectedItems:Array = [];
		/**
		 * selectedData或selectedDatas改变了，则为1；
		 * selectedDataIndex或selectedDataIndices改变了，则为2
		 * 都没改变，则为0
		 */
		private var selectedChangeType:int;
		private var oldSelectedDataIndex:int = -1;

		private var _rowCount:int
		private var _columnCount:int;
		private var _maxRows:int = 1;
		private var _maxColumns:int = 1;
		/**
		 * 当前显示的数据在dataprovider中的开始位置
		 * @default
		 */
		private var dataPosition:int;

		private var _horizontalAlign:String;
		private var _verticalAlign:String;

		private var _horizontalGap:int = 0;
		private var _verticalGap:int = 0;
		/**
		 * 包括horizontalGap和verticalGap的网格大小
		 * @default
		 */
		private var tileSize:Rectangle = new Rectangle();
		/**
		 * 当前的可视范围，网格坐标系统
		 * @default
		 */
		protected var curRect:Rectangle = new Rectangle();

		public function List(viewSource:Object=null)
		{
			super(viewSource);
		}

		override public function dispose():void
		{
			if (hasDisposed)
			{
				return;
			}

			for each (var item:IListItemRenderer in itemPool)
			{
				item.dispose();
			}

			super.dispose();
		}

		override protected function initialize():void
		{
			super.initialize();

			this.autoLayout = false;
		}

		//--------------------------------------------------------------------------
		//
		//  init list item
		//
		//--------------------------------------------------------------------------

		override protected function updateProperties():void
		{
			super.updateProperties();
			
			//此判断很重要
			if(!initItemsFlag)
			{
				return;
			}
			
			initItems();

			var len:int = getDataProviderLength();
			if (direction == DIR_VERTICAL)
			{
				_rowCount = Math.ceil(len / maxColumns);
				_columnCount = _rowCount > 1 ? maxColumns : len;
				
				if(autoSize)
				{
					this.height = contentHeight;
				}
			}
			else
			{
				_columnCount = Math.ceil(len / maxRows);
				_rowCount = _columnCount > 1 ? maxRows : len;
				
				if(autoSize)
				{
					this.width = contentWidth;
				}
			}

			tileSize.width = itemWidth + horizontalGap;
			tileSize.height = itemHeight + verticalGap;
			
			removeitems(curRect);
			curRect.width = curRect.height = 0;
		}

		protected function initItems():void
		{
			if (!initItemsFlag || !itemRendererClass)
			{
				return;
			}

			initItemsFlag = false;
			var item:IListItemRenderer;
			var itemView:DisplayObject;
			var i:int = 0;

			//重新初始化的，先清理以前的
			if (autoItem && _items.length > 0)
			{
				for each (item in getAllChild())
				{
					if (item)
					{
						this.removeChild(DisplayObject(item));
						item.dispose();
					}
				}

				for each (item in itemPool)
				{
					item.dispose();
				}

				_items.length = 0;
				itemPool.length = 0;
				curItems = new Dictionary(true);
				baseItemView = null;
			}

			//先检查命名如item0 item1...的元件
			while (true)
			{
				itemView = getChildByName("item" + (i++).toString());
				if (!itemView)
				{
					break;
				}
				createItemByView(itemView);
			}

			if (_items.length > 1)
			{
				autoItem = false;
			}
			else if (_items.length == 1)
			{
				autoItem = true;
			}
			else
			{
				//如果没有命名如item0 item1...的元件，再检查其它元件
				if (numChildren > 1)
				{
					autoItem = false;
					var children:Array = this.getAllChild();
					var n:int = children.length;
					children.sort(onSort); //y优先排序
					for (i = 0; i < n; i++)
					{
						createItemByView(children[i]);
					}
				}
				else
				{
					autoItem = true;
					if (numChildren == 1)
					{
						//只有一个元件，则使用其来创建item
						createItemByView(getChildAt(0));
					}
					else
					{
						//一个元件都没有，则使用itemRendererClass来创建item
						createItemByView();
					}
				}
			}

			if (autoItem)
			{
				for each (item in _items)
				{
					if (item.parent)
					{
						item.parent.removeChild(DisplayObject(item));
					}
					itemPool.push(item);
				}
			}

			itemWidth = _items[0].width;
			itemHeight = _items[0].height;
		}

		private function createItemByView(itemView:DisplayObject=null):IListItemRenderer
		{
			var item:IListItemRenderer = itemView is IListItemRenderer ? 
				IListItemRenderer(itemView) :  new itemRendererClass(itemView);

			if (!baseItemView)
			{
				baseItemView = item.view;
			}
			items.push(item);
			item.addEventListener(MouseEvent.CLICK, onItemMouseClick, false, 0, true);

			return item;
		}

		/**
		 * y优先深度排序
		 * @param a
		 * @param b
		 * @return
		 */
		private function onSort(a:DisplayObject, b:DisplayObject):int
		{
			if ((a.x >= b.x && a.y >= b.y) || a.y > b.y + b.height * 0.5)
			{
				return 1;
			}

			return -1;
		}

		//--------------------------------------------------------------------------
		//
		//  select
		//
		//--------------------------------------------------------------------------

		protected function invalidateSelected():void
		{
			this.callLater(updateSelected);
		}

		protected function updateSelected():void
		{
			if (!_dataProvider)// || !initItemsFlag)
			{
				return;
			}

			var item:IListItemRenderer;
			var child:DisplayObject;
			if (!selectable)
			{
				for each (child in getAllChild())
				{
					if (child is IListItemRenderer)
					{
						IListItemRenderer(child).selected = false;
					}
				}

				_selectedItems.length = 0;
				_selectedDatas.length = 0;
				_selectedDataIndices.length = 0;
				oldSelectedDataIndex = -1;

				return;
			}
			
			var n:int;
			var i:int;
			var index:int;
			var data:Object;
			
			if(selectedChangeType == 1)
			{
				n = _selectedDatas.length;
				for(i = 0; i < n; i++)
				{
					index = getDataIndex(_selectedDatas[i]);
					if(index < 0)
					{
						//不是dataProvider中的数据，则删除
						_selectedDatas.splice(i, 1);
						i--;
						n--;
					}
					else
					{
						_selectedDataIndices[i] = index;
					}
				}
			}
			else if(selectedChangeType == 2)
			{
				n = _selectedDataIndices.length;
				for(i = 0; i < n; i++)
				{
					data = _dataProvider[_selectedDataIndices[i]];
					if(data == null)
					{
						//不是dataProvider中的数据，则删除
						_selectedDataIndices.splice(i, 1);
						i--;
						n--;
					}
					else
					{
						_selectedDatas[i] = data;
					}
				}
			}
			selectedChangeType = 0;

			i = 0;
			for each (child in getAllChild())
			{
				if (!(child is IListItemRenderer))
				{
					continue;
				}
				item = IListItemRenderer(child);
				item.selected = false;

				for each (index in selectedDataIndices)
				{
					if (item.dataIndex == index)
					{
						item.selected = true;
						_selectedItems[i++] = item;
					}
				}
			}
			
			if(selectedDataIndex != oldSelectedDataIndex && hasEventListener(ListEvent.CHANGE))
			{
				dispatchEvent(new ListEvent(ListEvent.CHANGE, selectedDataIndex, 
					oldSelectedDataIndex, selectedItem, getItemByDataIndex(selectedDataIndex)));
				oldSelectedDataIndex = selectedDataIndex;
			}
		}
		
		private function getItemByDataIndex(index:int):IListItemRenderer
		{
			var item:IListItemRenderer;
			for each(var child:DisplayObject in getAllChild())
			{
				item = child as IListItemRenderer;
				if(item && item.dataIndex == index)
				{
					return item;
				}
			}
			
			return null;
		}

		protected function onItemMouseClick(event:MouseEvent):void
		{
			var index:int = IListItemRenderer(event.currentTarget).dataIndex;
			if(!allowMultipleSelection)
			{
				selectedDataIndices.length = 0;
				selectedDataIndex = index;
				return;
			}
			
			if(ArrayUtil.hasItem(index, selectedDataIndices))
			{
				ArrayUtil.deleteItem(index, selectedDataIndices);
			}
			else
			{
				selectedDataIndices.push(index);
			}
			invalidateSelected();
		}

		//--------------------------------------------------------------------------
		//
		//  scroll
		//
		//--------------------------------------------------------------------------

		override protected function updateScrollPostion():void
		{
			if (!autoItem)
			{
				if (direction == DIR_VERTICAL)
				{
					dataPosition = verticalScrollPosition;
					_scrollRect.x = horizontalScrollPosition;
				}
				else
				{
					dataPosition = horizontalScrollPosition;
					_scrollRect.y = verticalScrollPosition;
				}
				this.scrollRect = _scrollRect;
				updateScrollBarPosition();
				refresh();
				updateSelected();
				return;
			}

			super.updateScrollPostion();

			//获得屏幕内应当显示的格子，网格坐标系统
			var screen:Rectangle = rectToTile(new Rectangle(_scrollRect.x, 
				_scrollRect.y, viewportWidth, viewportHeight));

			if (!screen)
				return;

			//过滤显示范围	
			var cRect:Rectangle = new Rectangle(screen.x, screen.y);
			if (direction == DIR_VERTICAL)
			{
				cRect.width = maxColumns;
				cRect.height = Math.ceil(viewportHeight / tileSize.height) + 1;
			}
			else
			{
				cRect.width = Math.ceil(viewportWidth / tileSize.width) + 1;
				cRect.height = maxRows;
			}

			screen = screen.intersection(cRect);

			//增删格子
			if (curRect.x != screen.x) //左
			{
				if (curRect.x > screen.x)
					additems(new Rectangle(screen.x,curRect.y,Math.min(screen.width,curRect.x - screen.x),curRect.height),LEFT)
				else
					removeitems(new Rectangle(curRect.x,curRect.y,Math.min(curRect.width,screen.x - curRect.x),curRect.height));

				curRect.width += curRect.x - screen.x;
				curRect.width = Math.max(curRect.width,0);
				curRect.x = screen.x;
			}
			if (screen.right != curRect.right) //右
			{
				if (screen.right > curRect.right)
					additems(new Rectangle(curRect.right,curRect.y,Math.min(screen.width,screen.right - curRect.right),curRect.height),RIGHT)
				else
				{
					//增加元素时，如果跨屏较多，在向回卷的时候体积将会很大，删除时很费时间，因此要在下面进行补偿处理
					//形成这个问题是原因是向回跨屏时是先增加再删除，会同时存在两块分离的区域，暂时先这样解决
					//实际上，就算不做任何处理，这种拖慢也要等到百万级的数据集才能体现出来
					//当屏幕向回卷有大跨度时，只删除最下面的一部分，暂时先这样特殊处理一下
					if (curRect.width > 5000)
						removeitems(new Rectangle(screen.x + curRect.width - screen.width - 1,curRect.y,screen.width + 1,curRect.height));
					else
						removeitems(new Rectangle(screen.right,curRect.y,Math.min(curRect.width,curRect.right - screen.right),curRect.height))
				}
				curRect.width = screen.width;
			}
			if (curRect.y != screen.y) //上
			{
				if (curRect.y > screen.y)
					additems(new Rectangle(curRect.x,screen.y,curRect.width,Math.min(screen.height,curRect.y - screen.y)),UP);
				else
					removeitems(new Rectangle(curRect.x,curRect.y,curRect.width,Math.min(curRect.height,screen.y - curRect.y)));

				curRect.height += curRect.y - screen.y;
				curRect.height = Math.max(curRect.height,0);
				curRect.y = screen.y;
			}
			if (screen.bottom != curRect.bottom) //下
			{
				if (screen.bottom > curRect.bottom)
					additems(new Rectangle(curRect.x,curRect.bottom,curRect.width,Math.min(screen.height,screen.bottom - curRect.bottom)),DOWN);
				else
				{
					if (curRect.height > 5000)
						removeitems(new Rectangle(curRect.x,screen.y + curRect.height - screen.height - 1,curRect.width,screen.height + 1));
					else
						removeitems(new Rectangle(curRect.x,screen.bottom,curRect.width,Math.min(curRect.height,curRect.bottom - screen.bottom)));
				}
				curRect.height = screen.height;
			}
			
			updateSelected();
			
			_items.length = 0;
			for (var i:int = curRect.x; i < curRect.width; i++)
			{
				for (var j:int = curRect.y; j < curRect.height; j++)
				{
					_items.push(curItems[i+":" +j]);
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  local坐标和tile坐标的转换
		//
		//--------------------------------------------------------------------------

		/**
		 * 本地坐标点转换成网格坐标点
		 * @param pt
		 * @return
		 */
		protected function pointToTile(pt:Point):Point
		{
			return new Point(int(pt.x / tileSize.width), int(pt.y / tileSize.height));
		}

		/**
		 * 本地坐标矩形转换成网格坐标矩形
		 * @param rect
		 * @return
		 */
		protected function rectToTile(rect:Rectangle):Rectangle
		{
			if (!rect)
				return null;

			var tileRect:Rectangle = new Rectangle();
			tileRect.x = Math.floor(rect.x / tileSize.width);
			tileRect.y = Math.floor(rect.y / tileSize.height);
			tileRect.width = Math.ceil(rect.right / tileSize.width) - tileRect.x;
			tileRect.height = Math.ceil(rect.bottom / tileSize.height) - tileRect.y;

			return tileRect;
		}

		/**
		 * 根据本地坐标得到item
		 * @param x
		 * @param y
		 * @return
		 */
		protected function getItemByLocalPoint(x:Number, y:Number):IListItemRenderer
		{
			return null;
		}

		/**
		 * 根据网格坐标得到item
		 * @param x
		 * @param y
		 * @return
		 */
		protected function getItemByTilePoint(x:int, y:int):IListItemRenderer
		{
			return null;
		}

		//--------------------------------------------------------------------------
		//
		//  create add remove item
		//
		//--------------------------------------------------------------------------

		private function createItem():IListItemRenderer
		{
			var item:IListItemRenderer = itemPool.pop() as IListItemRenderer;
			//如果没有赋值view不能创建item，则复制初始的item的view
//			if (!item)
//			{
//				item = itemRendererClass.newInstance();
//			}
			if (!item)
			{
				item = new itemRendererClass(new baseItemView["constructor"]);
				item.addEventListener(MouseEvent.CLICK, onItemMouseClick, false, 0, true);
			}

			return item;
		}

		/**
		 * 创建Item的方法，可以重载此方法来添加新功能
		 * @param i	横坐标序号
		 * @param j	纵坐标序号
		 * @param direct 方向
		 */
		protected function addItem(i:int,j:int,direct:String):IListItemRenderer
		{
			var key:String = i.toString() + ":" + j.toString();

			if (curItems[key])
			{
				return curItems[key];
			}

			var item:IListItemRenderer = createItem();

			setItemPosition(item as DisplayObject, i, j);
			curItems[key] = item;

			if (direct == LEFT || direct == UP)
			{
				addChildAt(item as DisplayObject,0);
			}
			else
			{
				addChild(item as DisplayObject);
			}

			refreshIndex(i, j);

			return item;
		}

		/**
		 * 设置显示物体的坐标
		 */
		protected function setItemPosition(item:DisplayObject,i:int,j:int):void
		{
			item.x = i * tileSize.width;
			item.y = j * tileSize.height;
		}

		/**
		 * 删除物品
		 * @param i
		 * @param j
		 * @return
		 */
		protected function removeItem(i:int,j:int):DisplayObject
		{
			var item:DisplayObject = curItems[i + ":" +j];
			if (item)
			{
				delete curItems[i + ":" +j];
				removeChild(item);
				itemPool.push(item);
			}
			return item;
		}

		/**
		 * 增加一组格子
		 * @param rect	格子区域
		 * @param direct 方向
		 */
		protected function additems(rect:Rectangle,direct:String):void
		{
			var si:int = rect.x;
			var sj:int = rect.y;
			var ei:int = rect.right;
			var ej:int = rect.bottom;
			var i:int;
			var j:int;
			switch (direct)
			{
				case LEFT:
					for (i = ei - 1; i >= si; i--)
						for (j = ej - 1; j >= sj; j--)
							addItem(i,j,direct);
					break;
				case RIGHT:
					for (i = si; i < ei; i++)
						for (j = sj; j < ej; j++)
							addItem(i,j,direct);
					break;
				case UP:
					for (j = ej - 1; j >= sj; j--)
						for (i = ei - 1; i >= si; i--)
							addItem(i,j,direct);
					break;
				case DOWN:
					for (j = sj; j < ej; j++)
						for (i = si; i < ei; i++)
							addItem(i,j,direct);
					break;
			}
		}

		/**
		 * 删除一组物品
		 * @param rect
		 */
		protected function removeitems(rect:Rectangle):void
		{
			var si:int = rect.x;
			var sj:int = rect.y;
			var ei:int = rect.right;
			var ej:int = rect.bottom;
			for (var i:int = si; i < ei; i++)
				for (var j:int = sj; j < ej; j++)
					removeItem(i,j);
		}

		//--------------------------------------------------------------------------
		//
		//  refresh
		//
		//--------------------------------------------------------------------------

		/**
		 * 刷新数据显示
		 */
		public function refresh():void
		{
			if (!_dataProvider)
			{
				return;
			}
			
			var i:int;
			var j:int;
			var len:int;

			if (autoItem)
			{
				for (i = curRect.x; i < curRect.width; i++)
				{
					for (j = curRect.y; j < curRect.height; j++)
					{
						refreshIndex(i, j);
					}
				}
			}
			else
			{
				len = items.length;
				for (i = 0; i < len; i++)
				{
					refreshItem(items[i], _dataProvider[dataPosition + i], dataPosition + i);
				}
			}
		}

		protected function refreshIndex(i:int, j:int):void
		{
			if(!_dataProvider)
			{
				return;
			}
			if (direction == DIR_VERTICAL)
			{
				refreshItem(curItems[i + ":" + j], 
					_dataProvider[j * columnCount + i], j * columnCount + i);
			}
			else
			{
				refreshItem(curItems[i + ":" + j], 
					_dataProvider[i * rowCount + j], i * rowCount + j);

			}
		}

		protected function refreshItem(item:IListItemRenderer, data:Object, dataIndex:int):void
		{
			if (!item)
			{
				return;
			}

			item.data = data;
			item.dataIndex = dataIndex;

			if (data != null)
			{
				item.visible = true;
				if(itemBindFunc != null)
				{
					itemBindFunc(item);
				}
			}
			else
			{
				item.visible = showNullItem;
				if (showNullItem && itemBindFunc != null)
				{
					itemBindFunc(item);
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  properties
		//
		//--------------------------------------------------------------------------

		override public function get contentWidth():Number
		{
			return autoItem ? columnCount * tileSize.width - verticalGap : 
				Math.ceil(getDataProviderLength() /*/ items.length*/);
		}

		override public function get contentHeight():Number
		{
			return autoItem ? rowCount * tileSize.height - horizontalGap : 
				Math.ceil(getDataProviderLength() /*/ items.length*/);
		}

		override public function get viewportWidth():Number
		{
			return autoItem ? super.viewportWidth : (direction == DIR_HORIZONTAL ? items.length : 1);
		}

		override public function get viewportHeight():Number
		{
			return autoItem ? super.viewportHeight : (direction == DIR_VERTICAL ? items.length : 1);
		}

		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		public function set dataProvider(value:Object):void
		{
			return setDataProvider(value);
		}

		/**
		 * 设置数据
		 * @param data 可接受的类型有Array、Vector、XMLList
		 * @param resetScroll 是否重置滚动位置
		 */
		public function setDataProvider(data:Object, resetScroll:Boolean=true):void
		{
			if (!data)
			{
				data = [];
			}
			this.data = data;
			_dataProvider = data;

			if (resetScroll)
			{
				dataPosition = 0;
				horizontalScrollPosition = 0;
				verticalScrollPosition = 0;
			}

			invalidateProperties();
			invalidateDisplayList();
			invalidateScrollPostion();
		}

		private function getDataProviderLength():int
		{
			if (_dataProvider is Array || _dataProvider is Vector)
			{
				return _dataProvider["length"];
			}
			else if (_dataProvider is XMLList)
			{
				return _dataProvider["length"]();
			}

			return 0;
		}
		
		private function getDataIndex(data:Object):int
		{
			if(!_dataProvider)
			{
				return -1;
			}
			
			var n:int = getDataProviderLength();
			for(var i:int = 0; i < n; i++)
			{
				if(_dataProvider[i] == data)
				{
					return i;
				}
			}
			
			return -1;
		}

		public function get rowCount():int
		{
			return _rowCount;
		}

		public function get columnCount():int
		{
			return _columnCount;
		}

		public function get direction():String
		{
			return _direction;
		}

		public function set direction(value:String):void
		{
			if (_direction != value)
			{
				_direction = value;
				dataPosition = 0;
				horizontalScrollPosition = 0;
				verticalScrollPosition = 0;
				invalidateProperties();
				invalidateDisplayList();
				invalidateScrollPostion();
			}
		}

		public function get maxColumns():int
		{
			return _maxColumns;
		}

		public function set maxColumns(value:int):void
		{
			if (_maxColumns != value)
			{
				_maxColumns = value;
				if (direction == DIR_VERTICAL)
				{
					invalidateProperties();
					invalidateDisplayList();
					invalidateScrollPostion();
				}
			}
		}

		public function get maxRows():int
		{
			return _maxRows;
		}

		public function set maxRows(value:int):void
		{
			if (_maxRows != value)
			{
				_maxRows = value;
				if (direction == DIR_HORIZONTAL)
				{
					invalidateProperties();
					invalidateDisplayList();
					invalidateScrollPostion();
				}
			}
		}

		public function get horizontalGap():int
		{
			return _horizontalGap;
		}

		public function set horizontalGap(value:int):void
		{
			if (_horizontalGap != value)
			{
				_horizontalGap = value;
				invalidateProperties();
				invalidateDisplayList();
				invalidateScrollPostion();
			}
		}

		public function get verticalGap():int
		{
			return _verticalGap;
		}

		public function set verticalGap(value:int):void
		{
			if (_verticalGap != value)
			{
				_verticalGap = value;
				invalidateProperties();
				invalidateDisplayList();
				invalidateScrollPostion();
			}
		}

		public function get items():Vector.<IListItemRenderer>
		{
			return _items;
		}

		/**
		 * 必须有一个类型为IListItemRenderer的参数，IListItemRenderer.data已经被赋值，
		 * 用户可以根据data来绑定IListItemRenderer的内容
		 * @return 
		 */
		public function get itemBindFunc():Function
		{
			return _itemBindFunc;
		}

		public function set itemBindFunc(value:Function):void
		{
			_itemBindFunc = value;
		}

		/**
		 * 是否显示没有绑定数据的项，默认false
		 * @default
		 */
		public function get showNullItem():Boolean
		{
			return _showNullItem;
		}

		/**
		 * @private
		 */
		public function set showNullItem(value:Boolean):void
		{
			if (_showNullItem != value)
			{
				_showNullItem = value;
				invalidateDisplayList();
				invalidateScrollPostion();
			}
		}

		public function get itemRendererClass():Class
		{
			return _itemRendererClass;
		}

		public function set itemRendererClass(value:Class):void
		{
			if (_itemRendererClass != value)
			{
				_itemRendererClass = value;
				initItemsFlag = true;
				invalidateProperties();
				invalidateDisplayList();
				invalidateScrollPostion();
			}
		}

		public function get horizontalAlign():String
		{
			return _horizontalAlign;
		}

		public function set horizontalAlign(value:String):void
		{
			_horizontalAlign = value;
		}

		public function get verticalAlign():String
		{
			return _verticalAlign;
		}

		public function set verticalAlign(value:String):void
		{
			_verticalAlign = value;
		}

		public function get selectable():Boolean
		{
			return _selectable;
		}

		public function set selectable(value:Boolean):void
		{
			_selectable = value;
			invalidateSelected();
		}

		public function get selectedData():Object
		{
			return _selectedDatas.length > 0 ? 
				_selectedDatas[_selectedDatas.length - 1] : null;
		}

		public function set selectedData(value:Object):void
		{
			//为什么不根据value直接算出index，因为这时候dataProvider可能还没有值
			_selectedDatas[_selectedDatas.length > 0 ? 
				_selectedDatas.length - 1 : 0] = value;
			selectedChangeType = 1;
			invalidateSelected();
		}

		public function get selectedDataIndex():int
		{
			return _selectedDataIndices.length > 0 ? 
				_selectedDataIndices[_selectedDataIndices.length - 1] : -1;
		}

		public function set selectedDataIndex(value:int):void
		{
			_selectedDataIndices[_selectedDatas.length > 0 ? 
				_selectedDatas.length - 1 : 0] = value;
			selectedChangeType = 2;
			invalidateSelected();
		}

		public function get selectedItem():IListItemRenderer
		{
			return _selectedItems.length > 0 ? 
				_selectedItems[_selectedItems.length - 1] : null;
		}

		public function get allowMultipleSelection():Boolean
		{
			return _allowMultipleSelection;
		}

		public function set allowMultipleSelection(value:Boolean):void
		{
			_allowMultipleSelection = value;
		}

		public function get selectedDatas():Array
		{
			return _selectedDatas;
		}

		public function set selectedDatas(value:Array):void
		{
			//为什么不根据value直接算出index，因为这时候dataProvider可能还没有值
			_selectedDatas = value;
			selectedChangeType = 1;
			invalidateSelected();
		}

		public function get selectedDataIndices():Array
		{
			return _selectedDataIndices;
		}

		public function set selectedDataIndices(value:Array):void
		{
			_selectedDataIndices = value;
			selectedChangeType = 2;
			invalidateSelected();
		}

		public function get selectedItems():Array
		{
			return _selectedItems;
		}
	}
}