//
//  ViewController.m
//  DLNADemo
//
//  Created by Frank on 2022/1/7.
//

#import "ViewController.h"
#import <DLNACast/DLNACast.h>
#import <Masonry/Masonry.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,DLNACastManagerProtocol>

@property (nonatomic,strong) UITextField *videoURLTextField;

@property (nonatomic,strong) UIButton *searchBtn;

@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic,strong) DLNACastManager *castManager;

@property (nonatomic,strong) UITableView *deviceTableView;

@property (nonatomic,strong) NSArray *deviceArray;

@property (nonatomic,strong) UILabel *stateLabel;

// === 播放 暂停 快进
@property (nonatomic,strong) UIButton *playBtn;

@property (nonatomic,strong) UIButton *pauseBtn;

@property (nonatomic,strong) UIButton *seekBtn;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.castManager = [[DLNACastManager alloc] init];
    self.castManager.delegate = self;
    self.castManager.searchTimeout = 5.0;
    
    [self initializeSubviews];
}

- (void)initializeSubviews
{
    self.videoURLTextField = [[UITextField alloc] init];
    self.videoURLTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.videoURLTextField.text = @"http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4";
    self.videoURLTextField.backgroundColor = UIColor.grayColor;
    
    [self.view addSubview:self.videoURLTextField];
    [self.videoURLTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        make.left.equalTo(@20);
        make.centerX.equalTo(@0);
        make.height.equalTo(@50);
    }];
    
    self.searchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.searchBtn.backgroundColor = UIColor.cyanColor;
    [self.searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    
    [self.view addSubview:self.searchBtn];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoURLTextField);
        make.top.equalTo(self.videoURLTextField.mas_bottom).offset(30);
        make.height.equalTo(@50);
    }];
    
    [self.searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.hidesWhenStopped = YES;
    
    [self.view addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-30));
        make.centerY.equalTo(self.searchBtn);
    }];
    
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.indicatorView.mas_left).offset(-30);
    }];
    
    self.deviceTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.deviceTableView.backgroundColor = UIColor.grayColor;
    self.deviceTableView.delegate = self;
    self.deviceTableView.dataSource = self;
    
    [self.view addSubview:self.deviceTableView];
    [self.deviceTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchBtn);
        make.centerX.equalTo(@0);
        make.height.equalTo(@250);
        make.top.equalTo(self.searchBtn.mas_bottom).offset(30);
    }];
    
    self.stateLabel = UILabel.new;
    [self.view addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.centerX.equalTo(@0);
        make.height.equalTo(@30);
        make.top.equalTo(self.deviceTableView.mas_bottom).offset(10);
    }];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.playBtn.backgroundColor = UIColor.cyanColor;
    [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
    
    self.pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.pauseBtn.backgroundColor = UIColor.cyanColor;
    [self.pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
    
    self.seekBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.seekBtn.backgroundColor = UIColor.cyanColor;
    [self.seekBtn setTitle:@"快进5s" forState:UIControlStateNormal];
    
    [self.view addSubview:self.playBtn];
    [self.view addSubview:self.pauseBtn];
    [self.view addSubview:self.seekBtn];
    
    NSArray *views = @[self.playBtn,self.pauseBtn,self.seekBtn];
    
    [views mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20 leadSpacing:20 tailSpacing:20];
    
    [views mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stateLabel.mas_bottom).offset(20);
        make.height.equalTo(@70);
    }];
    
    [self.playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseBtn addTarget:self action:@selector(pauseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.seekBtn addTarget:self action:@selector(seekBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
}

#pragma mark - action
- (void)searchBtnClick
{
    [self.indicatorView startAnimating];
    [self.castManager searchTV];
}

- (void)playBtnClick
{
    [self.castManager dlnaPlay];
}

- (void)pauseBtnClick
{
    [self.castManager dlnaPause];
}

- (void)seekBtnClick
{
    [self.castManager seekToTime:self.castManager.currentTime + 5];
}

#pragma mark - table view delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    [self configueCell:cell device:self.deviceArray[indexPath.row]];
    
    return cell;
}

- (void)configueCell:(UITableViewCell *)cell device:(CLUPnPDevice *)device
{
    cell.textLabel.text = device.friendlyName;
    cell.detailTextLabel.text = device.uuid;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CLUPnPDevice *device = self.deviceArray[indexPath.row];
    [self.castManager chooseDevice:device castURL:self.videoURLTextField.text];
}

#pragma mark - dlna castmanager delegate

- (void)castManagerDidCastSuccess
{
    self.stateLabel.text = @"投屏成功";
}

// 结束搜索
- (void)castManagerDidEndSearching
{
    [self.indicatorView stopAnimating];
    self.stateLabel.text = @"搜索结束";
}

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

// 进度
- (void)castManagerDidPlayToTime:(long)sec
{
    NSLog(@"播放到 第 %ld 秒",sec);
    self.stateLabel.text = [NSString stringWithFormat:@"播放到 第 %ld 秒",sec];
}

// 投屏已经断开;
- (void)castManagerDidDisconnect
{
    NSLog(@"播放完成 或 断开");
    self.stateLabel.text = @"投屏断开了";
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
