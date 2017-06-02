//
//  JHAudioRecorder.m
//  FFTDemo
//
//  Created by sensology on 2017/4/24.
//  Copyright © 2017年 智觅智能. All rights reserved.
//

#import "JHAudioRecorder.h"
#import "lame.h"

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth  [[UIScreen mainScreen] bounds].size.width

@interface JHAudioRecorder ()<AVCaptureAudioDataOutputSampleBufferDelegate>{
    
    NSString*  nowTempPath;
    NSTimer *checkTime;
    NSMutableArray *pointArr;
    float viewWidth;
    float viewHeight;
}

@end

@implementation JHAudioRecorder


static JHAudioRecorder *shareAudioRecorder = nil;

+ (JHAudioRecorder *)shareAudioRecorder
{
    
    @synchronized(self)
    {
        if (shareAudioRecorder == nil)
        {
            shareAudioRecorder = [[self alloc] init];
        }
    }
    
    return shareAudioRecorder;
}


#pragma mark 录音

- (BOOL)startRecording{
    
    NSLog(@"startRecording");
    
    if (self.audioRecorder) {
        
        if ([self.audioRecorder isRecording]) {
            [self.audioRecorder stop];
        }
        self.audioRecorder = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];

    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10
                                           ];
    [recordSettings
     setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];//ID
    
    [recordSettings setObject:[NSNumber numberWithFloat:
                               11025.0] forKey: AVSampleRateKey];//采样率
    
    [recordSettings setObject:[NSNumber numberWithInt:
                               2] forKey:AVNumberOfChannelsKey];//通道的数目,1单声道,2立体声
    
    [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityMin] forKey: AVEncoderAudioQualityKey];
    nowTempPath = [
                   self filePathWithName:@"recordTemp" andType:[NSString stringWithFormat:@"%d",(int
                                                                                                 )[[NSDate date] timeIntervalSince1970]]];
    NSURL *url = [NSURL fileURLWithPath:nowTempPath];
    NSError *error = nil;
    
    
    self.audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    
    if ([self
         .audioRecorder prepareToRecord]){
        
        self.audioRecorder.meteringEnabled = YES
        ;
        
        self.audioRecorder.delegate = self
        ;
        
        return [self.audioRecorder record];
    }
    else
    {
        
        int errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(
              @"Error: %@ [%4.4s])" , [error localizedDescription], (char
                                                                     *)&errorCode);
        
        return NO;
    }
}

- (void)initAudioWithWidth:(float)width andHeight:(float)height{
    
    viewWidth  = width;
    viewHeight = height;
    _captureSession = [[AVCaptureSession alloc]init];
    
    NSError *error = nil;
    AVCaptureDevice *audioDev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc]initWithDevice:audioDev error:&error];
    
    if ([_captureSession canAddInput:audioIn]) {
        [_captureSession addInput:audioIn];
    }
    
    _captureAudioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    
    if([_captureSession canAddOutput:_captureAudioDataOutput]) {
        
        [_captureSession addOutput:_captureAudioDataOutput];
        //指定代理 增加线程
        dispatch_queue_t queue = dispatch_queue_create("myQueue",DISPATCH_QUEUE_CONCURRENT);
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
            float x = 10.0 + i * (viewWidth - 20) / d;
            NSLog(@"w = %i",w);//波形高度
            
            //            if (w < 100&&w>-100) { //去小声音
            //                w = 0;
            //            }
            //            float height = (self.showView.frame.size.height*0.5) *( (w > 32767.0?32767.0:w) / 32767.0);
            //
            //            float y = self.showView.frame.size.height/2.0f+ (height>self.showView.frame.size.height/2.0f?self.showView.frame.size.height/2.0f:height) ;
            
            float y = viewHeight/2.0f+ (viewHeight*0.5) * (w > 32767.0?32767.0:w) / 32767.0 ;
            NSValue *pValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
            [dataArr addObject:pValue];
        }
    }
    
    CFRelease(blockBuffer);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(reloadOutValueWithArr:)]) {
        [self.delegate reloadOutValueWithArr:dataArr];
    }
    //    self.pointArr = [NSMutableArray arrayWithArray:dataArr];
}




- (void)stopRecording{
    [self.audioRecorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    if (flag) {
        if (nowTempPath) {
            [self audio_PCMtoMP3WithPath:nowTempPath];
        }
    }
}

- (BOOL)isRecording{
    
    if (self.audioRecorder&&[self.audioRecorder isRecording]) {
        
        return YES;
    }
    else
    {
        return NO;
    }
}








#pragma mark 播放


- (void)playRecordingWith:(NSString *)filePath{
    
    NSLog(@"playRecording");
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSError *error;
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.numberOfLoops = 0;
    self.audioPlayer.meteringEnabled = YES;
    [self.audioPlayer play];
    [self startCheck];
}

- (void)startCheck{
    if (!checkTime) {
        pointArr = [[NSMutableArray alloc]init];
        checkTime = [NSTimer scheduledTimerWithTimeInterval:1.0/5000.0 target:self selector:@selector(checkRecordValueWithTime:) userInfo:nil repeats:YES];
    }
}

- (void)checkRecordValueWithTime:(NSTimer *)time{
    
    [self.audioPlayer updateMeters];
    float peakPower = [self.audioPlayer averagePowerForChannel:1];
    double peakPowerForChannel = pow(10, (0.05 * peakPower));
    [pointArr addObject:[NSNumber numberWithDouble:peakPowerForChannel]];
    
    if ([pointArr count] >= 100) {
        //        [pointArr removeObjectAtIndex:0];
        NSArray *tempArr = [[NSArray alloc ]initWithArray:pointArr];
        [pointArr removeAllObjects];
        if (self.delegate&&[self.delegate respondsToSelector:@selector(reloadValueWithArr:)]) {
            [self.delegate reloadValueWithArr:tempArr];
        }
    }
    
    
}

- (void)stopCheck{
    if (checkTime) {
        [checkTime invalidate];
        checkTime = nil;
    }
}

- (void)stopPlaying{
    NSLog(@"stopPlaying");
    
    if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
    [self stopCheck];
}

- (NSString *)filePathWithName:(NSString *)recorderName andType:(NSString *)type{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,
                                                         YES
                                                         );
    NSString *path = [paths  objectAtIndex:
                      0
                      ];
    NSString *account = @"yinyue";
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:
                                                               @"/sens/%@/recorder/"
                                                               ,account]];
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if
        (![fm fileExistsAtPath:filePath]) {
            [fm createDirectoryAtPath:filePath withIntermediateDirectories:
             YES attributes:nil error:nil
             ];
        }
    NSString *filename = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:
                                                                   @"%@%@"
                                                                   ,recorderName,type]];
    
    return
    filename;
}

- (void)audio_PCMtoMP3WithPath:(NSString *)recordcafPath{
    NSString *cafFilePath = recordcafPath;
    NSString *recordmp3Path = [
                               self filePathWithName:[NSString stringWithFormat:@"recorder%d",(int)[[NSDate date] timeIntervalSince1970]] andType:@".mp3"
                               ];
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    if([fileManager removeItemAtPath:recordmp3Path error:nil
        ])
    {
        NSLog(
              @"删除"
              );
    }
    
    @try
    {
        
        int
        read, write;
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:
                           1], "rb");  //source 被转换的音频文件位置
        
        fseek(pcm,
              4*1024, SEEK_CUR);                                   //skip file header
        
        FILE *mp3 = fopen([recordmp3Path cStringUsingEncoding:
                           1], "wb");  //output 输出生成的Mp3文件位置
        
        
        const int PCM_SIZE = 8192
        ;
        
        const int MP3_SIZE = 8192
        ;
        
        short int pcm_buffer[PCM_SIZE*2
                             ];
        
        unsigned char
        mp3_buffer[MP3_SIZE];
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame,
                               11025.0
                               );
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do
        {
            read = fread(pcm_buffer,
                         2*sizeof(short int
                                  ), PCM_SIZE, pcm);
            
            if (read == 0
                )
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            
            else
                
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            fwrite(mp3_buffer, write,
                   1
                   , mp3);
        }
        while (read != 0
               );
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    
    @catch
    (NSException *exception) {
        NSLog(
              @"%@"
              ,[exception description]);
    }
    
    @finally
    {
        NSLog(
              @"recordmp3Path  = %@"
              , recordmp3Path );
        
    }
}


@end
