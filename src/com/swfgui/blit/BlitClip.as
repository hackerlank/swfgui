package com.swfgui.blit
{
	import com.swfgui.events.TickEvent;
	import com.swfgui.interfaces.IDisposable;
	import com.swfgui.queue.MethodQueueElement;
	import com.swfgui.utils.time.Tick;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;

	[Event(name="PLAY_COMPLETE", type="game.lib.blit.BlitClipEvent")]

	[Event(name="PLAY_START", type="game.lib.blit.BlitClipEvent")]

	[Event(name="PLAY_END", type="game.lib.blit.BlitClipEvent")]

	/**
	 * 位图缓存显示对象基类
	 * @author llj
	 */
	public class BlitClip extends Sprite implements IDisposable
	{
		/**
		 * BlitFrameData缓存
		 */
		public static const pool:BlitFrameDataPool = new BlitFrameDataPool();

		private var _hasDisposed:Boolean;

		/**
		 * 用户自定义的数据
		 */
		public var data:Object;

		protected var bitmap:Bitmap;

		protected var _frameData:Vector.<BlitFrameData>;

		protected var curIndex:int;

		protected var maxIndex:int;

		protected var _reverse:Boolean;

		protected var _isPlaying:Boolean;

		protected var _fps:int = 24;

		protected var _currentLabels:Array;

		protected var labelIndexes:Dictionary;

		/**
		 * 从此帧开始播放，发出播放开始事件
		 * @default
		 */
		protected var startIndex:int;
		/**
		 * 播放到此帧，发出播放结束事件
		 * @default
		 */
		protected var endIndex:int=-1;

		private var numLoops:int = -1; //-1为无限循环

		private var frameTimer:int;

		private var source:String;
		private var drawMc:Boolean;
		private var mc:MovieClip;
		private var mcCanvas:Sprite;

		private var frameListeners:Dictionary = new Dictionary();

		private var onPlayComplete:MethodQueueElement = new MethodQueueElement(null);

		private var scale:Number;
		private var hFlip:Boolean;


		public function BlitClip(view:DisplayObject=null):void
		{
			initialize();
			if (view is MovieClip)
			{
				fromMovieClipNotDraw(view as MovieClip);
			}
		}

		public function get hasDisposed():Boolean
		{
			return _hasDisposed;
		}

		public function dispose():void
		{
			if (_hasDisposed)
			{
				return;
			}

			_hasDisposed = true;

			this.removeEventListener(Event.ADDED_TO_STAGE, updatePlayStatus);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, updatePlayStatus);
			this.removeFrameListener(Event.ENTER_FRAME, onEnterFrame);

			stop();
			if (_frameData)
			{
				pool.unrefrenceItem(source, _frameData);
				_frameData = null;
			}

			if (bitmap.parent == this)
			{
				bitmap.parent.removeChild(bitmap);
			}

			if (mc && mc.parent == this || mc.parent == mcCanvas)
			{
				mc.parent.removeChild(mc);
				mc = null;
			}
		}

		protected function initialize():void
		{
			//此处还需要重置多个显示相关属性，待寻找简便方式
			this.x = 0;
			this.y = 0;
			this.alpha = 1;
			this.rotation = 0;
			this.visible = true;
			this.scaleX = 1;
			this.scaleY = 1;

			bitmap = new Bitmap();
			curIndex = 0;
			maxIndex = 0;

			addEventListener(Event.ADDED_TO_STAGE, updatePlayStatus);
			addEventListener(Event.REMOVED_FROM_STAGE, updatePlayStatus);
		}

		public function fromMovieClipNotDraw(mc:MovieClip):void
		{
			if (!mc)
			{
				return;
			}
			drawMc = false;
			this.mc = mc;
			this.addChild(mc);
			mc.gotoAndStop(1);
			_currentLabels = [];
			labelIndexes = new Dictionary();
			//提取标签
			var labels:Array = mc.currentLabels;
			var len:int = labels.length;
			var i:int;
			for (i = 0; i < len; i++)
			{
				var label:FrameLabel = labels[i];
				_currentLabels.push(new FrameLabel(label.name, label.frame));
				labelIndexes[name]= i;
			}
			maxIndex = mc.totalFrames - 1;
			play();
		}

		/**
		 * 根据mc生成位图序列，如果src、hFlip、scale都相同，则多个BlitClip共享此位图序列
		 * @param mc
		 * @param src mc资源地址，如"assets/a.swf#mc"
		 * @param hFlip 是否水平翻转，rpg角色动作中常用到
		 * @param scale 缩放
		 */
		public function fromMovieClip(mc:MovieClip, src:String=null, hFlip:Boolean=false, scale:Number=1):void
		{
			if (!mc)
			{
				return;
			}
			if (frameData)
			{
				pool.unrefrenceItem(source, frameData);
			}

			this.mc = mc;
			this.hFlip = hFlip;
			this.scale = scale;
			drawMc = true;
			if (src)
			{
				source = src + "_" + hFlip.toString() + "_" + scale.toString();
			}
			else
			{
				source = null;
			}

			var frames:Vector.<BlitFrameData>;

			if (source && pool.hasItem(source))
			{
				frames = pool.refrenceItem(source);
				frameData = frames;
			}
			else
			{
				frames = source ? pool.refrenceItem(source) : new Vector.<BlitFrameData>();
				var n:int = mc.totalFrames;
				for (var i:int = 0; i < n; i++)
				{
					var bfd:BlitFrameData = new BlitFrameData();
					frames.push(bfd);
				}
				for each (var label:FrameLabel in mc.currentLabels)
				{
					frames[label.frame - 1].frameLabel = label.name;
				}

				mc.scaleX = hFlip ? -scale : scale;
				mc.scaleY = scale;
				mc.x = mc.y = 0;
				mcCanvas = new Sprite();
				mcCanvas.addChild(mc);

				this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
				frameData = frames;
				var bfd:BlitFrameData = drawMcToBitmap();
				if(bfd)
				{
					bfd.applyBitmap(bitmap);
				}
			}
			
			this.addChild(bitmap);
			play();
		}

		protected function onEnterFrame(event:Event):void
		{
			if (isDrawComplete(_frameData))
			{
				this.removeFrameListener(Event.ENTER_FRAME, onEnterFrame);
				return;
			}
			drawMcToBitmap();
		}
		
		private function drawMcToBitmap():BlitFrameData
		{
			var curIndex:int = mc.currentFrame - 1;
			if (curIndex >= 0 && curIndex < _frameData.length)
			{
				var bfd:BlitFrameData = _frameData[curIndex];
				if (!bfd.bitmapData)
				{
					var newBfd:BlitFrameData = BitmapCacher.cacheBitmap(mcCanvas);
					bfd.bitmapData = newBfd.bitmapData;
					bfd.x = newBfd.x;
					bfd.y = newBfd.y;
				}
				return bfd;
			}
			
			return null;
		}

		private function isDrawComplete(frameData:Vector.<BlitFrameData>):Boolean
		{
			for each (var bfd:BlitFrameData in frameData)
			{
				if (!bfd.bitmapData)
				{
					return false;
				}
			}

			return true;
		}

		private function stopAll(mc:DisplayObjectContainer):void
		{
			if (mc is MovieClip)
			{
				(mc as MovieClip).stop();
			}
			var n:int = mc.numChildren;
			for (var i:int = 0; i < n; i++)
			{
				var c:DisplayObjectContainer = mc.getChildAt(i) as DisplayObjectContainer;
				if (c)
				{
					stopAll(c);
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  新增播放控制接口
		//
		//--------------------------------------------------------------------------

		/**
		 * 当运行到某一帧时，执行回调函数，一次有效
		 * @param frame
		 * @param onTargetFrame
		 * @return 指定帧是否存在
		 */
		public function addFrameListener(frame:Object, method:Function, args:Array=null, callOnce:Boolean=true):Boolean
		{
			var index:int = getFrameIndexByObject(frame);
			if (index != -1)
			{
				frameListeners[index] = new MethodQueueElement(method, args, callOnce);
			}

			return index != -1;
		}

		public function removeFrameListener(frame:Object, medthod:Function=null):void
		{
			var index:int = getFrameIndexByObject(frame);
			if (index != -1)
			{
				delete frameListeners[index];
			}
		}

		/**
		 * 从当前帧播放到frame，然后停止
		 * @param frame
		 * @return frame帧不存在则返回false
		 */
		public function playTo(frame:Object, onComplete:Function=null, onCompleteArgs:Array=null, loop:int=1):Boolean
		{
			return playFromTo(currentFrame, frame, onComplete, onCompleteArgs, loop);
		}

		/**
		 * 从frame1播放到frame2,然后停止
		 * @param frame1
		 * @param frame2
		 * @return frame1或frame2帧不存在则返回false
		 */
		public function playFromTo(
			frame1:Object, frame2:Object=null, onComplete:Function=null, 
			onCompleteArgs:Array=null, loop:int=1):Boolean
		{
			var rtv:Boolean = true;
			startIndex = getFrameIndexByObject(frame1);
			endIndex = getFrameIndexByObject(frame2);

			if (startIndex < 0)
			{
				rtv = false;
				startIndex = 0;
			}
			if (endIndex < 0)
			{
				rtv = false;
				endIndex = maxIndex;
			}

			numLoops = loop;
			onPlayComplete.method = onComplete;
			onPlayComplete.args = onCompleteArgs;
			goon();

			return rtv;
		}

		public function pause():void
		{
			_isPlaying = false;
			updatePlayStatus();
		}

		public function goon():void
		{
			exit = true;
			_isPlaying = true;
			updatePlayStatus();
		}

		/**
		 * 返回帧
		 * @param label
		 * @return
		 */
		public function getFrameByLabel(label:String):int
		{
			var rtv:int=getFrameIndexByObject(label);

			return rtv < 0 ? rtv : rtv + 1;
		}

		//--------------------------------------------------------------------------
		//
		//  MovieClip兼容接口
		//
		//--------------------------------------------------------------------------

		/**
		 * 播放
		 */
		public function play():void
		{
			numLoops = -1;
			startIndex = 0;
			endIndex = maxIndex;
			_isPlaying = true;
			exit = true;
			updatePlayStatus();
		}

		/**
		 * 停止
		 */
		public function stop():void
		{
			numLoops = -1;
			startIndex = 0;
			endIndex = maxIndex;
			_isPlaying = false;
			updatePlayStatus();
		}

		public function prevFrame():void
		{
			gotoFrame(curIndex - 1);
		}

		/**
		 * 跳转到下一帧
		 */
		public function nextFrame():void
		{
			gotoFrame(curIndex + 1);
		}

		/**
		 * 跳转到指定帧并播放
		 * @param	frame
		 */
		public function gotoAndPlay(frame:Object):Boolean
		{
			var rtv:Boolean = gotoFrameObj(frame);
			play();

			return rtv;
		}

		/**
		 * 跳转到指定帧并停止
		 * @param	frame
		 */
		public function gotoAndStop(frame:Object):Boolean
		{
			var rtv:Boolean = gotoFrameObj(frame);
			stop();

			return rtv;
		}

		//--------------------------------------------------------------------------
		//
		//  私有
		//
		//--------------------------------------------------------------------------

		protected function updatePlayStatus(evt:Event=null):void
		{
			if (_isPlaying && maxIndex > 1 && stage != null)
			{
				Tick.instance.addEventListener(TickEvent.TICK, onTick);
			}
			else
			{
				Tick.instance.removeEventListener(TickEvent.TICK, onTick);
			}
		}

		/**
		 *
		 * @param frame
		 * @return frameData的索引，不是frame
		 */
		protected function getFrameIndexByObject(frame:Object):int
		{
			if (frame is String)
			{
				if (labelIndexes[frame])
				{
					return int(labelIndexes[frame]);
				}
				else
				{
					return -1;
				}
			}
			else
			{
				///用户指定的帧数从1开始，程序内部的数组索引从0开始  因此减1
				return int(frame) - 1;
			}
		}

		/**
		 * 跳转到指定帧
		 * @param frame
		 */
		protected function gotoFrameObj(frame:Object):Boolean
		{
			var frameIndex:int = getFrameIndexByObject(frame);
			if (frameIndex < 0)
			{
				return false;
			}
			else
			{
				gotoFrame(frameIndex);
				return true;
			}
		}

		/**
		 * 跳转到指定索引的帧
		 * @param	frameIndex
		 */
		protected function gotoFrame(frameIndex:int):void
		{
			if (frameIndex > maxIndex)
			{
				frameIndex = reverse ? maxIndex : 0;
			}
			else if (frameIndex < 0)
			{
				frameIndex = reverse ? maxIndex : 0;
			}
			curIndex = frameIndex;

			if (drawMc)
			{
				var bfd:BlitFrameData = _frameData[curIndex];
				bfd.applyBitmap(bitmap);
			}
			else if (mc)
			{
				if (currentFrame == mc.currentFrame + 1)
				{
					mc.nextFrame();
				}
				else if (currentFrame == mc.currentFrame - 1)
				{
					mc.prevFrame();
				}
				else
				{
					mc.gotoAndStop(currentFrame);
				}
			}

			var mqe:MethodQueueElement = frameListeners[curIndex];
			if (mqe)
			{
				mqe.call();
				if (mqe.callOnce)
				{
					delete frameListeners[curIndex];
				}
			}
		}

		/**
		 * 一次播放是否完毕
		 * @return
		 */
		private function isPlayEnd():Boolean
		{
			if (reverse)
			{
				return curIndex == startIndex;
			}
			else
			{
				return curIndex == endIndex;
			}
		}

		private var exit:Boolean;

		protected function onTick(event:TickEvent):void
		{
			if (numLoops == 0 || totalFrames <= 1 || fps == 0)
			{
				return;
			}

			frameTimer -= event.interval;
			while (numLoops != 0 && frameTimer < 0)
			{
				if (isPlayEnd())
				{
					if (numLoops > 0)
					{
						numLoops--;
					}

					if (numLoops == 0)
					{
						//防止onPlayComplete中又赋值了onPlayComplete
						var method:Function = onPlayComplete.method;
						onPlayComplete.call();
						if (onPlayComplete.method == method)
						{
							onPlayComplete.clear();
						}
						dispatchEvent(new BlitClipEvent(BlitClipEvent.PLAY_COMPLETE, currentLabel));

						//防止onPlayComplete中调用了play等播放函数
						if (exit)
						{
							exit = false;
						}
						else
						{
							frameTimer = 0; //停止动画时需要将延时重置为0
						}
					}
					else
					{
						loopBackToStart();
					}
				}
				else
				{
					if (reverse)
					{
						prevFrame();
					}
					else
					{
						nextFrame()
					}
				}

				frameTimer += 1000/ fps;
			}
		}

		protected function loopBackToStart():void
		{
			gotoFrame(reverse ? endIndex : startIndex);
		}

		/**
		 * 位图帧序列
		 */
		public function get frameData():Vector.<BlitFrameData>
		{
			return _frameData;
		}

		public function set frameData(value:Vector.<BlitFrameData>):void
		{
			_frameData = value;
			bitmap.bitmapData = null;
			_currentLabels = [];
			labelIndexes = new Dictionary();

			if (_frameData == null)
			{
				curIndex = 0;
				maxIndex = 0;
			}
			else
			{
				maxIndex = _frameData.length - 1;
				gotoFrame(curIndex);

				//提取标签
				var len:int = _frameData.length;
				var i:int;
				for (i = 0; i < len; i++)
				{
					var name:String = _frameData[i].frameLabel;
					if (name)
					{
						_currentLabels.push(new FrameLabel(name, i + 1));
						labelIndexes[name]= i;
					}
				}
			}
		}

		public function get viewMC():MovieClip
		{
			return mc;
		}

		/**
		 * 获取当前帧索引
		 */
		public function get currentFrame():int
		{
			///用户指定的帧数从1开始，程序内部的数组索引从0开始  因此加1
			return maxIndex > 0 ? curIndex + 1 : 0;
		}

		/**
		 * 获取总的帧数
		 */
		public function get totalFrames():int
		{

			return maxIndex > 0 ? maxIndex + 1 : 0;

		}

		/**
		 * 获取或设置位图是否启用平滑处理
		 */
		public function get smoothing():Boolean
		{
			return bitmap.smoothing;
		}

		public function set smoothing(value:Boolean):void
		{
			bitmap.smoothing = value;
		}

		/**
		 * 指示动画当前是否正在播放
		 */
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}

		/**
		 * 获取当前位图帧信息
		 */
		public function getCurrentBlitFrameData():BlitFrameData
		{
			return _frameData ? _frameData[curIndex] : null;
		}

		/**
		 * 获取指定索引的位图帧信息
		 * @param	index
		 * @return
		 */
		public function getBlitFrameData(frame:int):BlitFrameData
		{
			///用户指定的帧数从1开始，程序内部的数组索引从0开始  因此减1
			return _frameData ? _frameData[frame - 1] : null;
		}

		/**
		 * 返回帧标签，不存在，则返回null
		 * @return
		 */
		public function get currentLabel():String
		{
			return labelIndexes[curIndex];
		}

		/**
		 * 返回所有的标签
		 * @return
		 */
		public function get currentLabels():Array
		{
			return _currentLabels;
		}

		/**
		 * 播放帧率，默认24
		 * @return
		 */
		public function get fps():int
		{
			return _fps;
		}

		public function set fps(value:int):void
		{
			_fps = value;
		}

		/**
		 * 反向播放，默认false
		 * @return
		 */
		public function get reverse():Boolean
		{
			return _reverse;
		}

		public function set reverse(value:Boolean):void
		{
			_reverse = value;
		}

	}
}