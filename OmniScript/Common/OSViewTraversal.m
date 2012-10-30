//
//  OSViewTraversal.m
//  OmniScript
//
//  Created by Kam Dahlin on 10/29/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import "OSViewTraversal.h"
#import "OmniScriptSupport.h"

@interface OSViewTraversal ()
@property (nonatomic, readwrite) id rootView;
@end

@implementation OSViewTraversal
@synthesize rootView = _rootView;

- (id)initWithRootView:(id)view
{
    if(! (self = [super init])) {
        [self release];
        return nil;
    }
    
    if(! [view conformsToProtocol:@protocol(OmniScriptScriptingContainer)]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"%@ must conform to OmniScriptScriptingContainer", [view class]];
    }
    
    _rootView = view;
    return self;
}

- (void)dealloc
{
    _rootView = nil;
    [super dealloc];
}

@end
