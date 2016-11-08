//
//  ShowView.m
//  FFTDemo
//
//  Created by sensology on 2016/11/2.
//  Copyright © 2016年 智觅智能. All rights reserved.
//

#import "ShowView.h"

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

@implementation ShowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _m_pointWavArray = [[NSMutableArray alloc]init];
        self.backgroundColor = [UIColor whiteColor];

    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (!self.m_pointWavArray) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blueColor] setStroke];
    CGContextSetLineWidth(context, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, self.frame.size.height/2.0);
    for (int i = 0; i < [self.m_pointWavArray count]; i++) {
        CGPoint point = [self.m_pointWavArray[i] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextAddLineToPoint(context, ScreenWidth, self.frame.size.height/2.0);
    CGContextStrokePath(context);
}



@end
