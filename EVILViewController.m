//
//  EVILViewController.m
//  CylonicCA
//
//  Created by Joachim Bengtsson on 2013-11-02.
//  Copyright (c) 2013 Joachim Bengtsson. All rights reserved.
//

#import "EVILViewController.h"

@interface EVILViewController ()
@property(nonatomic) EVILLayer *evil;
@end

@implementation EVILViewController
- (void)moveEyeTo:(CGFloat)p animated:(BOOL)animated
{
	[self.evil moveEyeTo:p*self.evil.frame.size.width animated:animated];
}
- (void)animateEye
{
	[self.evil animateEye];
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad
{
    _evil = [[EVILLayer alloc] init];
    _evil.frame = self.view.bounds;
    [self.view.layer addSublayer:_evil];
}

- (void)viewDidLayoutSubviews
{
    [_evil setFrame:self.view.bounds];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_evil moveEyeTo:[[touches anyObject] locationInView:self.view].x animated:YES];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_evil moveEyeTo:[[touches anyObject] locationInView:self.view].x animated:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_evil animateEye];
}

@end
