#import "ViewController.h"
#import "TCAHPSimpleServer.h"
@import AVFoundation;


@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoDataOutput *_videoOutput;
    AVCaptureVideoPreviewLayer *_preview;
	dispatch_queue_t _processingQueue;
	NSTimeInterval _lastFrame;
	TCAHPSimpleServer *_server;
}

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSError *err;
	_server = [[TCAHPSimpleServer alloc] initOnBasePort:14568 serviceType:@"_vidya._tcp" serviceName:@"" delegate:nil error:&err];
	if(!_server)
		NSLog(@"Server err: %@", err);

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
	
	// 3. Output
	
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    _videoOutput.alwaysDiscardsLateVideoFrames = YES;
    _videoOutput.videoSettings = @{
        (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
    };
     _processingQueue = dispatch_queue_create("lulzcamera", DISPATCH_QUEUE_SERIAL);
    [_videoOutput setSampleBufferDelegate:self queue:_processingQueue];

	
	CGRect r = self.view.bounds;
	
	if(_videoInput) {
		// 4. Configure
		[_captureSession beginConfiguration];
			_captureSession.sessionPreset = AVCaptureSessionPresetMedium;
			[_captureSession addInput:_videoInput];
			[_captureSession addOutput:_videoOutput];
		[_captureSession commitConfiguration];
		
		/*NSError *err;
		if([_device lockForConfiguration:&err]) {
			_device.activeVideoMinFrameDuration = CMTimeMakeWithSeconds(0.5, 1000);
			[_device unlockForConfiguration];
		} else {
			NSLog(@"Bawww: %@", err);
		}*/


		// 5. Run!
		[_captureSession startRunning];
		
		_preview = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
		_preview.frame = r;
	}
	
	[self.view.layer addSublayer:_preview];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	if(now - _lastFrame < 0.1) {
		return;
	}
	_lastFrame = now;
	
	
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    CVPixelBufferLockBaseAddress(imageBuffer,0);
	
	// Fetch sample buffer from camera into a CGImage that we can work with.
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bpr = CVPixelBufferGetBytesPerRow(imageBuffer);
    CGSize size = CGSizeMake(CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef cameraContext = CGBitmapContextCreate(baseAddress, size.width, size.height, 8, bpr, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef misalignedImage = CGBitmapContextCreateImage(cameraContext);

	// The CGImage is incorrectly rotated and wrong aspect ratio. Make a new target bitmap context and fix all the
	// transformation problems.
	CGContextRef rotatedContext = CGBitmapContextCreate(NULL, size.height, size.width, 8, size.height*4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
	CGContextRotateCTM(rotatedContext, -M_PI_2);
	CGContextTranslateCTM(rotatedContext, -size.width, 0);
	CGContextScaleCTM(rotatedContext, size.width/size.height, size.height/size.width);
	CGContextDrawImage(rotatedContext, CGRectMake(0, 0, size.height, size.width), misalignedImage);
	CGImageRelease(misalignedImage);
	
    CGImageRef cgImage = CGBitmapContextCreateImage(rotatedContext);
	CGContextRelease(rotatedContext);

    CGContextRelease(cameraContext);
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
	// Finally, write it as a JPEG to disk.
	UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
	NSData *imageData = UIImageJPEGRepresentation(uiImage, 0.2);
	CGImageRelease(cgImage);
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[_server broadcast:@{
			@"image": imageData,
		}];
	});
}

@end
