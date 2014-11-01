//
//  TCAHPSimpleClient.m
//  TCAHPDemo
//
//  Created by Joachim Bengtsson on 2012-10-06.
//
//

#import "TCAHPSimpleClient.h"

@interface TCAHPSimpleClient () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@end

@implementation TCAHPSimpleClient {
    NSNetServiceBrowser *_browser;
    AsyncSocket *_connectingSocket;
    NSString *_serviceType;
    id<TCAsyncHashProtocolDelegate> _delegate;
    NSMutableSet *_pendingResolve;
    NSMutableSet *_resolved;
	NSTimer *_reconnect;
}
- (id)initConnectingToAnyHostOfType:(NSString*)serviceType delegate:(id<TCAsyncHashProtocolDelegate>)delegate
{
    if(!(self = [super init]))
        return nil;
    
    _pendingResolve = [NSMutableSet new];
    _resolved = [NSMutableSet new];
    
    _browser = [[NSNetServiceBrowser alloc] init];
    _browser.delegate = self;
    _serviceType = serviceType;
    [_browser searchForServicesOfType:serviceType inDomain:@""];
    
    _delegate = delegate;
    
    return self;
}

- (void)reconnect;
{
	NSLog(@"Disconnecting and reconnecting to %@", _resolved);
    [_proto.socket disconnect];
    [_connectingSocket disconnect];
    _proto = nil;
    _connectingSocket = nil;

    if(_resolved.count > 0)
        [self connectToNetService:_resolved.anyObject];
}

- (void)connectToNetService:(NSNetService*)aNetService
{
    NSLog(@"Attempting connection to %@", aNetService);
    
    NSError *err;
    _connectingSocket = [[AsyncSocket alloc] initWithDelegate:self];
    for(NSData *address in aNetService.addresses)
        if(![_connectingSocket connectToAddress:address error:&err])
            NSLog(@"Failed connection to %@: %@", aNetService, err);
        else
            return;
	
	NSLog(@"Failed to connect, starting retry");
	[self startReconnecting];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"Attempting resolution of %@", aNetService);
    [_pendingResolve addObject:aNetService];
    aNetService.delegate = self;
    [aNetService resolveWithTimeout:5];
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
	NSLog(@"Lost service %@", aNetService);
    [_pendingResolve removeObject:aNetService];
    [_resolved removeObject:aNetService];
}

- (void)netServiceDidResolveAddress:(NSNetService *)aNetService
{
	NSLog(@"Did resolve %@", aNetService);
    [_resolved addObject:aNetService];
    [_pendingResolve removeObject:aNetService];
    
    if (_proto || _connectingSocket)
        return;
    
    [self connectToNetService:aNetService];
}
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict;
{
    NSLog(@"Failed to resolve %@: %@", sender, errorDict);
    [_pendingResolve removeObject:sender];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Connected to %@", host);
    self.proto = [[TCAsyncHashProtocol alloc] initWithSocket:sock delegate:(id)self];
    _connectingSocket = nil;
	_proto.autoDispatchCommands = YES;
	[_proto readHash];
	[_reconnect invalidate]; _reconnect = nil;
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"Disconnection reason: %@ %@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"Disconnected %@", sock);
    _connectingSocket = nil;
    self.proto = nil;
    [_browser searchForServicesOfType:_serviceType inDomain:@""];
	[self startReconnecting];
}

- (void)startReconnecting
{
	[_reconnect invalidate];
	_reconnect = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(reconnect) userInfo:nil repeats:YES];
}

// Forward AsyncSocket delegates.
-(NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector;
{
	if([super respondsToSelector:aSelector]) return [super methodSignatureForSelector:aSelector];
	if([_delegate respondsToSelector:aSelector]) return [(id)_delegate methodSignatureForSelector:aSelector];
	return nil;
}
-(void)forwardInvocation:(NSInvocation *)anInvocation;
{
	if([_delegate respondsToSelector:anInvocation.selector]) {
		anInvocation.target = _delegate;
		[anInvocation invoke];
        return;
	}
	[super forwardInvocation:anInvocation];
}
-(BOOL)respondsToSelector:(SEL)aSelector;
{
	return [super respondsToSelector:aSelector] || [_delegate respondsToSelector:aSelector];
}
@end
