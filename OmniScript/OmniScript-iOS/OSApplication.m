//
//  OSApplication.m
//  OmniScript
//
//  Created by Kam Dahlin on 10/15/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import "OSApplication.h"
#import "OSMessenger.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface OSApplication () <OSMessengerDelegate>
@property (nonatomic, retain) OSMessenger *messenger;
+ (void)startOmniScriptSessionForCurrentApplication;
- (id)initWithSessionName:(NSString *)sessionName;
@end

@implementation OSApplication

@synthesize messenger = _messenger;
@synthesize isPublished = _isPublished;

+ (void)startOmniScriptSessionForCurrentApplication
{
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    [[self class] startOmniScriptSessionWithSessionName:bundleName];
}

static char *kOSAppInstanceKey = "OSApplicationInstance";
+ (void)startOmniScriptSessionWithSessionName:(NSString *)sessionName
{
    OSApplication *app = [[OSApplication alloc] initWithSessionName:sessionName];
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

#pragma mark - OSMessengerDelegate

-(void)messenger:(OSMessenger *)messenger receivedData:(NSData *)data
{
    
}

-(void)messengerPublishedSuccessfully:(OSMessenger *)messenger
{
    self.isPublished = YES;
}

-(void)messenger:(OSMessenger *)messenger failedToPublish:(NSError *)error
{
    self.isPublished = NO;
}

-(void)messenger:(OSMessenger *)messenger sentBytes:(NSNumber *)bytes
{
    
}

@end
