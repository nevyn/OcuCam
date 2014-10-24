//
//  EVILViewController.m
//  CylonicCA
//
//  Created by Joachim Bengtsson on 2013-11-02.
//  Copyright (c) 2013 Joachim Bengtsson. All rights reserved.
//

#import "EVILViewController.h"
#import "EVILLayer.h"

@implementation EVILViewController
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad
{
    EVILLayer *layer = [[EVILLayer alloc] init];
    layer.frame = self.view.bounds;
    [self.view.layer addSublayer:layer];
}

- (void)viewDidLayoutSubviews
{
    [self.view.layer.sublayers[0] setFrame:self.view.bounds];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view.layer.sublayers[0] moveEyeTo:[[touches anyObject] locationInView:self.view].x animated:YES];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view.layer.sublayers[0] moveEyeTo:[[touches anyObject] locationInView:self.view].x animated:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view.layer.sublayers[0] animateEye];
}

@end
