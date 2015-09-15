//
//  ZMWaterDropView.m
//  WaterDropDemo
//
//  Created by 钱长存 on 9/7/15.
//  Copyright (c) 2015 com.zmodo. All rights reserved.
//

#import "ZMWaterDropView.h"
#import "ZMWaterWaveView.h"
#import "ZMDripView.h"

@interface ZMWaterDropView () <UICollectionViewDelegate>
{
    NSTimer *_dropTimer;
}
@property (strong, nonatomic) ZMWaterWaveView *waveView;
@property (strong, nonatomic) ZMDripView *dripView;
@property (strong, nonatomic) UIView *barrierLine;
@property (strong, nonatomic) UIDynamicAnimator *animator;

@end

@implementation ZMWaterDropView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self awakeFromNib];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.waveView = [[ZMWaterWaveView alloc] initWithFrame:CGRectZero];
    [self addSubview:_waveView];
    
    self.dripView = [[ZMDripView alloc] initWithFrame:CGRectZero];
    
    [self addSubview:_dripView];
    
    
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    
    self.barrierLine = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self addSubview:_barrierLine];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const float waveViewWidth = 150.0f;
    const float waveViewHeight = 150.0f;
    
    [_waveView setFrame:CGRectMake((self.bounds.size.width - waveViewWidth) * 0.5f,
                                   self.bounds.size.height - waveViewHeight,
                                   waveViewWidth,
                                   waveViewHeight)];
    
    _waveView.layer.cornerRadius = waveViewWidth * 0.5f;
    _waveView.layer.borderWidth = 0.5f;
    _waveView.layer.borderColor = [UIColor colorWithRed:80.0f/255
                                                  green:80.0f/255
                                                   blue:80.0f/255
                                                  alpha:1.0f].CGColor;
    
    _waveView.backgroundColor = [UIColor colorWithRed:80.0f/255
                                                green:80.0f/255
                                                 blue:80.0f/255
                                                alpha:1.0f];
    _waveView.clipsToBounds = YES;
    
    CGFloat dripViewWidth = 100.0f;
    CGFloat dripViewHeight = 50.0f;

    [_dripView setFrame:CGRectMake((self.bounds.size.width - dripViewWidth) * 0.5f,
                                   -dripViewHeight,
                                   dripViewWidth,
                                   dripViewHeight)];
    
    _barrierLine.frame = CGRectMake(0,
                                    self.bounds.size.height - waveViewHeight * 0.5f + 40.0f,
                                    self.bounds.size.width,
                                    1);
}


- (void)startDrop
{
    [self stopDrop];

    _dropTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                  target:self
                                                selector:@selector(resetDrop)
                                                userInfo:nil
                                                 repeats:YES];
    
    [self resetDrop];
    [_waveView startWave];

}

- (void)stopDrop
{
    if (_dropTimer) {
        [_dropTimer invalidate];
        _dropTimer = nil;
    }
    
    [_waveView stopSplashWater];
    [_waveView stopWave];
}

- (void)resetDrop
{

    [_dripView setFrame:CGRectMake((self.bounds.size.width - _dripView.bounds.size.width) * 0.5f,
                                   20,
                                   _dripView.bounds.size.width,
                                   _dripView.bounds.size.height)];
    [self addSubview:_dripView];

    [self resetBeahviors];
}

- (void)resetBeahviors
{
    [_animator removeAllBehaviors];
    
    UIGravityBehavior *gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:@[_dripView]];
    [_animator addBehavior:gravityBeahvior];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[_dripView]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = NO;
    
    CGPoint rightEdge = CGPointMake(_barrierLine.frame.origin.x + _barrierLine.frame.size.width,
                                    _barrierLine.frame.origin.y);
    
    [collisionBehavior addBoundaryWithIdentifier:@"barrier"
                                fromPoint:_barrierLine.frame.origin
                                  toPoint:rightEdge];
    collisionBehavior.collisionDelegate = (id)self;
    [_animator addBehavior:collisionBehavior];

    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[_dripView, _barrierLine]];
    itemBehaviour.elasticity = 0.0;
    [_animator addBehavior:itemBehaviour];
    
    
}

#pragma mark - Collection delegate

- (void)collisionBehavior:(UICollisionBehavior*)behavior
      endedContactForItem:(id <UIDynamicItem>)item
   withBoundaryIdentifier:(id <NSCopying>)identifier
{
    [_animator removeAllBehaviors];
    
    [_dripView removeFromSuperview];
    [_waveView splashWater];
}

@end
