package com.swfgui.debug
{
import flash.events.Event;

import com.swfgui.utils.Utils;

/**
 *	Logger事件 
 * @author Allen
 * 
 */
public class LoggerEvent extends Event
{
	
	/**
	 * 记录
	 */		
	public static const Log:String = "Log";
	
	/**
	 * 错误
	 */		
	public static const ERROR:String = "ERROR";
	
	/**
	 * 警告 
	 */		
	public static const WARNING:String = "WARNING";
	
	
	
	
	/**
	 * 打印信息
	 */		
	public var msg:String;
	
	
	/**
	 * 触发logger事件的类名
	 */		
	public var className:String;
	
	
	public function LoggerEvent(type:String, instance:*, msg:String)
	{
		super(type);
		this.className = Utils.getClassName(instance);
		this.msg = msg;
	}
	
}
}