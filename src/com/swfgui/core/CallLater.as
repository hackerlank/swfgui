package com.swfgui.core
{
	/**
	 * 延迟函数到屏幕重绘前执行。
	 * @param method 要延迟执行的函数
	 * @param args 函数参数列表
	 * @param delayFrames 延迟的帧数，0表示在当前帧的屏幕重绘前(Render事件)执行；
	 * 1表示下一帧EnterFrame事件时执行,2表示两帧后的EnterFrame事件时执行，以此类推。默认值0。
	 * @param callOnce 如果同一方法被CallLater多次，是否只有一次有效
	 */		
	public function CallLater(method:Function,args:Array=null,delayFrames:int=0,callOnce:Boolean = true):void
	{
		DelayCall.getInstance().callLater(method,args,delayFrames,callOnce);
	}
}

import com.swfgui.core.Application;
import flash.display.Shape;
import flash.events.Event;

/**
 * 延迟执行函数管理类
 * @author DOM
 */
class DelayCall extends Shape
{
	
	private static var _instance:DelayCall;
	/**
	 * 获取单例
	 */	
	public static function getInstance():DelayCall
	{
		if(!_instance)
			_instance = new DelayCall();
		return _instance;
	}
	/**
	 * 延迟函数队列 
	 */		
	private var methodQueue:Vector.<MethodQueueElement> = new Vector.<MethodQueueElement>();
	/**
	 * 是否添加过EnterFrame事件监听标志 
	 */		
	private var listenForEnterFrame:Boolean = false;
	/**
	 * 是否添加过Render事件监听标志 
	 */	
	private var listenForRender:Boolean = false;
	
	/**
	 * 延迟函数到屏幕重绘前执行。
	 * @param method 要延迟执行的函数
	 * @param args 函数参数列表
	 * @param delayFrames 延迟的帧数，0表示在当前帧的屏幕重绘前(Render事件)执行；
	 * 1表示下一帧EnterFrame事件时执行,2表示两帧后的EnterFrame事件时执行，以此类推。默认值0。
	 */		
	public function callLater(method:Function,args:Array=null,delayFrames:int=0, callOnce:Boolean = true):void
	{
		if(callOnce)
		{
			for each(var el:MethodQueueElement in methodQueue)
			{
				if(el.method == method && el.args == args && el.delayFrames == delayFrames)
				{
					return;
				}
			}
		}
		
		var element:MethodQueueElement = 
			new MethodQueueElement(method,args,delayFrames,delayFrames==0);
		methodQueue.push(element);
		if(!listenForEnterFrame)
		{
			addEventListener(Event.ENTER_FRAME,onCallBack);
			listenForEnterFrame = true;
		}
		if(element.onRender)
		{
			if(!listenForRender && Application.hasInstance)
			{
				Application.instance.stage.addEventListener(Event.RENDER,onCallBack,false,-1000);
				Application.instance.stage.invalidate();
				listenForRender = true;
			}
		}
	}
	/**
	 * 执行延迟函数
	 */		
	private function onCallBack(event:Event):void
	{
		var element:MethodQueueElement;
		var onRender:Boolean = Boolean(event.type==Event.RENDER);
		var startIndex:int = methodQueue.length-1;
		for(var i:int=startIndex;i>=0;i--)
		{
			element = methodQueue[i];
			if(onRender&&!element.onRender)
				continue;
			if(!element.onRender)
				element.delayFrames--;
			if(element.delayFrames>0)
				continue;
			methodQueue.splice(i,1);
			startIndex--;
			if(element.args==null)
			{
				element.method();
			}
			else
			{
				element.method.apply(null,element.args);
			}
		}
		var length:int = methodQueue.length;
		var hasOnRender:Boolean = false;
		startIndex = Math.max(0,startIndex);
		for(i=startIndex;i<length;i++)
		{
			if(methodQueue[i].onRender)
			{
				hasOnRender = true;
				break;
			}
		}
		if(!hasOnRender&&listenForRender)
		{
			Application.instance.stage.removeEventListener(Event.RENDER,onCallBack);
			listenForRender = false; 
		}
		if(methodQueue.length==0)
		{
			if(listenForEnterFrame)
			{
				removeEventListener(Event.ENTER_FRAME,onCallBack);
				listenForEnterFrame = false;
			}
			   
		}
	}
}

/**
 *  延迟执行函数元素
 */
class MethodQueueElement
{
	
	public function MethodQueueElement(method:Function,args:Array = null,delayFrames:int=0,onRender:Boolean=true)
	{
		this.method = method;
		this.args = args;
		this.delayFrames = delayFrames;
		this.onRender = onRender;
	}
	
	public var method:Function;
	
	public var args:Array;
	
	public var delayFrames:int;
	/**
	 * 在render事件触发
	 */	
	public var onRender:Boolean;
}