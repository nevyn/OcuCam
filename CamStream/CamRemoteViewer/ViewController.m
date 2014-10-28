//
//  ViewController.m
//  CamRemoteViewer
//
//  Created by Joachim Bengtsson on 2014-10-28.
//  Copyright (c) 2014 Thirdcog. All rights reserved.
//

#import "ViewController.h"
#import "TCAHPSimpleClient.h"

@interface ViewController () <TCAsyncHashProtocolDelegate>
{
	TCAHPSimpleClient *_client;
}
@property(nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_client = [[TCAHPSimpleClient alloc] initConnectingToAnyHostOfType:@"_vidya._tcp" delegate:self];
	[_client reconnect];
}

-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash payload:(NSData*)payload;
{
	NSData *data = hash[@"image"];
	UIImage *image = [UIImage imageWithData:data];
	_imageView.image = image;
}

@end
