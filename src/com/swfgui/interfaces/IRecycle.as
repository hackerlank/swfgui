package com.swfgui.interfaces 
{
	
	/**
	 * 可回收对象接口，对象池使用此接口
	 * @author llj
	 */
	public interface IRecycle 
	{
		/**
		 * 回收此对象
		 */
		function recycle():void;
	}
}