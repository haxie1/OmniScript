#import "Kiwi.h"
#import "OSViewTraversal.h"
#import <UIKit/UIKit.h>

@interface TestView : UIView
@property (nonatomic, retain) NSString *identStr;
@end

@implementation TestView
@synthesize identStr = _identStr;

-(void)dealloc
{
    [_identStr release];
    [super dealloc];
}

- (id)omniScriptIdentifier
{
    return self.identStr;
}

- (NSString *)customMessage
{
    return @"booya";
}
@end

@interface SubTestView : UIView

@end

@implementation SubTestView

- (id)omniScriptIdentifier
{
    return @"subTestView";
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
            testView.identStr = @"testview1";
            FooBarView *fooBarView = [[FooBarView alloc] initWithFrame:CGRectZero];
            [testView addSubview:fooBarView];
            
            [[[root subviews] objectAtIndex:3] addSubview:testView];
            UIView *subRoot = [[root subviews] objectAtIndex:2];
            SubTestView *sv = [[SubTestView alloc] initWithFrame:CGRectZero];
            for(NSUInteger i = 0; i < 5; i++) {
                TestView *tv = [[TestView alloc] init];
                tv.identStr = [NSString stringWithFormat:@"viewid%d", i];
                if([tv.identStr isEqualToString:@"viewid3"]) {
                    [tv addSubview:sv];
                }
                
                [subRoot addSubview:tv];
                [tv release];
            }
            
            [sv release];
            [testView release];
            [fooBarView release];
        });
        
        context(@"when finding views by class name", ^{
            
            it(@"should return nil if the target view can't be found", ^{
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"BogusView"];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req error:NULL];
                [result shouldBeNil];
            });
            
            it(@"should find a child view of the root view", ^{
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"testview"];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req error:NULL];
                [[result shouldNot] beNil];
                [[result should] beKindOfClass:[TestView class]];
            });
            
            it(@"should find child views regardless of name format", ^{
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"FOoBarVIEW"];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req error:NULL];
                [[result shouldNot] beNil];
                [[result should] beKindOfClass:[FooBarView class]];
            });
        });
        
        context(@"when finding views with the omniScriptIdentifier", ^{
            it(@"should find the view that matches the identifier", ^{
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"testView" withIdentifer:@"testview1"];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req error:NULL];
                [[result shouldNot] beNil];
                [[result should] beKindOfClass:[TestView class]];

            });
            
            it(@"should return nil when a view with the given omniScriptIdentifier can't be found", ^{
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"testView" withIdentifer:@"bogusid"];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req error:NULL];
                [result shouldBeNil];
            });
            
            context(@"when multiples of the same view are found", ^{
                it(@"should find a view with a specific omniScriptIdentifier", ^{
                    OSViewRequest *req = [[OSViewRequest alloc] init];
                    req = [[req findViewClass:@"view"] findViewClass:@"testView" withIdentifer:@"viewid2"];
                    OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                    id result = [traveral findViewWithRequst:req error:NULL];
                    [[result shouldNot] beNil];
                    [[result should] beKindOfClass:[TestView class]];;
                    [[[result omniScriptIdentifier] should] equal:@"viewid2"];
                });
                
                it(@"should find a view in the path with a specific omniscriptIdentifier", ^{
                    OSViewRequest *req = [[OSViewRequest alloc] init];
                    req = [[[req findViewClass:@"view"] findViewClass:@"testView" withIdentifer:@"viewid3"] findViewClass:@"subTestView" withIdentifer:@"subTestView"];
                    OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                    id result = [traveral findViewWithRequst:req error:NULL];
                    [[result shouldNot] beNil];
                    [[result should] beKindOfClass:[SubTestView class]];;
                    [[[result omniScriptIdentifier] should] equal:@"subTestView"];
                    NSLog(@"----> result id: %@", [result omniScriptIdentifier]);
                });
            });
            
        });
        
        context(@"when finding views with a custom message", ^{
            
            it(@"should find the view that matches the result from a given message", ^{
                OSMessage *message = [[OSMessage alloc] initWithSelectorName:@"customMessage" arguments:nil];
                OSViewRequest *req = [[OSViewRequest alloc] init];
                req = [[req findViewClass:@"view"] findViewClass:@"testView" withIdentifier:@"booya" usingMessageForIdentifier:message];
                OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
                id result = [traveral findViewWithRequst:req error:NULL];
                [[result shouldNot] beNil];
                [[result should] beKindOfClass:[TestView class]];
            });
             
        });
        
        it(@"should return an error by reference when a view can't be found", ^{
            OSViewRequest *req = [[OSViewRequest alloc] init];
            req = [[req findViewClass:@"view"] findViewClass:@"BogusView"];
            OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
            NSError *error = nil;
            id result = [traveral findViewWithRequst:req error:&error];
            [result shouldBeNil];
            [error shouldNotBeNil];
        });
        
        it(@"should return an error when a view in the chain can't be found", ^{
            OSViewRequest *req = [[OSViewRequest alloc] init];
            req = [[[req findViewClass:@"view"] findViewClass:@"BogusView"] findViewClass:@"TestView"];
            OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
            NSError *error = nil;
            id result = [traveral findViewWithRequst:req error:&error];
            [result shouldBeNil];
            [error shouldNotBeNil];
        });
        
        it(@"should return an error by reference when a view can't be found using a message", ^{
            OSViewRequest *req = [[OSViewRequest alloc] init];
            req = [[[req findViewClass:@"view"] findViewClass:@"testView" withIdentifer:@"viewid"]
                                                findViewClass:@"subTestView" withIdentifer:@"subTestView"];
            OSViewTraversal *traveral = [[OSViewTraversal alloc] initWithRootView:root];
            NSError *error = nil;
            id result = [traveral findViewWithRequst:req error:&error];
            [result shouldBeNil];
            [error shouldNotBeNil];
        });
    });
});
SPEC_END