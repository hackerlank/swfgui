package com.swfgui.controls
{
	import com.swfgui.core.Application;
	import com.swfgui.core.IListItemRenderer;
	import com.swfgui.core.UIComponent;
	import com.swfgui.events.ListEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class DropDownListBase extends UIComponent
	{
		protected static const DOWN_ARROW:String = "downArrow";
		protected static const LIST_RENDERER:String = "listRenderer";
		protected static const HSCROLL_BAR:String = "hscrollBar";
		protected static const VSCROLL_BAR:String = "vscrollBar";
		
		protected var downArrow:Button;
		protected var listRenderer:IListItemRenderer;
		private var listRendererView:DisplayObject;
		private var _listRendererClass:Class;
		private var _list:List;//宽度随renderer，高度随renderer数量，最大1/3应用程序
		private var _dataProvider:Object;
		private var _selectedData:Object;
		private var _selectedDataIndex:int = -1;
		private var _selectedItem:IListItemRenderer;
		private var _itemBindFunc:Function;
		private var _isDropDownOpen:Boolean;
		
		public function DropDownListBase(viewSource:Object=null)
		{
			super(viewSource);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			var downArrowView:DisplayObject = this.getChildByName(DOWN_ARROW);
			if(downArrowView)
			{
				downArrow = new Button(downArrowView);
				downArrow.right = viewContainer.width / viewContainer.scaleX - downArrow.x - downArrow.width;
			}
			
			listRendererView = this.getChildByName(LIST_RENDERER);
			if(listRendererView)
			{
				var spt:Sprite = new Sprite();
				spt.addChild(listRendererView);
				var hscrollBarView:DisplayObject = this.getChildByName(HSCROLL_BAR);
				if(hscrollBarView)
				{
					spt.addChild(hscrollBarView);
				}
				
				var vscrollBarView:DisplayObject = this.getChildByName(VSCROLL_BAR);
				if(vscrollBarView)
				{
					vscrollBarView.y = 0;
					spt.addChild(vscrollBarView);
				}
				
				_list = new List(spt);
				_list.includeInLayout = false;
				_list.width = this.width;
				_list.height = this.height;
			}
			
			if(downArrow)
			{
				downArrow.addEventListener(MouseEvent.CLICK, onMouseClick);
			}
			this.addEventListener(MouseEvent.CLICK, onListClick);
		}
		
		override protected function updateProperties():void
		{
			super.updateProperties();
			
			if(!_list)
			{
				return;
			}
			
			_list.itemBindFunc = _itemBindFunc;
			_list.setDataProvider(_dataProvider);
			if(_selectedData)
			{
				_list.selectedData = _selectedData;
			}
			if(_selectedDataIndex != -1)
			{
				_list.selectedDataIndex = _selectedDataIndex;
			}
			
			_list.addEventListener(ListEvent.CHANGE, onListChange);
			//_list.addEventListener(MouseEvent.CLICK, onListClick);
		}
		
		protected function onListClick(event:MouseEvent):void
		{
			event.stopPropagation();
		}
		
		/**
		 * 用户应重写此函数，以实现下拉选择绑定
		 * @param event
		 */
		protected function onListChange(event:ListEvent):void
		{
			this.dispatchEvent(event);
			closeDropDown();
		}
		
		protected function onMouseClick(event:MouseEvent):void
		{
			event.stopPropagation();
			if(_isDropDownOpen)
			{
				closeDropDown();
			}
			else
			{
				openDropDown();
			}
		}
		
		public function openDropDown():void
		{
			if(!parent || !_list)
			{
				return;
			}
			_isDropDownOpen = true;
			_list.maxHeight = Application.instance.width * 0.3;
			_list.height = list.contentHeight;
			_list.width = this.width;
			_list.validateSize();
			
			var listPt:Point = new Point();
			var thisPt:Point = Application.instance.componentToApp(this, new Point(0,0));
			
			if(thisPt.y + height + _list.height > Application.instance.height)
			{
				if(thisPt.y - _list.height < 0)
				{
					listPt.y = Math.round((Application.instance.height - _list.height) * 0.5);
				}
				else
				{
					listPt.y = thisPt.y - _list.height;
				}
			}
			else
			{
				listPt.y = thisPt.y + height;
			}
			
			if(thisPt.x + _list.width > Application.instance.width)
			{
				listPt.x = thisPt.x + this.width - _list.width;
			}
			else
			{
				listPt.x = thisPt.x;
			}
			
			//listPt = Application.instance.appToComponent(this, listPt);
			_list.x = listPt.x;
			_list.y = listPt.y;
			//this.addChild(_list);
			Application.instance.popUpLayer.addChild(_list);
			stage.addEventListener(MouseEvent.CLICK, onStageClick);
		}
	
		public function closeDropDown():void
		{
			if(!_list)
			{
				return;
			}
			_isDropDownOpen = false;
			Application.instance.stage.removeEventListener(MouseEvent.CLICK, onStageClick);
			safeRemoveChild(_list);
		}
		
		protected function onStageClick(event:MouseEvent):void
		{
			closeDropDown();
		}
		
		public function get listRendererClass():Class
		{
			return _listRendererClass;
		}

		public function set listRendererClass(value:Class):void
		{
			_listRendererClass = value;
			if(_list && _listRendererClass)
			{
				_list.itemRendererClass = _listRendererClass;
			}
		}

		public function get list():List
		{
			return _list;
		}

		public function set list(value:List):void
		{
			_list = value;
			invalidateProperties();
		}

		public function get dataProvider():Object
		{
			return _dataProvider;
		}

		public function set dataProvider(value:Object):void
		{
			_dataProvider = value;
			invalidateProperties();
		}

		public function get selectedData():Object
		{
			return _list ? _list.selectedData : null;
		}

		public function set selectedData(value:Object):void
		{
			_selectedData = value;
			_selectedDataIndex = -1;
			invalidateProperties();
		}

		public function get selectedDataIndex():int
		{
			return _selectedDataIndex;
		}

		public function set selectedDataIndex(value:int):void
		{
			_selectedDataIndex = value;
			_selectedData = null;
			invalidateProperties();
		}

		public function get selectedItem():IListItemRenderer
		{
			return _selectedItem;
		}

		public function get isDropDownOpen():Boolean
		{
			return _isDropDownOpen;
		}

		public function get itemBindFunc():Function
		{
			return _itemBindFunc;
		}

		public function set itemBindFunc(value:Function):void
		{
			_itemBindFunc = value;
			invalidateProperties();
		}
	}
}