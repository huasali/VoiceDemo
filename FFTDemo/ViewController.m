//
//  ViewController.m
//  FFTDemo
//
//  Created by sensology on 2016/11/2.
//  Copyright © 2016年 智觅智能. All rights reserved.
//

#import "ViewController.h"
#import "ShowView.h"
#import "JHAudioRecorder.h"

@interface ViewController ()<JHAudioRecordDelegate>{
    ShowView *sView;
    NSTimer *reloadTime;
}

@property (weak, nonatomic) IBOutlet UIButton *luyinBtn;
@property (weak, nonatomic) IBOutlet UIButton *bofangBtn;
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (atomic, strong) NSMutableArray *pointArr;

@end

@implementation ViewController

/*
 对于单声道声音文件，采样数据为八位的短整数（short int 00H-FFH）；而对于双声道立体声声音文件，每次采样数据为一个16位的整数（int），高八位和低八位分别代表左右两个声道。
 前者可用byte，后者可用short。
 */

- (void)viewDidLoad {
    
    [[JHAudioRecorder shareAudioRecorder] initAudioWithWidth:self.showView.frame.size.width andHeight:self.showView.frame.size.height];
    [[JHAudioRecorder shareAudioRecorder] setDelegate:self];
    
    self.pointArr = [[NSMutableArray alloc]init];
    
    sView = [[ShowView alloc]initWithFrame:CGRectMake(0, 0, self.showView.frame.size.width, self.showView.frame.size.height)];
    [self.showView addSubview:sView];
    
    reloadTime = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(reloadState:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:reloadTime forMode:NSRunLoopCommonModes];
    
}

- (void)reloadState:(NSTimer *)t{
    if (self.pointArr) {
        sView.pointArr = [NSMutableArray arrayWithArray:self.pointArr];
        [sView setNeedsDisplay];
    }
}

- (void)reloadValueWithArr:(NSArray *)valueArr{
    NSMutableArray *showArr = [[NSMutableArray alloc]init];
    for (int i  = 0; i < [valueArr count]; i++) {
        NSNumber *number = valueArr[i];
        float x = 10.0 + i * (self.showView.frame.size.width - 20) / 100;
        float height = (self.showView.frame.size.height*0.5) *[number doubleValue];
        
        float y = self.showView.frame.size.height/2.0f+ (height>self.showView.frame.size.height/2.0f?self.showView.frame.size.height/2.0f:height) ;
        NSValue *pValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
        [showArr addObject:pValue];
    }
    
    self.pointArr = [NSMutableArray arrayWithArray:showArr];
}

- (void)reloadOutValueWithArr:(NSArray *)valueArr{
    if (valueArr) {
        self.pointArr = [NSMutableArray arrayWithArray:valueArr];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startRAction:(id)sender {
    UIButton *btn = sender;
    
    if (![[JHAudioRecorder shareAudioRecorder].captureSession isRunning]) {
        if ([[JHAudioRecorder shareAudioRecorder] startRecording]) {
            [[JHAudioRecorder shareAudioRecorder].captureSession startRunning];
            [btn setTitle:@"停止" forState:UIControlStateNormal];
        }
    }
    else{
        [[JHAudioRecorder shareAudioRecorder] stopRecording];
        [[JHAudioRecorder shareAudioRecorder].captureSession stopRunning];
        [btn setTitle:@"开始" forState:UIControlStateNormal];
    }
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    sView.frame = CGRectMake(0, 0, self.showView.frame.size.width, self.showView.frame.size.height);
}

- (IBAction)startPAction:(id)sender {
    
    if (![[JHAudioRecorder shareAudioRecorder].audioPlayer isPlaying]) {
        NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"Kuba Oms - My Love" ofType:@"mp3"];
        if (pathStr) {
            [[JHAudioRecorder shareAudioRecorder] playRecordingWith:pathStr];
        }
    }
    else{
        [[JHAudioRecorder shareAudioRecorder] stopPlaying];
    }
    
}


@end
