#import "AppDelegate.h"
#import "ExtVC.h"

@interface AppDelegate ()

@end

@interface Foo : UIViewController
@property(nonatomic) IBOutlet UITextView *text;
@end
@implementation Foo
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
