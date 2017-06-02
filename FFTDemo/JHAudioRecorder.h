//
//  JHAudioRecorder.h
//  FFTDemo
//
//  Created by sensology on 2017/4/24.
//  Copyright © 2017年 智觅智能. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@protocol JHAudioRecordDelegate <NSObject>

- (void)reloadValueWithArr:(NSArray *)valueArr;
- (void)reloadOutValueWithArr:(NSArray *)valueArr;

@end

@interface JHAudioRecorder : NSObject<AVAudioRecorderDelegate>

+ (JHAudioRecorder *)shareAudioRecorder;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, weak) id <JHAudioRecordDelegate> delegate;

@property(strong,nonatomic) AVCaptureSession *captureSession;//数据传递
@property(strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//输入数据
@property(strong,nonatomic) AVCaptureAudioDataOutput *captureAudioDataOutput;//视频输出

- (void)initAudioWithWidth:(float)width andHeight:(float)height;

- (BOOL)startRecording;

- (void)stopRecording;

- (void)playRecordingWith:(NSString *)filePath;

- (void)stopPlaying;

- (BOOL)isRecording;


@end
