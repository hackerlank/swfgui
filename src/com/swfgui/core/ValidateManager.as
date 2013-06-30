package com.swfgui.core
{
	import com.swfgui.events.UIEvent;
	
	import flash.display.Shape;
	import flash.events.Event;
	
	/**
	 * 所有组件的一次三个延迟验证渲染阶段全部完成 
	 */	
	[Event(name="updateComplete", type="com.swfgui.core.events.UIEvent")]
	/**
	 * 布局管理器
	 * @author llj
	 */
	public class ValidateManager extends Shape
	{
		private static var _instance:ValidateManager;
		
		public static function get instance():ValidateManager
		{
			return _instance || (_instance = new ValidateManager());
		}
		
		public function ValidateManager()
		{
			super();
		}
		
		private var targetLevel:int = int.MAX_VALUE;
		/**
		 * 需要抛出组件初始化完成事件的对象 
		 */		
		private var updateCompleteQueue:DepthQueue = new DepthQueue();
		
		private var invalidatePropertiesFlag:Boolean = false;
		
		private var invalidateClientPropertiesFlag:Boolean = false;
		
		private var invalidatePropertiesQueue:DepthQueue = new DepthQueue();
		/**
		 * 标记组件提交过属性
		 */		
		public function invalidateProperties(client:IValidatable):void
		{
			if(!invalidatePropertiesFlag)
			{
				invalidatePropertiesFlag = true;
				if(!listenersAttached)
					attachListeners();
			}
			if (targetLevel <= client.nestLevel)
				invalidateClientPropertiesFlag = true;
			invalidatePropertiesQueue.insert(client);
		}
		
		/**
		 * 使提交的属性生效，由外向内，父级属性更改，可能会影响到子项，而子项的属性更改很少影响都父级，
		 * 所以属性的生效是由外向内的
		 */		
		private function validateProperties():void
		{
			var client:IValidatable = invalidatePropertiesQueue.shift();
			while(client)
			{
				//if (client.hasParent)
				{
					//验证期间，client组件会阻止自身再次触发invalidateProperties，但不会阻止别的组件
					//触发invalidateProperties，也不会阻止触发别的invalidateXXX
					client.validateProperties();
					//防止多次触发更新完成事件
					if (!client.updateCompletePendingFlag)
					{
						updateCompleteQueue.insert(client);
						client.updateCompletePendingFlag = true;
					}
				}        
				client = invalidatePropertiesQueue.shift();
			}
			if(invalidatePropertiesQueue.isEmpty())
				invalidatePropertiesFlag = false;
		}
		
		private var invalidateSizeFlag:Boolean = false;
		
		private var invalidateClientSizeFlag:Boolean = false;
		
		private var invalidateSizeQueue:DepthQueue = new DepthQueue();
		/**
		 * 标记需要重新测量尺寸
		 */		
		public function invalidateSize(client:IValidatable):void
		{
			if(!invalidateSizeFlag)
			{
				invalidateSizeFlag = true;
				if(!listenersAttached)
					attachListeners();
			}
			if (targetLevel <= client.nestLevel)
				invalidateClientSizeFlag = true;
			invalidateSizeQueue.insert(client);
		}
		/**
		 * 测量属性，由内向外，先测量确定子项的大小，然才能确定父级的大小
		 */		
		private function validateSize():void
		{
			var client:IValidatable = invalidateSizeQueue.pop();
			while(client)
			{
				//if (client.hasParent)
				{
					client.validateSize();
					if (!client.updateCompletePendingFlag)
					{
						updateCompleteQueue.insert(client);
						client.updateCompletePendingFlag = true;
					}
				}      
				client = invalidateSizeQueue.pop();
			}
			if(invalidateSizeQueue.isEmpty())
				invalidateSizeFlag = false;
		}
		
		
		private var invalidateDisplayListFlag:Boolean = false;
		
		private var invalidateDisplayListQueue:DepthQueue = new DepthQueue();
		/**
		 * 标记需要重新测量尺寸
		 */		
		public function invalidateDisplayList(client:IValidatable ):void
		{
			if(!invalidateDisplayListFlag)
			{
				invalidateDisplayListFlag = true;
				if(!listenersAttached)
					attachListeners();
			}
			invalidateDisplayListQueue.insert(client);
		}
		/**
		 * 测量属性，由外向内，为何由外向内？刷新子项的时候，会改变子项的size，又会触发“子项的子项”的size，
		 * 触发以后，添加到invalidateDisplayListQueue中本组件的后面，这样就能保证一次把所有子项的子项都刷新，而不会
		 * 延迟改变
		 */		
		private function validateDisplayList():void
		{
			var client:IValidatable = invalidateDisplayListQueue.shift();
			while(client)
			{
				//if (client.hasParent)
				{
					client.validateDisplayList();
					if (!client.updateCompletePendingFlag)
					{
						updateCompleteQueue.insert(client);
						client.updateCompletePendingFlag = true;
					}
				}      
				client = invalidateDisplayListQueue.shift();
			}
			if(invalidateDisplayListQueue.isEmpty())
				invalidateDisplayListFlag = false;
		}
		/** 
		 * 是否已经添加了事件监听
		 */		
		private var listenersAttached:Boolean = false;
		/**
		 * 添加事件监听
		 */		
		private function attachListeners():void
		{
			this.addEventListener(Event.ENTER_FRAME,doPhasedInstantiation);
			this.addEventListener(Event.RENDER, doPhasedInstantiation);
			if(Application.hasInstance)
			{
				Application.instance.stage.invalidate();
			}
			listenersAttached = true;
		}
		/**
		 * 执行属性应用
		 */		
		private function doPhasedInstantiation(event:Event=null):void
		{
			this.removeEventListener(Event.ENTER_FRAME,doPhasedInstantiation);
			this.removeEventListener(Event.RENDER, doPhasedInstantiation);
			if (invalidatePropertiesFlag)
			{
				validateProperties();
			}
			if (invalidateSizeFlag)
			{
				validateSize();
			}
				
			if (invalidateDisplayListFlag)
			{
				validateDisplayList();
			}
			
			if (invalidatePropertiesFlag ||
				invalidateSizeFlag ||
				invalidateDisplayListFlag)
			{
				attachListeners();
			}
			else
			{
				listenersAttached = false;
				var client:IValidatable = updateCompleteQueue.pop();
				while (client)
				{
					//第一次失效验证完成后，设置初始化标志
					if (!client.initialized)
						client.initialized = true;
					//发出更新完成事件的顺序是由内向外
					if (client.hasEventListener(UIEvent.UPDATE_COMPLETE))
						client.dispatchEvent(new UIEvent(UIEvent.UPDATE_COMPLETE));
					client.updateCompletePendingFlag = false;
					client = updateCompleteQueue.pop();
				}

				dispatchEvent(new UIEvent(UIEvent.UPDATE_COMPLETE));
			}
		}
		/**
		 * 立即应用所有延迟的属性
		 */		
		public function validateNow():void
		{
			var infiniteLoopGuard:int = 0;
			while (listenersAttached && infiniteLoopGuard++ < 100)
				doPhasedInstantiation();
		}
		/**
		 * 使大于等于指定组件层级的元素立即应用属性，也就是更新组件及其子项
		 * @param target 要立即应用属性的组件
		 * @param skipDisplayList 是否跳过更新显示列表阶段
		 */			
		public function validateClient(target:IValidatable, skipDisplayList:Boolean = false):void
		{
			
			var obj:IValidatable;
			var i:int = 0;
			var done:Boolean = false;
			var oldTargetLevel:int = targetLevel;
			
			if (targetLevel == int.MAX_VALUE)
				targetLevel = target.nestLevel;
			
			while (!done)
			{
				done = true;
				
				obj = IValidatable(invalidatePropertiesQueue.removeSmallestChild(target));
				while (obj)
				{
					if (obj.hasParent)
					{
						obj.validateProperties();
						if (!obj.updateCompletePendingFlag)
						{
							updateCompleteQueue.insert(obj);
							obj.updateCompletePendingFlag = true;
						}
					}
					obj = IValidatable(invalidatePropertiesQueue.removeSmallestChild(target));
				}
				
				if (invalidatePropertiesQueue.isEmpty())
				{
					invalidatePropertiesFlag = false;
				}
				invalidateClientPropertiesFlag = false;
				
				obj = IValidatable(invalidateSizeQueue.removeLargestChild(target));
				while (obj)
				{
					if (obj.hasParent)
					{
						obj.validateSize();
						if (!obj.updateCompletePendingFlag)
						{
							updateCompleteQueue.insert(obj);
							obj.updateCompletePendingFlag = true;
						}
					}
					if (invalidateClientPropertiesFlag)
					{
						obj = IValidatable(invalidatePropertiesQueue.removeSmallestChild(target));
						if (obj)
						{
							invalidatePropertiesQueue.insert(obj);
							done = false;
							break;
						}
					}
					
					obj = IValidatable(invalidateSizeQueue.removeLargestChild(target));
				}
				
				if (invalidateSizeQueue.isEmpty())
				{
					invalidateSizeFlag = false;
				}
				invalidateClientPropertiesFlag = false;
				invalidateClientSizeFlag = false;
				
				if (!skipDisplayList)
				{
					obj = IValidatable(invalidateDisplayListQueue.removeSmallestChild(target));
					while (obj)
					{
						if (obj.hasParent)
						{
							obj.validateDisplayList();
							if (!obj.updateCompletePendingFlag)
							{
								updateCompleteQueue.insert(obj);
								obj.updateCompletePendingFlag = true;
							}
						}
						if (invalidateClientPropertiesFlag)
						{
							obj = IValidatable(invalidatePropertiesQueue.removeSmallestChild(target));
							if (obj)
							{
								invalidatePropertiesQueue.insert(obj);
								done = false;
								break;
							}
						}
						
						if (invalidateClientSizeFlag)
						{
							obj = IValidatable(invalidateSizeQueue.removeLargestChild(target));
							if (obj)
							{
								invalidateSizeQueue.insert(obj);
								done = false;
								break;
							}
						}
						
						obj = IValidatable(invalidateDisplayListQueue.removeSmallestChild(target));
					}
					
					
					if (invalidateDisplayListQueue.isEmpty())
					{
						invalidateDisplayListFlag = false;
					}
				}
			}
			
			if (oldTargetLevel == int.MAX_VALUE)
			{
				targetLevel = int.MAX_VALUE;
				if (!skipDisplayList)
				{
					obj = IValidatable(updateCompleteQueue.removeLargestChild(target));
					while (obj)
					{
						if (!obj.initialized)
							obj.initialized = true;
						
						if (obj.hasEventListener(UIEvent.UPDATE_COMPLETE))
							obj.dispatchEvent(new UIEvent(UIEvent.UPDATE_COMPLETE));
						obj.updateCompletePendingFlag = false;
						obj = IValidatable(updateCompleteQueue.removeLargestChild(target));
					}
				}
			}
		}

	}
}