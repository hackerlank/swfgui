package com.swfgui.controls
{
	import com.swfgui.core.UIComponent;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class PageList extends List
	{		
		private var _currentPage:int;
		private var _totalPage:int;
		private var _pageSize:int = -1;
		
		private var _btnPrePage:Button;
		private var _btnNextPage:Button;
		private var _btnFirstPage:Button;
		private var _btnLastPage:Button;
		private var _tfPage:TextField;
		
		public function PageList(viewSource:Object=null)
		{
			super(viewSource);
			UIComponent.traceValidate = false;
		}
		
		override protected function initialize():void
		{
			if (viewContainer.getChildByName("btnPrePage"))
			{
				btnPrePage = new Button(viewContainer.getChildByName("btnPrePage"));
			}
			if (viewContainer.getChildByName("btnNextPage"))
			{
				btnNextPage = new Button(viewContainer.getChildByName("btnNextPage"));
			}
			if (viewContainer.getChildByName("btnFirstPage"))
			{
				btnFirstPage = new Button(viewContainer.getChildByName("btnFirstPage"));
			}
			if (viewContainer.getChildByName("btnLastPage"))
			{
				btnLastPage = new Button(viewContainer.getChildByName("btnLastPage"));
			}
			if (viewContainer.getChildByName("tfPage"))
			{
				tfPage = viewContainer.getChildByName("tfPage") as TextField;
			}
			
			super.initialize();
			
			this.autoLayout = false;
		}
		
		override protected function initItems():void
		{
			super.initItems();
			if(_pageSize < 0)
			{
				_pageSize = items.length;
			}
		}
		
		private var _dataProvider:Object;
		
		override public function setDataProvider(data:Object, resetScroll:Boolean=true):void
		{
			super.setDataProvider(data, resetScroll);
			_dataProvider = super.dataProvider;
			if(resetScroll)
			{
				_currentPage = 0;
			}
			
			var a:Array = _dataProvider as Array;
			if(a.length > 0)
			{
				_totalPage = _pageSize > 0 ? Math.ceil(a.length / _pageSize) : 1;
			}
			else
			{
				_totalPage = 0;
			}
			
			gotoPage(_currentPage);
		}
		
		override public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		//--------------------------------------------------------------------------
		//
		//  page
		//
		//--------------------------------------------------------------------------
		
		public function nextPage():void
		{
			gotoPage(currentPage + 1);
		}
		
		public function prePage():void
		{
			gotoPage(currentPage - 1);
		}
		
		public function firstPage():void
		{
			gotoPage(0);
		}
		
		public function lastPage():void
		{
			gotoPage(totalPage - 1);
		}
		
		public function gotoPage(page:int):void
		{
			if (page >= totalPage)
			{
				page = totalPage - 1;
			}
			
			if (page < 0)
			{
				page = 0;
			}
			
			_currentPage = page;
			
			if(_dataProvider &&  _totalPage > 1)
			{
				var pageData:Array = (_dataProvider as Array).slice(_currentPage * _pageSize, 
					_currentPage * _pageSize + _pageSize);
				super.setDataProvider(pageData);
				invalidateScrollPostion();
				trace(_pageSize);
			}
			
			updatePageButton();
			updatePageLabel();
		}
		
		private function updatePageButton():void
		{
			if (_btnPrePage)
			{
				_btnPrePage.enabled = (currentPage > 0);
			}
			
			if (_btnNextPage)
			{
				_btnNextPage.enabled = (currentPage < totalPage - 1);
			}
			
			if (_btnFirstPage)
			{
				_btnFirstPage.enabled = (currentPage > 0);
			}
			
			if (_btnLastPage)
			{
				_btnLastPage.enabled = (currentPage < totalPage - 1);
			}
		}
		
		private function updatePageLabel():void
		{
			if (_tfPage)
			{
				if(totalPage > 0)
				{
					_tfPage.text = (currentPage + 1).toString() + "/" + totalPage.toString();
				}
				else
				{
					_tfPage.text = "0/0";
				}
			}
		}
		
		private function onBtnPageClick(e:MouseEvent):void
		{
			switch (e.currentTarget)
			{
				case btnPrePage:
					prePage();
					break;
				case btnNextPage:
					nextPage();
					break;
				case btnFirstPage:
					firstPage();
					break;
				case btnLastPage:
					lastPage();
					break;
			}
		}
		
		public function get btnPrePage():Button
		{
			return _btnPrePage;
		}
		
		public function set btnPrePage(value:Button):void
		{
			_btnPrePage = value;
			_btnPrePage.enabled = false;
			_btnPrePage.addEventListener(MouseEvent.CLICK, onBtnPageClick);
		}
		
		public function get btnNextPage():Button
		{
			return _btnNextPage;
		}
		
		public function set btnNextPage(value:Button):void
		{
			_btnNextPage = value;
			_btnNextPage.enabled = false;
			_btnNextPage.addEventListener(MouseEvent.CLICK, onBtnPageClick);
		}
		
		public function get btnFirstPage():Button
		{
			return _btnFirstPage;
		}
		
		public function set btnFirstPage(value:Button):void
		{
			_btnFirstPage = value;
			_btnFirstPage.enabled = false;
			_btnFirstPage.addEventListener(MouseEvent.CLICK, onBtnPageClick);
		}
		
		public function get btnLastPage():Button
		{
			return _btnLastPage;
		}
		
		public function set btnLastPage(value:Button):void
		{
			_btnLastPage = value;
			_btnLastPage.enabled = false;
			_btnLastPage.addEventListener(MouseEvent.CLICK, onBtnPageClick);
		}
		
		/**
		 * 页码标签
		 */
		public function get tfPage():TextField
		{
			return _tfPage;
		}
		
		public function set tfPage(value:TextField):void
		{
			_tfPage = value;
		}
		
		public function get currentPage():int
		{
			return _currentPage;
		}
		
		public function get totalPage():int
		{
			return _totalPage;
		}
		
		public function get pageSize():int
		{
			return _pageSize;
		}
		
		public function set pageSize(value:int):void
		{
			_pageSize = value;
		}
		
	}
}