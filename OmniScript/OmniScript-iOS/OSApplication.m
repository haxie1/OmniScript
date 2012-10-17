//
//  OSApplication.m
//  OmniScript
//
//  Created by Kam Dahlin on 10/15/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import "OSApplication.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "OSMessenger.h"
#import "OSResponse.h"
#import "OSViewRequest.h"


@interface OSApplication () <OSMessengerDelegate>
@property (nonatomic, retain) OSMessenger *messenger;
+ (void)startOmniScriptSessionForCurrentApplication;
- (id)initWithSessionName:(NSString *)sessionName;
- (void)sendResponse:(OSResponse *)response;
- (void)processRequest:(OSViewRequest *)request;
@end

@implementation OSApplication

@synthesize messenger = _messenger;
@synthesize isPublished = _isPublished;

+ (void)startOmniScriptSessionForCurrentApplication
{
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    [[self class] startOmniScriptSessionWithSessionName:bundleName];
}

static char *kOSAppInstanceKey = "OSApplicationKey";
+ (void)startOmniScriptSessionWithSessionName:(NSString *)sessionName
{
    OSApplication *app = [[[OSApplication alloc] initWithSessionName:sessionName] autorelease];
    UIApplication *appInstance = [UIApplication sharedApplication];
    objc_setAssociatedObject(appInstance, kOSAppInstanceKey, app, OBJC_ASSOCIATION_RETAIN);
}

- (id)initWithSessionName:(NSString *)sessionName
{
    if(! (self = [super init])) {
        [self release];
        return nil;
    }
    
    _messenger = [[OSMessenger alloc] init];
    _messenger.delegate = self;
    [_messenger publishServiceWithName:sessionName];
    
    self.isPublished = NO;
    
    return self;
}

- (void)dealloc
{
    [self stopSession];
    [_messenger release];
    
    [super dealloc];
}

- (void)stopSession
{
    [self.messenger stop];
}

- (void)sendResponse:(OSResponse *)response
{
    NSData *responseData = [NSKeyedArchiver archivedDataWithRootObject:response];
    [self.messenger sendData:responseData];
}

- (void)processRequest:(OSViewRequest *)request
{
    
}

#pragma mark - OSMessengerDelegate

-(void)messenger:(OSMessenger *)messenger receivedData:(NSData *)data
{
    id req = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if([req isKindOfClass:[OSViewRequest class]]) {
        OSViewRequest *viewReq = (OSViewRequest *)req;
        [self processRequest:viewReq];
    } else {
        // TODO: handle other request types
    }
}

-(void)messengerPublishedSuccessfully:(OSMessenger *)messenger
{
    self.isPublished = YES;
}

-(void)messenger:(OSMessenger *)messenger failedToPublish:(NSError *)error
{
    self.isPublished = NO;
    NSLog(@"OSApplication failed to publish scripting session: %@", [error description]);
}

-(void)messenger:(OSMessenger *)messenger sentBytes:(NSNumber *)bytes
{
    NSLog(@"sent bytes: %@", bytes);
}

@end
