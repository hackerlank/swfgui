package com.swfgui.containers
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import com.swfgui.managers.PopUpManager;
	import com.swfgui.controls.Button;
	
	/**
	 * 弹出窗口
	 * @author llj
	 */
	public class PopUpWindow extends Canvas
	{
		private var _btnClose:Button;
		private var _btnOk:Button;
		
		public function PopUpWindow(view:DisplayObject)
		{
			super(viewSource);		
		}
		
		override protected function initialize():void
		{
			super.initialize();

			if(view["btnClose"])
			{
				_btnClose = new Button(view["btnClose"]);
				_btnClose.addEventListener(MouseEvent.CLICK, onClose);
			}
			
			if(view["btnOk"])
			{
				_btnOk = new Button(view["btnOk"]);
				_btnOk.addEventListener(MouseEvent.CLICK, onOk);
			}
		}
		
		override public function dispose():void
		{			
			if(hasDisposed)
			{
				return;
			}
			
			if(_btnClose)
			{
				_btnClose.removeEventListener(MouseEvent.CLICK, onClose);
			}
			
			if(_btnOk)
			{
				_btnOk.removeEventListener(MouseEvent.CLICK, onOk);
			}
			
			super.dispose();
		}
		
		/**
		 * 
		 * @param modal 是否模态
		 * @param position 新窗口相对于老窗口的位置，详见PopUpManager
		 */
		public function show(modal:Boolean = false, position:int=-1):void
		{
			PopUpManager.addPopUp(this, null, modal, position);
			PopUpManager.centerPopUp(this);
		}
		
		/**
		 * 
		 * @param hideDispose 关闭以后，是否销毁窗口，释放资源
		 */
		public function hide(hideDispose:Boolean = true):void
		{
			PopUpManager.removePopUp(this);
			if(hideDispose)
			{
				this.dispose();
			}
		}
		
		/**
		 * 关闭按钮鼠标单击事件处理器
		 * @param e
		 */
		protected function onClose(e:MouseEvent):void
		{
			hide();
		}
		
		/**
		 * 确定按钮鼠标单击事件处理器
		 * @param e
		 */
		protected function onOk(e:MouseEvent):void
		{
			hide();
		}

		public function get btnClose():Button
		{
			return _btnClose;
		}

		public function get btnOk():Button
		{
			return _btnOk;
		}

	}
}