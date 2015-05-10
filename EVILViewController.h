//
//  EVILViewController.h
//  CylonicCA
//
//  Created by Joachim Bengtsson on 2013-11-02.
//  Copyright (c) 2013 Joachim Bengtsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVILLayer.h"

@interface EVILViewController : UIViewController
// 0,0-1,0
- (void)moveEyeTo:(CGFloat)p animated:(BOOL)animated;
- (void)animateEye;
@end
