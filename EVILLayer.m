//
//  EVILLayer.m
//  CylonicCA
//
//  Created by Joachim Bengtsson on 2013-11-02.
//  Copyright (c) 2013 Joachim Bengtsson. All rights reserved.
//

#import "EVILLayer.h"
@import AVFoundation;

@implementation EVILLayer
{
    CAGradientLayer *_slit;
    CALayer *_outerGlow;
    CALayer *_innerGlow;
    CALayer *_innerImage;
    AVPlayer *_swoosh;
    NSTimer *_swooshTimer;
}

- (id)init
{
    if(!(self = [super init]))
        return nil;
    
    _swoosh = [AVPlayer playerWithURL:[[NSBundle mainBundle] URLForResource:@"sounds/eye" withExtension:@"wav"]];
    
    [self performSelector:@selector(setup) withObject:nil afterDelay:0];
    
    return self;
}

- (void)setup
{
    _slit = [CAGradientLayer new];
    _slit.colors = @[
        (id)[UIColor colorWithRed:0.199 green:0.010 blue:0.033 alpha:1.000].CGColor,
        (id)[UIColor colorWithRed:0.663 green:0.000 blue:0.067 alpha:1.000].CGColor,
        (id)[UIColor colorWithRed:0.199 green:0.010 blue:0.033 alpha:1.000].CGColor,
    ];
    _slit.startPoint = CGPointMake(0, 0);
    _slit.endPoint = CGPointMake(1, 0);
    _slit.cornerRadius = 4;
    
    float h = 50;
    _slit.frame = CGRectMake(100, self.frame.size.height/2-h/2, self.frame.size.width-200, h);
    _slit.shadowColor = [UIColor colorWithRed:0.256 green:0.006 blue:0.038 alpha:1.000].CGColor;
    _slit.shadowOffset = CGSizeMake(0, 0);
    _slit.shadowRadius = 2;
    _slit.shadowOpacity = 0.6;
    
    _outerGlow = [CALayer new];
    _outerGlow.contents = (id)[UIImage imageNamed:@"OuterGlow"].CGImage;
    _outerGlow.bounds = CGRectMake(0, 0, 512, 512);
    _outerGlow.position = CGPointMake(_slit.frame.origin.x+50, self.frame.size.height/2);
    
    _innerGlow = [CALayer new];
    _innerGlow.frame = _slit.frame;
    _innerGlow.cornerRadius = 4;
    _innerGlow.masksToBounds = YES;
    _innerImage = [CALayer new];
    _innerImage.contents = (id)[UIImage imageNamed:@"InnerGlow"].CGImage;
    _innerImage.bounds = CGRectMake(0, 0, 512, 512);
    _innerImage.position = CGPointMake(50, _innerGlow.frame.size.height/2);
    [_innerGlow addSublayer:_innerImage];
    
    [self addSublayer:_outerGlow];
    [self addSublayer:_slit];
    [self addSublayer:_innerGlow];
    
    [self animateEye];
}

- (void)moveEyeTo:(CGFloat)p animated:(BOOL)animated;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_swooshTimer invalidate];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    anim.fromValue = @([(CALayer*)_innerImage.presentationLayer position].x);
    anim.toValue = @(p - _innerGlow.frame.origin.x);
    anim.duration = animated ? 0.2 : 0.01;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;

    [_innerImage addAnimation:anim forKey:@"sweep"];
    
    anim.fromValue = @([(CALayer*)_outerGlow.presentationLayer position].x);
    anim.toValue = @(p);
    
    [_outerGlow addAnimation:anim forKey:@"sweep"];
}

- (void)animateEye
{
    [self moveEyeTo:120 animated:YES];
    [self performSelector:@selector(animateEye2) withObject:Nil afterDelay:0.2];
}

static const float duration = 2.2;

- (void)animateEye2
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    anim.byValue = @(_innerGlow.frame.size.width-100);
    anim.duration = duration;
    anim.repeatCount = 1e100;
    anim.autoreverses = YES;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self performSelector:@selector(startSwoosh) withObject:nil afterDelay:0.4];
    
    [_innerImage addAnimation:anim forKey:@"sweep"];
    [_outerGlow addAnimation:anim forKey:@"sweep"];
}

- (void)startSwoosh
{
    [self swoosh];
    [_swooshTimer invalidate];
    _swooshTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(swoosh) userInfo:nil repeats:YES];
}

- (void)swoosh
{
    [_swoosh seekToTime:CMTimeMake(0, 1)];
    [_swoosh play];
}

@end
