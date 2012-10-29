#import "Kiwi.h"
#import "OSViewTraversal.h"
#import <UIKit/UIKit.h>

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
});
SPEC_END