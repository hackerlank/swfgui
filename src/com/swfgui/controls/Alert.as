package com.swfgui.controls
{
	/**
	 * Alert警告窗口
	 * @author dd
	 */
	
	import com.swfgui.containers.Canvas;
	import com.swfgui.events.CloseEvent;
	import com.swfgui.managers.PopUpManager;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class Alert extends Canvas
	{
		/**
		 * 没有按钮
		 */
		public static const FLAGS_NONE:int = 0;
		/**
		 * 一个按钮
		 */
		public static const FLAGS_OK:int = 1;
		/**
		 * 两个按钮
		 */
		public static const FLAGS_YESNO:int = 2;
				
		public static const OK:int = 1;
		public static const YES:int = 2;
		public static const NO:int = 3;
		
		private static var _okLabel:String = "确定";
		private static var _yesLabel:String = "是";
		private static var _noLabel:String = "否";
		
		public var text:String;
		public var buttonFlags:uint;
		
		public var btnYes:Button;
		public var btnNO:Button;
		public var btnOK:Button;
		
		public var title:Label;
		public var content:Label;
		protected var onClose:Function;
		protected var autoClose:uint;
		protected var isClosed:Boolean;
		
		private var timeId:uint;
		
		public function Alert(viewSource:Object=null)
		{
			super(viewSource);
		}
		
		override public function get className():String
		{
			return "Alert";
		}
		
		/**
		 * 组件的初始化代码
		 */
		override protected function initialize():void
		{
			btnYes = new Button(viewContainer.getChildByName("btnYes"));
			btnYes.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			btnNO = new Button(viewContainer.getChildByName("btnNO"));
			btnNO.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			btnOK = new Button(viewContainer.getChildByName("btnOK"));
			btnOK.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			title = new Label(viewContainer.getChildByName("title"));
			content = new Label(viewContainer.getChildByName("content"));
			
			super.initialize();
		}
		
		override public function dispose():void
		{			
			if(hasDisposed)
			{
				return;
			}
			
			btnYes.removeEventListener(MouseEvent.CLICK, onMouseClick);			
			btnNO.removeEventListener(MouseEvent.CLICK, onMouseClick);			
			btnOK.removeEventListener(MouseEvent.CLICK, onMouseClick);
			if(onClose != null)
			{
				this.removeEventListener(CloseEvent.CLOSE, onClose);
				onClose = null;
			}
			
			super.dispose();
		}
			
		protected function onMouseClick(event:MouseEvent):void
		{
			if(event.currentTarget == btnOK)
			{
				closeAlert(OK);
			}
			else if(event.currentTarget == btnYes)
			{
				closeAlert(YES);
			}
			else if(event.currentTarget == btnNO)
			{
				closeAlert(NO);
			}
			else
			{
				closeAlert();
			}
		}
		
		/**
		 * @param message 提示文字内容
		 * @param title 标题
		 * @param callback 回调函数
		 * @param flag alert类型，0=确定框 or 1=是否框
		 * @param modal 是否模态
		 * @param autoclose 自动关闭，0表示不自动关闭，单位为秒
		 */
		public static function show(text:String , title:String = "" , autoClose:uint = 0, flags:uint = 1, 
									onClose:Function = null, parent:Sprite = null, modal:Boolean = true):Alert
		{			
			var alert:Alert = new Alert();
			alert.showAlert(text, title, autoClose, flags, onClose, parent, modal);
			return alert;
		}
		
		public function showAlert(text:String , title:String = "" , autoClose:uint = 0, flags:uint = 1, 
								  onClose:Function = null, parent:Sprite = null, modal:Boolean = true):void
		{
			this.title.htmlText = title;
			this.content.htmlText = text;
			this.onClose = onClose;
			this.autoClose = autoClose;
			
			if(onClose != null)
			{
				this.addEventListener(CloseEvent.CLOSE, onClose);
			}
			
			this.text = text;
			this.buttonFlags = flags;
			
			btnOK.label = okLabel;
			btnYes.label = yesLabel;
			btnNO.label = noLabel;
			
			if(flags == FLAGS_NONE)
			{
				btnOK.visible = false;
				btnYes.visible = false;
				btnNO.visible = false;
			}
			else if(flags == FLAGS_YESNO)
			{
				btnOK.visible = false;
				btnYes.visible = true;
				btnNO.visible = true;
			}
			else
			{
				btnOK.visible = true;
				btnYes.visible = false;
				btnNO.visible = false;
			}
			
			PopUpManager.addPopUpEx(this, parent, modal);
			PopUpManager.centerPopUp(this);
			
			if(autoClose > 0)
			{
				timeId = setTimeout(closeAlert, autoClose * 1000, YES);
			}
		}
		
		public function closeAlert(closeDetail:int = 0):void
		{
			clearTimeout(timeId);
			PopUpManager.removePopUpEx(this);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, closeDetail));			
			dispose();
		}
		
		public static function get okLabel():String
		{
			return _okLabel;
		}

		public static function set okLabel(value:String):void
		{
			_okLabel = value;
		}

		public static function get yesLabel():String
		{
			return _yesLabel;
		}

		public static function set yesLabel(value:String):void
		{
			_yesLabel = value;
		}

		public function get noLabel():String
		{
			return _noLabel;
		}

		public static function set noLabel(value:String):void
		{
			_noLabel = value;
		}
	}
}