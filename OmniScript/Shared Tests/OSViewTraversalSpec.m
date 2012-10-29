#import "Kiwi.h"
#import "NSObject+OmniScriptSupport.h"

SPEC_BEGIN(OSViewTraversalSpec)
describe(@"OSViewTraversal", ^{
    it(@"should print out methods", ^{
        NSString *str = @"foo";
        NSArray *methods = [str propertyNames];
        NSLog(@"method names: %@", methods);
    });
});
SPEC_END