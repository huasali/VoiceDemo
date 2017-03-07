//
//  ShowView.m
//  FFTDemo
//
//  Created by sensology on 2016/11/2.
//  Copyright © 2016年 智觅智能. All rights reserved.
//

#import "ShowView.h"

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth  [[UIScreen mainScreen] bounds].size.width

@implementation ShowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _pointArr = [[NSMutableArray alloc]init];
        self.backgroundColor = [UIColor whiteColor];

    }
    return self;
}

//柱形
//-(void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    if (!self.pointArr||[self.pointArr count] == 0) {
//        return;
//    }
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [[UIColor blueColor] setStroke];
//    CGContextSetLineWidth(context, 1.0);
//    //    CGContextMoveToPoint(context, self.frame.size.width - 10, 20);
//    //    CGContextAddLineToPoint(context, 10, 20);
//    //    CGContextAddLineToPoint(context, 10, self.frame.size.height/2.0);
//    // CGContextStrokePath(context);
//    CGFloat height = self.frame.size.height;
//    
//    CGContextMoveToPoint(context, 10, height/2.0);
//    CGPoint prePoint = CGPointMake(10.0, 0.0);
//    [[UIColor blackColor] setStroke];
//    CGContextSetLineWidth(context, 1.0);
//    for (int i = 0; i < [self.pointArr count]; i++) {
//        CGPoint point = [self.pointArr[i] CGPointValue];
//        
//        if (i%10 == 0) {
//            
//            CGContextAddLineToPoint(context, prePoint.x, point.y);
//            CGContextAddLineToPoint(context, point.x, point.y);
//            CGContextStrokePath(context);
//            
//            CGContextMoveToPoint(context, prePoint.x,prePoint.y);
//            CGContextAddLineToPoint(context, prePoint.x, point.y);
//            CGContextAddLineToPoint(context, point.x, point.y);
//            if (i > 765) {
//                [[UIColor colorWithRed:(255 -(i - 765))/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] setFill];
//            }
//            else{
//                [[UIColor colorWithRed:(i<255?i:255.0)/255.0 green:((i>255)?((i-255)>255?255:(i-255)):0.0)/255.0 blue:(i>510?(i - 510):0.0)/255.0 alpha:1.0] setFill];
//            }
//            CGContextAddLineToPoint(context, point.x, height);
//            CGContextAddLineToPoint(context, prePoint.x, height);
//            CGContextFillPath(context);
//            CGContextMoveToPoint(context, point.x,point.y);
//            prePoint = point;
//        }
//        
//        
//        
//        
//    }
//    [[UIColor blueColor] setStroke];
//    
//    CGContextSetLineWidth(context, 1.0);
//    CGContextAddLineToPoint(context, ScreenWidth - 10, self.frame.size.height/2.0);
//    CGContextAddLineToPoint(context, ScreenWidth - 10, height);
//    CGContextAddLineToPoint(context, 10, height);
//    CGContextAddLineToPoint(context, 10, self.frame.size.height/2.0);
//    CGContextStrokePath(context);
//}

//波形
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (!self.pointArr) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blueColor] setStroke];
    CGContextSetLineWidth(context, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, self.frame.size.height/2.0);
    for (int i = 0; i < [self.pointArr count]; i++) {
        CGPoint point = [self.pointArr[i] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextAddLineToPoint(context, ScreenWidth, self.frame.size.height/2.0);
    CGContextStrokePath(context);
}



@end
