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
- (id)findWithRequest:(OSViewRequest *)currentRequest startingFromView:(id)view;
- (NSString *)viewClassForCurrentSystem;
- (BOOL)viewClass:(id)view matchesName:(NSString *)searchName;
- (BOOL)view:(id)view matchesRequest:(OSViewRequest *)req;
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

- (id)findViewWithRequst:(OSViewRequest *)request
{
    id foundView = [self findWithRequest:request startingFromView:self.rootView];
    return foundView;
}

- (id)findWithRequest:(OSViewRequest *)request startingFromView:(id)view
{
    OSViewRequest *currentRequest = request;
    
    NSString *targetViewClass = currentRequest.viewClass;
    if(([targetViewClass isEqualToString:@"view"]) || (targetViewClass == nil)) {
        targetViewClass = [self viewClassForCurrentSystem];
    }
    
    if([self view:view matchesRequest:currentRequest]) {
        if(request.request == nil) {
            NSLog(@"we got a match: %@", [view class]);
            return view;
        }
        currentRequest = request.request;
    }
    
    id resultView = nil;
    for(id child in [view omniScriptChildren]) {
        resultView = [self findWithRequest:currentRequest startingFromView:child];
        if(resultView) {
            return resultView;
        }
    }
    
    return nil;
}

- (NSString *)viewClassForCurrentSystem
{
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    return @"UIView";
#else
    return @"NSView";
#endif
}

- (BOOL)view:(id)view matchesRequest:(OSViewRequest *)req
{
    if([self viewClass:view matchesName:req.viewClass]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)viewClass:(id)view matchesName:(NSString *)searchName;
{
    NSString *classStr = NSStringFromClass([view class]);
    NSRange matchRange = [classStr rangeOfString:searchName options:(NSRegularExpressionSearch | NSCaseInsensitiveSearch)];
    return (NSEqualRanges(matchRange, NSMakeRange(NSNotFound, 0)) ? NO : YES);
}
@end
