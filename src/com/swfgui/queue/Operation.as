package com.swfgui.queue
{
	import flash.events.EventDispatcher;

	public class Operation
	{
		public var thisRef:EventDispatcher;
		public var opFunction:Function;
		public var argArray:Array;
		public var paiallel:Boolean; //并行 串行 执行
		public var isComplete:Boolean;
		
		public function Operation(thisRef:EventDispatcher, opFunction:Function, argArray:Array=null, paiallel:Boolean = false)
		{
			this.thisRef = thisRef;
			this.opFunction = opFunction;            
			this.argArray = argArray;
			this.paiallel = paiallel;
		}
		
		public function exeOperation():void
		{
			opFunction.apply(thisRef, argArray);
		}
	}
}