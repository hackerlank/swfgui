EnterFrame和Render事件的关系

在flash内部，帧会被切分成“时间片”。这个工作是由一个组件（老外叫它Marshal元帅）控制的，它将时间切割成Flash Player工作的基本时间片。这里我们通常有一个误区，认为时间片和 swf 的帧速率是相关的。这是错误的，这里的时间片是绝对时间的，就是1秒可以分成多少个Flash Player的工作时间单位。在不同的平台上，切分单位是不同的。
每个时间片中，可能按以下顺序执行操作：

Player事件调度 – 比如Timer事件，鼠标事件，ENTER_FRAME事件，URLLoader事件等
用户代码执行 – 监听上一步事件的代码被执行
RENDER事件调度- 在用户代码执行期间调用 stage.invalidate()会触发这个特殊时间
最后的用户代码执行 – 监听上述第三步特殊事件的代码被执行
Player 更改显示列表

validation的三个阶段：validateProperties、validateSize、validateDisplay

validateProperties 由外向内调用，属性失效验证里面有好多属性要验证，而每个属性引起的改变又 不同，不能因为别的属性改变，而影响没有改变的属性的验证工作，所以，具体属性的改变也加个标志，如blendShaderChanged。

validateSize改变的因素有：内容的改变、maxXXX  minXXX  explicitXXX，
由内向外依次调用

validateDisplayList 由外向内依次更新

几个宽高的关系：
width、height：组件对用户的接口
explicitWidth、explicitHeight：用户显示设置width和height以后，存在这里
measuredWidth、measuredHeight：用户没有显示设置宽高，自动测量所得
preferredWidth、preferredHeight：测量时要用到的首选宽高，包括了scale
layoutBoundsWidth、layoutBoundsHeight：布局设置的宽高


UIComponent类完全分析：
构造函数：判断舞台存不存在，存在则初始化validateManager
addToStage：初始化valiateManager，检查阻塞的invalidateFlag
added：检查阻塞的invalidateFlag，调用initialize()，这说明，组件被移到舞台外以后，validate就没有效果了。
initialize：发出initialize事件，createChildren()留给用户覆盖，来初始化子项，childrenCreated()完全执行一次三个失效验证。
CREATION_COMPLETE：第一次三段失效验证结束后，validateManager设置initialized中发出的。

width和height改变：记录到explicitXXX里面，触发
invalidateProperties()、
invalidateDisplayList()、
invalidateParentSizeAndDisplayList()、
invalidateSize();
真可谓牵一发而动全身。

x和y的改变：直接给super.XXX，触发invalidateProperties()，其它的都交给父级的childXYChanged()处理

失效验证：调用invalidateXXX()，添加到invalidateXXXQueue队列里面，本帧的render或下一帧的开始的时候，调用validateXXX，添加到updateCompleteQueue队列里面，并设置updateCompletePendingFlag标志为true，这个标志主要是为了防止重复发出updateComplete事件。

我的设计：UIComponent里面不给用户设置layout，也没有autolayout属性，也不调用BasicLayout，只是调用layoutUtil。
从Canvas开始才显示使用layout，并且layout像flex那样，管理更多的东西，测量大小（如果autoWidth或autoHeight的话）、content大小，唯一和flex的layout的区别是，优化BasicLayout的性能，使得在测量的时候就确定了大小，而不是在updateDisplay的时候。
从用户的角度看，跟flex不同的是：1、自动大小默认是不开启的，需要设置autoWidth和autoHeight；2、比flex的UIComponent多了绝对布局功能，主要是为了方便伸缩皮肤；3、优化了BasicLayout性能。


layout：
管理scrollPosition
clipAndEnableScrolling
getScrollRect
