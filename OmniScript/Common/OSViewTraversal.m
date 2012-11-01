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
- (id)findWithRequest:(OSViewRequest *)currentRequest startingFromView:(id)view error:(NSError **)error;
- (NSString *)viewClassForCurrentSystem;
- (BOOL)viewClass:(id)view matchesName:(NSString *)searchName;
- (BOOL)view:(id)view matchesRequest:(OSViewRequest *)req error:(NSError **)error;
- (id)executeMessage:(OSMessage *)message onView:(id)view error:(NSError **)error;
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

- (id)findViewWithRequst:(OSViewRequest *)request error:(NSError **)error;
{
    id foundView = [self findWithRequest:request startingFromView:self.rootView error:error];
    return foundView;
}

- (id)findWithRequest:(OSViewRequest *)request startingFromView:(id)view error:(NSError **)error
{
    OSViewRequest *currentRequest = request;
    
    NSString *targetViewClass = currentRequest.viewClass;
    if(([targetViewClass isEqualToString:@"view"]) || (targetViewClass == nil)) {
        targetViewClass = [self viewClassForCurrentSystem];
    }
    
    NSError *matchError = nil;
    if([self view:view matchesRequest:currentRequest error:&matchError]) {
        if(request.request == nil) {
            NSLog(@"we got a match: %@", [view class]);
            return view;
        }
        currentRequest = request.request;
        
    } else {
        if(error) {
            // if we have an error than it means it is fatal to our search
            // so set the error ref and bail.
            if(matchError) {
                *error = matchError;
                return nil;
            }
        }
    }
    
    
    id resultView = nil;
    for(id child in [view omniScriptChildren]) {
        resultView = [self findWithRequest:currentRequest startingFromView:child error:error];
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

// we can match a view
// we can match a view and a scripting identifier
// we can match a view using a custom message
- (BOOL)view:(id)view matchesRequest:(OSViewRequest *)req error:(NSError **)error
{
    // if we don't match the current view, bail
    // if this is our last request, then we never found the view, so create an error
    if(! [self viewClass:view matchesName:req.viewClass])
    {
        if(req.request == nil) {
            if(error) {
                NSString *reason = [NSString stringWithFormat:@"Couldn't find view: %@", req.viewClass];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:reason, NSLocalizedFailureReasonErrorKey, nil];
                *error = [NSError errorWithDomain:@"OSViewRequestViewNotFound" code:1001 userInfo:dict];
            }
        }
        return NO;
    }
        
    
    BOOL result = YES; // at this point we have a matching view so if nothing else changes we should return that we have a match
    if(req.identifier) {
        NSError *messageError = nil;
        if([req.identifier isEqual:[self executeMessage:req.identifierMessage onView:view error:&messageError]]) {
            result = YES;
        } else {
            if(error) {
                if(messageError) {
                   *error = messageError; 
                } else {
                    NSString *reason = [NSString stringWithFormat:@"Failed to find view with identifier: %@ - using message: %@", req.identifier, [req.identifierMessage selectorName]];
                   NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:reason, NSLocalizedFailureReasonErrorKey, nil];
                    *error = [NSError errorWithDomain:@"OSViewRequestViewNotFound" code:1001 userInfo:dict];
                }
            }
            result = NO;
        }
    }
    
    return result;
}

- (BOOL)viewClass:(id)view matchesName:(NSString *)searchName;
{
    NSString *classStr = NSStringFromClass([view class]);
    NSRange matchRange = [classStr rangeOfString:searchName options:(NSRegularExpressionSearch | NSCaseInsensitiveSearch)];
    return (NSEqualRanges(matchRange, NSMakeRange(NSNotFound, 0)) ? NO : YES);
}

- (id)executeMessage:(OSMessage *)message onView:(id)view error:(NSError **)error;
{
    OSResultWrapper *wrappedResult = [message invokeMessageOnTarget:view error:error];
    if(! wrappedResult) {
        NSLog(@"failed to execute message on view: %@ because: %@", [view class], *error);
        return nil;
    }
    
    return wrappedResult.result;
}
@end
