
### WordClock

一直有在用那个屏保WordClock很喜欢，看到有人用安卓做了一个。iOS版的没有比较合适的，所以就写了这个Demo。但是iPhone的壁纸不能像安卓那么强大，网上给的方案用3D Touch的Live Photo也有点蠢，所以这块暂时没什么办法。

### 工程简介

#### ViewController 

实例化BSHWordClockView，实现其代理方法。

```oc

self.wordClock = [[BSHWordClockView alloc] initWithFrame:t];
self.wordClock.center = self.view.center;
self.wordClock.delegate = self;
self.wordClock.dataSource = self;
[self.view addSubview:self.wordClock];
    
#pragma mark - BSHWordDataSource

- (NSInteger)numberOfWordClockItemsIn:(NSInteger)section {
    return [self.sourceArray[section] count];
}

- (NSInteger)numberOfWordClockSections {
    return self.sourceArray.count;
}

- (NSString *)wordClockTextSection:(NSInteger)section andIndex:(NSInteger)index {
    NSArray *a = self.sourceArray[section];
    return a[index];
}

- (__kindof UIView *)wordItemViewForIndex:(NSInteger)index section:(NSInteger)section {
    BSHWordItemLabel *label = [[BSHWordItemLabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:8];
    label.textAlignment = NSTextAlignmentRight;
    return label;
}
```

#### 时钟

##### BSHWordClockLayoutAttribute

持有坐标和形变的model

##### BSHWordItemLabel

持有BSHWordClockLayoutAttribute的Label

##### BSHWordClockView

为了便于维护和扩展，时钟的主View设计成API和TableView类似。


###### BSHWordDataSource

要求代理必须实现。

###### BSHWordDelegate

待扩展的协议。


#### 功能列表

- [x] 文本自定义
- [x] 按秒定时更新
- [x] 流式布局和环形布局简单切换

#### 待定

- [ ] 流式布局和环形布局仿WordClock切换动画
- [ ] 支持手势滑动


### 参考

1. [【自定义View】抖音网红文字时钟](https://juejin.im/post/5cb53e93e51d456e55623b07)
2. [HYWordClockDemo](https://github.com/aixinchao/HYWordClockDemo)
3. [CharacterClock](https://github.com/lww7329/CharacterClock)


