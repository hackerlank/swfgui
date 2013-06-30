package com.swfgui.queue
{
	import flash.events.EventDispatcher;
	
	import com.swfgui.utils.ArrayUtil;

	/**
	 * 执行队列，按时间顺序自动执行操作
	 * @author liulijun
	 */
	public class OperationQueue
	{
		private var opArr:Array;
		private var oldArr:Array;
		private var paiallelArr:Array;
		private var canExe:Boolean=true;
		
		private var curOp:Operation;
		
		public function OperationQueue()
		{
			opArr = [];
			paiallelArr = [];
			oldArr = [];
		}
		
		public function get isNull():Boolean
		{
			return (opArr.length == 0);
		}
		
		public function clear():void
		{
			opArr.length = 0;
		}
		
		/**
		 * 顺序执行多个操作，每个操作执行完毕以后，会发出OperationEvent.COMPLETE事件。
		 * @param thisRef
		 * @param opFunction
		 * @param argArray
		 * @param paiallel n个paiallel为true的操作，会同时执行，
		 * 当n个操作全部都执行完毕以后，才继续执行后续操作。
		 */
		public function push(thisRef:EventDispatcher, opFunction:Function, argArray:Array=null, paiallel:Boolean = false):void
		{
			if(!thisRef || opFunction==null)
			{
				return;
			}
			
			var op:Operation = new Operation(thisRef, opFunction, argArray, paiallel);
			thisRef.addEventListener(OperationEvent.COMPLETE, opCpt);
			
			opArr.push(op);
			if(canExe || (paiallel && opArr.length == 0))
			{
				exeOperation();
			}
		}
		
		private function opCpt(e:OperationEvent):void
		{
			var target:Operation = ArrayUtil.getItemByProperty("thisRef", e.thisRef, oldArr) as Operation;
			if(!target)
			{
				return;
			}
			
			ArrayUtil.deleteItem(target, oldArr);
			target.isComplete = true;
			
			if(ArrayUtil.hasItemByProperty("thisRef", e.thisRef, paiallelArr))
			{
				for each(var op:Operation in paiallelArr)
				{
					if(!op.isComplete)
					{
						return;
					}
				}
				
				paiallelArr.length = 0;
				canExe = true;
				exeOperation();
			}
			else
			{
				canExe = true;
				exeOperation();
			}
		}
		
		public function pop():Operation
		{
			return opArr.pop();
		}
		
		//取出第一个操作执行，然后检查能否继续执行
		public function exeOperation():void
		{
			if(opArr.length == 0)
			{
				canExe = true;
				return;
			}
			
			var op:Operation = opArr[0];
			if(op.paiallel)
			{
				while(opArr.length)
				{
					op = opArr[0];
					if(!op.paiallel)
					{
						break;
					}
					
					curOp = op;
					op.exeOperation();
					oldArr.push(opArr.shift());
					paiallelArr.push(op);
				}
			}
			else
			{
				curOp = op;
				oldArr.push(opArr.shift());
				op.exeOperation();
			}
			
			canExe = false;
		}
	}	
}