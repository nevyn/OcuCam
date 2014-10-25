#import "AppDelegate.h"
#import "ExtVC.h"
#import "EVILViewController.h"

@import AVFoundation;
@import GameController;

@interface AppDelegate ()

@end

@interface Foo : EVILViewController
@property(nonatomic) IBOutlet UITextView *text;
@end
@implementation Foo
{
	AVPlayer *a, *b, *c, *d, *e;
}
- (void)viewDidLoad
{
	[super viewDidLoad];
	a = [AVPlayer playerWithURL:[[NSBundle mainBundle] URLForResource:@"sounds/by your command" withExtension:@"wav"]];
	b = [AVPlayer playerWithURL:[[NSBundle mainBundle] URLForResource:@"sounds/extermination" withExtension:@"wav"]];
	c = [AVPlayer playerWithURL:[[NSBundle mainBundle] URLForResource:@"sounds/fire weapons" withExtension:@"wav"]];
	d = [AVPlayer playerWithURL:[[NSBundle mainBundle] URLForResource:@"sounds/leave no survivors" withExtension:@"wav"]];
	e = [AVPlayer playerWithURL:[[NSBundle mainBundle] URLForResource:@"sounds/scan for identification" withExtension:@"wav"]];
}
- (ExtVC*)ext
{
	return [(AppDelegate*)[[UIApplication sharedApplication] delegate] valueForKey:@"externalVC"];
}
- (IBAction)a:(id)sender
{
	[self.ext a];
}
- (IBAction)b:(id)sender
{
	[self.ext b];
}

- (IBAction)s1:(id)sender
{
    [a seekToTime:CMTimeMake(0, 1)];
	[a play];
}
- (IBAction)s2:(id)sender
{
    [b seekToTime:CMTimeMake(0, 1)];
	[b play];
}
- (IBAction)s3:(id)sender
{
    [c seekToTime:CMTimeMake(0, 1)];
	[c play];
}
- (IBAction)s4:(id)sender
{
    [d seekToTime:CMTimeMake(0, 1)];
	[d play];
}
- (IBAction)s5:(id)sender
{
    [e seekToTime:CMTimeMake(0, 1)];
	[e play];
}
@end

@implementation AppDelegate
{
	ExtVC *_externalVC;
	UIWindow *_extW;
	UIScreen *_screen;
}

- (Foo*)foo {
	return (Foo*)self.window.rootViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSError *err;
	if(!([[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&err])) {
		NSLog(@"ASCategErr: %@", err);
	}
	if(![[AVAudioSession sharedInstance] setActive:YES error:&err]) {
		NSLog(@"ASSerr: %@", err);
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screensChanged:) name:UIScreenDidConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screensChanged:) name:UIScreenDidDisconnectNotification object:nil];
	[self screensChanged:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupControllers:) name:GCControllerDidConnectNotification object:nil];
	[GCController startWirelessControllerDiscoveryWithCompletionHandler:nil];
	[self setupControllers:nil];
	
	return YES;
}

- (void)setupControllers:(NSNotification*)notif
{
	int i = 0;
	for(GCController *controller in [GCController controllers]) {
		NSLog(@"Connecting controller %@", controller);
		if(controller.playerIndex == GCControllerPlayerIndexUnset)
			controller.playerIndex = i++;
		
		controller.extendedGamepad.leftThumbstick.valueChangedHandler = ^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
			if(yValue > -0.05 && yValue < 0.05) {
				[self.foo.evil performSelector:@selector(animateEye) withObject:nil afterDelay:1];
			} else {
				[NSObject cancelPreviousPerformRequestsWithTarget:self.foo.evil selector:@selector(animateEye) object:nil];
				[self.foo.evil moveEyeTo:((xValue*0.5)+0.5)*self.foo.evil.frame.size.width animated:NO];
			}
		};
		controller.gamepad.buttonA.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
			if(pressed)
				[self.foo s1:nil];
		};
		controller.gamepad.buttonB.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
			if(pressed)
				[self.foo s2:nil];
		};
		controller.gamepad.buttonX.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
			if(pressed)
				[self.foo s3:nil];
		};
		controller.gamepad.buttonY.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
			if(pressed)
				[self.foo s4:nil];
		};
		controller.extendedGamepad.rightShoulder.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
			if(pressed)
				[self.foo s5:nil];
		};
		
		controller.extendedGamepad.leftTrigger.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
			if(pressed)
				[self.foo a:nil];
		};
		controller.extendedGamepad.rightTrigger.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
			if(pressed)
				[self.foo b:nil];
		};


	}
}


- (void)screensChanged:(NSNotification*)notif
{
	UITextView *text = [(Foo*)[[[UIApplication sharedApplication] keyWindow] rootViewController] text];

	NSArray *screens = [UIScreen screens];
	if(screens.count == 1) {
		_externalVC = nil;
		_extW.hidden = YES;
		_extW = nil;
		_screen = nil;
		text.text = @"disconnected";
	} else {
		_screen = screens.lastObject;
		
		text.text = [_screen.availableModes description];
		UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
		_externalVC = [sb instantiateViewControllerWithIdentifier:@"external"];
		_extW = [[UIWindow alloc] initWithFrame:_screen.bounds];
		_extW.screen = _screen;
		_extW.hidden = NO;
		_extW.rootViewController = _externalVC;
	}
}
@end
