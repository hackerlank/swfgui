package com.swfgui.controls
{
	import com.swfgui.core.IFactory;
	import com.swfgui.core.UIComponent;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	public class ListItemRenderer extends UIComponent implements IFactory
	{
		protected const OVER_SKIN:String = "overSkin";
		protected const SELECTED_SKIN:String = "selectedSkin";
		
		private var _overSkin:DisplayObject;
		private var _selectedSkin:DisplayObject;
		
		public function ListItemRenderer(viewSource:Object=null)
		{
			super(viewSource);			
		}
		
		override public function dispose():void
		{
			if(hasDisposed)
			{
				return;
			}
			
			if(overSkin)
			{
				this.removeEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
				this.removeEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
			}
			
			super.dispose();
		}
		
		override protected function initialize():void
		{
			if(viewContainer)
			{
				_overSkin = viewContainer.getChildByName(OVER_SKIN);
				_selectedSkin = viewContainer.getChildByName(SELECTED_SKIN);
				
				if(!_overSkin)
				{
					_overSkin = _selectedSkin;
				}
				
				if(!_selectedSkin)
				{
					_selectedSkin = _overSkin;
				}
			}
			
			if(_overSkin)
			{
				this.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
				this.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
				_overSkin.visible = false;
			}
			if(_selectedSkin)
			{
				_selectedSkin.visible = false;
			}
			
			
			super.initialize();
			
		}
		
		override protected function updateSize():void
		{
			super.updateSize();
			if(overSkin)
			{
				overSkin.width += width - oldWidth;
				overSkin.height += height - oldHeight;
			}
			if(selectedSkin)
			{
				selectedSkin.width += width - oldWidth;
				selectedSkin.height += height - oldHeight;
			}
		}
		
		public function newInstance(viewSource:Object=null):*
		{
			if(!view)
			{
				return null;
			}
			
			return new ListItemRenderer(view);
		}
		
		protected function onMouseRollOver(event:MouseEvent):void
		{
			if(overSkin)
			{
				overSkin.visible = true;
			}
		}
		
		protected function onMouseRollOut(event:MouseEvent):void
		{
			if(overSkin)
			{
				overSkin.visible = false;
			}
			if(selectedSkin)
			{
				selectedSkin.visible = selected;
			}
		}
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			if(selectedSkin)
			{
				selectedSkin.visible = value;
			}
		}
		
		public function get overSkin():DisplayObject
		{
			return _overSkin;
		}

		public function get selectedSkin():DisplayObject
		{
			return _selectedSkin;
		}
	}
}