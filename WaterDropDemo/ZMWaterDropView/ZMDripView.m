//
//  ZMDripView.m
//  WaterDropDemo
//
//  Created by 钱长存 on 9/7/15.
//  Copyright (c) 2015 com.zmodo. All rights reserved.
//

#import "ZMDripView.h"

@interface ZMDripView ()

@end


@implementation ZMDripView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, self.bounds.size.width * 0.5f, 0);
    
    [[UIColor whiteColor] set];
    CGContextSetLineWidth(context, 1.0);
    
    CGContextAddCurveToPoint(context,
                             0,
                             self.bounds.size.height,
                             self.bounds.size.width,
                             self.bounds.size.height,
                             self.bounds.size.width * 0.5f,
                             0);
    
    CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
    CGContextFillPath(context);
    
    CGContextStrokePath(context);
    
}
@end
