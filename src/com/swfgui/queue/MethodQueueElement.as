package com.swfgui.queue
{

	public class MethodQueueElement
	{
		/**
		 *
		 * @param method
		 * @param args
		 * @param callOnce 是否只调用一次
		 */
		public function MethodQueueElement(method:Function,
			args:Array /* of Object */ = null,
			callOnce:Boolean = true)
		{
			this.method = method;
			this.args = args;
			this.callOnce = callOnce;
		}
		
		public function call():void
		{
			if(method != null)
			{
				method.apply(null, args);
			}
		}
		
		public function clear():void
		{
			method = null;
			args = null;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  method
		//----------------------------------

		public var method:Function;

		//----------------------------------
		//  args
		//----------------------------------

		public var args:Array /* of Object */;

		public var callOnce:Boolean;
	}
}