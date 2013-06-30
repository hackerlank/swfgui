package com.swfgui.interfaces
{

	/**
	 * 析构接口
	 * @author llj
	 */
	public interface IDisposable
	{
		function dispose():void;

		function get hasDisposed():Boolean;
	}
}