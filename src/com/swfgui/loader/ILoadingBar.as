package com.swfgui.loader
{
	public interface ILoadingBar
	{
		function update(curLoadName:String, 
						curBytesLoaded:int, 
						curBytesTotal:int,
						curLoadIndex:int, 
						total:int):void;
	}
}