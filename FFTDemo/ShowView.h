//
//  ShowView.h
//  FFTDemo
//
//  Created by sensology on 2016/11/2.
//  Copyright © 2016年 智觅智能. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kMaxKeyPoints  1000
#define kHillSegmentWidth 10


@interface ShowView : UIView
{
    CGPoint m_pSonogramKeyPoint[kMaxKeyPoints];
}






@property (assign ,nonatomic) float m_pOffsetX;
@property (assign ,nonatomic) int m_pSonogramKeyPointNum;
//转换后的座标数据，用于绘制波形图
@property (atomic, strong) NSMutableArray *m_pointWavArray;


@end
