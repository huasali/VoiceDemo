//
//  ViewController.m
//  FFTDemo
//
//  Created by sensology on 2016/11/2.
//  Copyright © 2016年 智觅智能. All rights reserved.
//

#import "ViewController.h"
#import "ShowView.h"

@interface ViewController ()<AVCaptureAudioDataOutputSampleBufferDelegate>{
    ShowView *sView;
    NSTimer *reloadTime;
}

@property (weak, nonatomic) IBOutlet UIButton *luyinBtn;
@property (weak, nonatomic) IBOutlet UIButton *bofangBtn;
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (atomic, strong) NSMutableArray *m_pointWavArray;

@end

@implementation ViewController

/*
 对于单声道声音文件，采样数据为八位的短整数（short int 00H-FFH）；而对于双声道立体声声音文件，每次采样数据为一个16位的整数（int），高八位和低八位分别代表左右两个声道。
 前者可用byte，后者可用short。
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAudio];
    self.m_pointWavArray = [[NSMutableArray alloc]init];
     sView = [[ShowView alloc]initWithFrame:CGRectMake(0, 0, self.showView.frame.size.width, self.showView.frame.size.height)];
    [self.showView addSubview:sView];
    reloadTime = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reloadState:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:reloadTime forMode:NSRunLoopCommonModes];

}

- (void)reloadState:(NSTimer *)t{
    if (self.m_pointWavArray) {
        sView.m_pointWavArray = [NSMutableArray arrayWithArray:self.m_pointWavArray];
        [sView setNeedsDisplay];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startRAction:(id)sender {
    UIButton *btn = sender;
    
    if ([_captureSession isRunning]) {
        [_captureSession stopRunning];
        [btn setTitle:@"开始录音" forState:UIControlStateNormal];
    }
    else{
       [_captureSession startRunning];
        [btn setTitle:@"停止录音" forState:UIControlStateNormal];
    }
    
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    sView.frame = CGRectMake(0, 0, self.showView.frame.size.width, self.showView.frame.size.height);
}

- (IBAction)startPAction:(id)sender {
    
}

- (void)initAudio{
    
    _captureSession = [[AVCaptureSession alloc]init];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    NSError *error = nil;
    
    AVCaptureDevice *audioDev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc]initWithDevice:audioDev error:&error];
    
    if ([_captureSession canAddInput:audioIn]) {
        [_captureSession addInput:audioIn];
    }
    
    
    _captureAudioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    if([_captureSession canAddOutput:_captureAudioDataOutput]) {
        
        [_captureSession addOutput:_captureAudioDataOutput];
        //指定代理 增加并行线程
        dispatch_queue_t queue = dispatch_queue_create("myQueue",DISPATCH_QUEUE_SERIAL);
        [_captureAudioDataOutput setSampleBufferDelegate:self queue:queue];
        [_captureAudioDataOutput connectionWithMediaType:AVMediaTypeAudio];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    NSMutableArray *dataArr = [[NSMutableArray alloc]init];
    AudioBufferList audioBufferList;
    CMBlockBufferRef blockBuffer;
    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);
    for( int y=0; y< audioBufferList.mNumberBuffers; y++ ){
        
        AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
        Byte *frame = (Byte *)audioBuffer.mData;
        int d = audioBuffer.mDataByteSize/2;
        for(long i=0; i<d; i++)
        {
            long x1 = frame[i*2+1]<<8;
            long x2 = frame[i*2];
            short int w = x1 | x2;
            float x = 10.0 + i * (self.showView.frame.size.width - 20) / d;
            float y = self.showView.frame.size.height/2.0f+ (self.showView.frame.size.height*0.5) * (w > 32767.0?32767.0:w) / 32767.0 ;
            NSValue *pValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
            [dataArr addObject:pValue];
        }
    }
    CFRelease(blockBuffer);
    self.m_pointWavArray = [NSMutableArray arrayWithArray:dataArr];

}




@end
