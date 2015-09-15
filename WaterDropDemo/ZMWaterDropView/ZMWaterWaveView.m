//
//  ZMWaterWaveView.m
//  WaterDropDemo
//
//  Created by 钱长存 on 9/7/15.
//  Copyright (c) 2015 com.zmodo. All rights reserved.
//

#define kDripCount          7     // 水滴总数

#import "ZMWaterWaveView.h"

@interface ZMWaterWaveView ()
{
    
    CADisplayLink *_frameTimer;
    
    CGFloat _waveSpeed;

    CGFloat _waveWidth;
    CGFloat _offsetX;
    
    CGFloat _variable;
    BOOL _increase;

    
}
@property (strong, nonatomic) NSMutableArray *dripLayers;
@property (strong, nonatomic) NSMutableArray *waveLayers;

@end

@implementation ZMWaterWaveView



#pragma mark - Splash water
- (void)splashWater
{
    if (!_dripLayers) {
        _dripLayers = [[NSMutableArray alloc] initWithCapacity:kDripCount];
        
        for (int i = 0; i < kDripCount; i++) {
            
            CALayer *dripLayer = [CALayer layer];
            [_dripLayers addObject:dripLayer];
            
        }
    }
    
    for (int i = 0; i < kDripCount; i++) {
        
        [self performSelector:@selector(addAnimationToDrip:) withObject:_dripLayers[i] afterDelay:i * 0.01];
    }
    
}

- (void)stopSplashWater
{
    [_dripLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeAllAnimations];
        [obj removeFromSuperlayer];
    }];
}

- (void)addAnimationToDrip:(CALayer *)dripLayer
{
    CGFloat width = arc4random() % 15 + 1;
    dripLayer.frame = CGRectMake((self.bounds.size.width - width)* 0.5f, self.bounds.size.height * 0.5f + 40, width, width);
    dripLayer.cornerRadius = dripLayer.frame.size.width * 0.5f;
    dripLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    [self.layer addSublayer:dripLayer];
    
    CGFloat x3 = arc4random() % ((int)self.bounds.size.width) + 1;
    CGFloat y3 = self.bounds.size.height * 0.5f + 40;
    
    CGFloat height = arc4random() % ((int)(self.bounds.size.height * 0.5f));
    
    [self throwDrip:dripLayer
               from:dripLayer.position
                 to:CGPointMake(x3, y3)
             height:height
           duration:0.7f];
}

- (void)throwDrip:(CALayer *)drip
             from:(CGPoint)start
               to:(CGPoint)end
           height:(CGFloat)height
         duration:(CGFloat)duration
{
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, start.x, start.y);
    CGPathAddQuadCurveToPoint(path, NULL, (end.x + start.x) * 0.5f, -height, end.x, end.y);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setPath:path];
    animation.duration = duration;
    CFRelease(path);
    path = nil;
    
    [drip addAnimation:animation forKey:@"position"];
    
}


#pragma mark - Animation did stop

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        [self stopSplashWater];
    }
}

#pragma mark - Wave


- (void)startWave
{
    [self stopWave];
    
    _waveWidth = self.bounds.size.width;
    _variable = 1.6;
    _increase = NO;
    
    _offsetX = 0;
    
    [self loadWaveLayers];
    
    _frameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateVibrations:)];
    _frameTimer.frameInterval = 2;
    [_frameTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    
}

- (void)loadWaveLayers
{
    
    if (!_waveLayers) {
        
        self.waveLayers = [[NSMutableArray alloc] initWithCapacity:3];
        
        UIColor *whiteColor = [UIColor whiteColor];
        UIColor *lightGrayColor = [UIColor colorWithRed:207/255.0f
                                                  green:207/255.0f
                                                   blue:207/255.0f
                                                  alpha:1.0f];
        UIColor *darkGrayColor = [UIColor colorWithRed:159/255.0f
                                                 green:159/255.0f
                                                  blue:159/255.0f
                                                 alpha:1.0f];
        
        NSArray *colors = @[darkGrayColor, lightGrayColor, whiteColor];
        
        for (int i = 0; i < 3; ++i) {
            CAShapeLayer *waveLayer = [CAShapeLayer layer];
            waveLayer.fillColor = ((UIColor *)colors[i]).CGColor;
            [self.layer addSublayer:waveLayer];
            
            [_waveLayers addObject:waveLayer];
        }
    }


}

- (void)stopWave
{
    if (_frameTimer) {
        [_frameTimer invalidate];
        _frameTimer = nil;
    }
    
    if (_waveLayers && [_waveLayers count] > 0) {
        [_waveLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj removeFromSuperlayer];
        }];
        
        _waveLayers = nil;
    }

}


- (void)updateVibrations:(CADisplayLink *)displayLink
{
    if (_increase) {
        _variable += 1 / 30.0f;
    }else{
        _variable -= 1 / 30.0f;
    }
    
    if (_variable <= 1) {
        _increase = YES;
    }
    
    if (_variable >= 1.6) {
        _increase = NO;
    }
    
    _offsetX += _waveSpeed;
    
    [self drawWaveWithLayer:_waveLayers[0] amplitude:_variable * 3 waveCycle:1.5* M_PI / _waveWidth offsetY:20.0f];    // dark
    [self drawWaveWithLayer:_waveLayers[1] amplitude:_variable * 5 waveCycle:1.1 * M_PI / _waveWidth offsetY:22.0f];   // light
    [self drawWaveWithLayer:_waveLayers[2] amplitude:_variable * 10 waveCycle:1 * M_PI / _waveWidth offsetY:22.0f];    // white

}

- (void)drawWaveWithLayer:(CAShapeLayer *)waveLayer
                amplitude:(CGFloat)amplitude
                waveCycle:(CGFloat)waveCycle
                  offsetY:(CGFloat)offsetY
{
        CGMutablePathRef path = CGPathCreateMutable();
        CGFloat y = self.bounds.size.height * 0.5f;
        CGPathMoveToPoint(path, nil, 0, y);
        
        for (float x = 0.0f; x <=  _waveWidth ; x++) {
            y = amplitude * sin(waveCycle * x + _offsetX) + self.frame.size.height * 0.5f + offsetY;   // 正弦波
            CGPathAddLineToPoint(path, nil, x, y);
        }
        
        CGPathAddLineToPoint(path, nil, _waveWidth, self.frame.size.height);
        CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
        CGPathCloseSubpath(path);
        
        waveLayer.path = path;
        CGPathRelease(path);
    
}


@end
