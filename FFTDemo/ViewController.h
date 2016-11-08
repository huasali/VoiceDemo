//
//  ViewController.h
//  FFTDemo
//
//  Created by sensology on 2016/11/2.
//  Copyright © 2016年 智觅智能. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController

@property(strong,nonatomic) AVCaptureSession *captureSession;//数据传递

@property(strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//输入数据

@property(strong,nonatomic) AVCaptureAudioDataOutput *captureAudioDataOutput;//视频输出
@property (weak, nonatomic) IBOutlet UIButton *wode;

@end

