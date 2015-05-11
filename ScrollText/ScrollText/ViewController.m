//
//  ViewController.m
//  ScrollText
//
//  Created by Nevyn Bengtsson on 2015-05-10.
//  Copyright (c) 2015 ThirdCog. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
	NSString *s;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	s = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"foo" ofType:@"txt" inDirectory:nil] encoding:NSUTF8StringEncoding error:nil];
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(foo) userInfo:nil repeats:YES];
}

- (void)foo
{
	int start = arc4random_uniform(s.length);
	NSRange r = NSMakeRange(start, MIN(s.length-start, 2000));
	_tx.text = [s substringWithRange:r];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
