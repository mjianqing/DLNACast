# DLNACast
iOS DLNA投屏

### 简介
DLNACast库可以被用于视频播放软件，满足投屏的需求；基于DLNA_UPnP（https://github.com/ClaudeLi/DLNA_UPnP） 库做了封装，拓展了部分没有的接口。依赖‘GCDAsyncSocket’和‘GDataXMLNode’，系统库libxml2.tbd。

### 接口简介
主要的方法有：‘搜索’，‘连接’，‘断开’，‘播放’，‘暂停’，‘进度调整’，‘音量调整’；
拓展了实时播放进度和播放状态的获取，转交给代理；

#### 搜索
```
- (void)searchBtnClick
{
    [self.indicatorView startAnimating];
    [self.castManager searchTV];
}
```

### 搜索到了设备
```
// 投屏搜索到了设备
- (void)castManagerDidSearchDevices:(NSArray *)devices
{
    if (devices.count)
    {
        self.stateLabel.text = @"搜索到了设备";
        self.deviceArray = devices;
        [self.deviceTableView reloadData];
    }
}
```

#### 连接
```
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CLUPnPDevice *device = self.deviceArray[indexPath.row];
    [self.castManager chooseDevice:device castURL:self.videoURLTextField.text];
}
```

#### 投屏连接成功
```
- (void)castManagerDidCastSuccess
{
    self.stateLabel.text = @"投屏成功";
}
```

#### 暂停

```
- (void)pauseBtnClick
{
    [self.castManager dlnaPause];
}
```

#### 播放
```
- (void)playBtnClick
{
    [self.castManager dlnaPlay];
}
```

#### 进度回调
```
// 进度
- (void)castManagerDidPlayToTime:(long)sec
{
    NSLog(@"播放到 第 %ld 秒",sec);
    self.stateLabel.text = [NSString stringWithFormat:@"播放到 第 %ld 秒",sec];
}
```


#### 进度调整
如：快进5s
```
- (void)seekBtnClick
{
    [self.castManager seekToTime:self.castManager.currentTime + 5];
}
```


### 注意事项
* 项目工程的info要加入‘Privacy - Local Network Usage Description’key
* 手机或模拟器要与电视处于同一wifi网络；
* Demo可以在地址栏输入任意视频URL地址进行测试；
