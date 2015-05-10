//
//  ExtVC.m
//  OcuCam
//
//  Created by Joachim Bengtsson on 2014-10-24.
//  Copyright (c) 2014 Thirdcog. All rights reserved.
//

#import "ExtVC.h"
#import <AVFoundation/AVFoundation.h>
#import "OcuCam-Swift.h"

@interface ExtVC ()

@end

@implementation ExtVC
{
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoPreviewLayer *_preview;
    CAReplicatorLayer *_replicator;
	float _eyeSeparation;
	CALayer *_remoteImageLayer;
	CATextLayer *_text;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	_eyeSeparation = [[NSUserDefaults standardUserDefaults] floatForKey:@"sep"];
	
	self.view.backgroundColor = [UIColor darkGrayColor];
	
	_captureSession = [AVCaptureSession new];
    
    // 1. Choose device
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
        if(device.position == AVCaptureDevicePositionFront)
            _device = device;
	
    if(!_device) {
		NSLog(@"Aww no device");
		self.view.backgroundColor = [UIColor redColor];
    }
    
    // 2. Input
	NSError *error = nil;
	_videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_device error:&error];
    if(!_videoInput || ![_captureSession canAddInput:_videoInput]) {
        NSLog(@"-[[AVCaptureDeviceInput alloc] initWithDevice:error:]: %@", error);
		self.view.backgroundColor = [UIColor redColor];
    }
	
	CGRect r = self.view.bounds;
	r.size.width /= 2;
	
	if(_videoInput) {
		// 4. Configure
		[_captureSession beginConfiguration];
			_captureSession.sessionPreset = AVCaptureSessionPresetMedium;
			[_captureSession addInput:_videoInput];
		[_captureSession commitConfiguration];

		// 5. Run!
		[_captureSession startRunning];
		
		_preview = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
		_preview.frame = r;
		_preview.orientation = [UIApplication sharedApplication].statusBarOrientation;
		_preview.automaticallyAdjustsMirroring = NO;
		_preview.mirrored = NO;
	}
	
	_replicator = [CAReplicatorLayer layer];
	_replicator.frame = self.view.bounds;
	_replicator.instanceCount = 2;
	[self adjustTransform];
	if(_preview)
		[_replicator addSublayer:_preview];
	OcuHUDLayer *hud = [[OcuHUDLayer alloc] initWithFrame:r];
	[_replicator addSublayer:hud];
	
	_remoteImageLayer = [[CALayer alloc] init];
	_remoteImageLayer.frame = CGRectMake(400, 150, 120, 100);
	_remoteImageLayer.backgroundColor = [UIColor greenColor].CGColor;
	[_replicator addSublayer:_remoteImageLayer];
	
	_text = [[CATextLayer alloc] init];
	_text.fontSize = 24;
	CGFontRef font = CGFontCreateWithFontName((CFStringRef)@"HelveticaNeue-Regular");
	_text.font = font;
	_text.string = @"hello";
	_text.frame = CGRectMake(self.view.frame.size.width/4, self.view.frame.size.height/2, 100, 100);
	_text.foregroundColor = [UIColor whiteColor].CGColor;
	[_text display];
	[_replicator addSublayer:_text];
	
	
	[self.view.layer addSublayer:_replicator];
	[hud addAnimations];
}

- (void)a
{
	_eyeSeparation += 1;
	[[NSUserDefaults standardUserDefaults] setFloat:_eyeSeparation forKey:@"sep"];
	[self adjustTransform];
}
- (void)b
{
	_eyeSeparation -= 1;
	[[NSUserDefaults standardUserDefaults] setFloat:_eyeSeparation forKey:@"sep"];
	[self adjustTransform];
}
- (void)adjustTransform
{
	CGRect r = self.view.bounds;
	r.size.width /= 2;
	_replicator.instanceTransform = CATransform3DMakeTranslation(r.size.width + _eyeSeparation, 0, 0.0);
	NSLog(@"Separation: %f", _eyeSeparation);
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
    [_preview removeFromSuperlayer];
	[_captureSession stopRunning];
}

- (void)setRemoteImage:(UIImage*)image
{
	_remoteImageLayer.contents = (id)image.CGImage;
}

- (void)addMessage:(NSString*)message
{
	_text.string = message;
}


@end
