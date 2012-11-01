#import "Kiwi.h"
#import "OSViewTraversal.h"
#import <UIKit/UIKit.h>

@interface TestView : UIView
@end

@implementation TestView
- (id)omniScriptIdentifier
{
    return @"testview1";
}

- (NSString *)customMessage
{
    return @"booya";
}
@end

@interface FooBarView : UIView
@end

@implementation FooBarView
- (id)omniScriptIdentifier
{
    return @"foobarview";
}
@end

SPEC_BEGIN(OSViewTraversalSpec)
describe(@"OSViewTraversal", ^{
    it(@"should be initialized with a root object", ^{
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        OSViewTraversal *traversal = [[OSViewTraversal alloc] initWithRootView:v];
        [[traversal.rootView shouldNot] beNil];
    });
    
    it(@"should throw an exception if the root view doesn't conform to OmniScriptScriptingContainer protocol", ^{
        NSObject *foo = [[NSObject alloc] init];
        [[theBlock(^{
            [[OSViewTraversal alloc] initWithRootView:foo];
        }) should] raiseWithName:NSInternalInconsistencyException];
    });
    
    context(@"when finding views", ^{
        __block UIView *root = nil;
        beforeAll(^{
            root = [[UIView alloc] initWithFrame:CGRectZero];
            for(NSUInteger i = 0; i < 5; i++) {
                UIView *subView = [[UIView alloc] initWithFrame:CGRectZero];
                [root addSubview:subView];
                [subView release];
            }
            
            TestView *testView = [[TestView alloc] initWithFrame:CGRectZero];
            FooBarView *fooBarView = [[FooBarView alloc] initWithFrame:CGRectZero];
            
            [[[root subviews] objectAtIndex:3] addSubview:testView];
            
            [testView addSubview:fooBarView];
            [testView release];
            [fooBarView release];
        });
        
        context(@"when finding views by class name", ^{
            
            it(@"should return nil if the target view can't be found", ^{
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"BogusView"];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req];
                [result shouldBeNil];
            });
            
            it(@"should find a child view of the root view", ^{
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"testview"];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req];
                [[result shouldNot] beNil];
                [[result should] beKindOfClass:[TestView class]];
            });
            
            it(@"should find child views regardless of name format", ^{
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"FOoBarVIEW"];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req];
                [[result shouldNot] beNil];
                [[result should] beKindOfClass:[FooBarView class]];
            });
        });
        
        context(@"when finding views with the omniScriptIdentifier", ^{
            it(@"should find the view that matches the identifier", ^{
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"testView" withIdentifer:@"testview1"];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req];
                [[result shouldNot] beNil];
                [[result should] beKindOfClass:[TestView class]];

            });
            
            it(@"should return nil when a view with the given omniScriptIdentifier can't be found", ^{
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"testView" withIdentifer:@"bogusid"];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req];
                [result shouldBeNil];
            });
        });
        
        context(@"when finding views with a custom message", ^{
            
            it(@"should find the view that matches the result from a given message", ^{
                OSMessage *message = [[OSMessage alloc] initWithSelectorName:@"customMessage" arguments:nil];
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"testView" withIdentifier:@"booya" usingMessageForIdentifier:message];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req];
                [[result shouldNot] beNil];
                [[result should] beKindOfClass:[TestView class]];
            });
             
        });
    });
});
SPEC_END