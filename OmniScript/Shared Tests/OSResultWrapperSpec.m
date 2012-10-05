#import "kiwi.h"
#import "OSResultWrapper.h"

SPEC_BEGIN(OSResultWrapperSpec)

describe(@"OSResultWrapper", ^{
    it(@"should wrap an object", ^{
        OSResultWrapper *wrapper = [[OSResultWrapper alloc] init];
        [wrapper setObjectResult:@"String"];
        [[[wrapper result] shouldNot] beNil];
        [[[wrapper result] should] beKindOfClass:[NSString class]];
    });
    
    it(@"should return the encoded type", ^{
        OSResultWrapper *wrapper = [[OSResultWrapper alloc] init];
        [wrapper setObjectResult:@"String"];
        [[wrapper.type should] equal:@"@"];
    });
    
    it(@"should wrap numbers as NSNumbers", ^{
        OSResultWrapper *wrapper = [[OSResultWrapper alloc] init];
        NSUInteger value = 10;
        [wrapper setNonObjectResult:&value forObjcType:@encode(NSUInteger)];
        [[wrapper.result should] beKindOfClass:[NSNumber class]];
    });
});
SPEC_END