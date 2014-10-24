//
//  EVILLayer.h
//  CylonicCA
//
//  Created by Joachim Bengtsson on 2013-11-02.
//  Copyright (c) 2013 Joachim Bengtsson. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface EVILLayer : CALayer
- (void)moveEyeTo:(CGFloat)p animated:(BOOL)animated;
- (void)animateEye;
@end
