#import "AppDelegate.h"
#import "ExtVC.h"
#import "EVILViewController.h"
@import AVFoundation;

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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screensChanged:) name:UIScreenDidConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screensChanged:) name:UIScreenDidDisconnectNotification object:nil];
	[self screensChanged:nil];
	
	return YES;
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
