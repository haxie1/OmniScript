#import "kiwi.h"
#import "OSResultWrapper.h"
#import <UIKit/UIKit.h>

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
    
    it(@"should wrap (const char *) as a NSString", ^{
        OSResultWrapper *wrapper = [[OSResultWrapper alloc] init];
        const char *str = "string";
        [wrapper setNonObjectResult:str forObjcType:@encode(const char *)];
        [[wrapper.result should] beKindOfClass:[NSString class]];
        [[wrapper.result should] equal:@"string"];
    });
    
    it(@"should wrap BOOL is a NSNumber", ^{
       OSResultWrapper *wrapper = [[OSResultWrapper alloc] init];
        BOOL yn = YES;
        [wrapper setNonObjectResult:&yn forObjcType:@encode(BOOL)];
        [[wrapper.result should] beKindOfClass:[NSNumber class]];
    });
    
    it(@"should handle void by setting the type but not the result", ^{
        OSResultWrapper *wrapper = [[OSResultWrapper alloc] init];
        [wrapper setNonObjectResult:NULL forObjcType:@encode(void)];
        [wrapper.result shouldBeNil];
        [[wrapper.type should] equal:@"v"];
    });
    
    it(@"should wrap structures in NSValues", ^{
       OSResultWrapper *wrapper = [[OSResultWrapper alloc] init];
        CGRect rect = CGRectMake(10, 10, 10, 10);
        [wrapper setNonObjectResult:&rect forObjcType:@encode(CGRect)];
        [[wrapper.result should] beKindOfClass:[NSValue class]];
    });
    
    context(@"when serializing/deserializing", ^{
        it(@"should confrom to NSCoding", ^{
            [[OSResultWrapper should] conformToProtocol:@protocol(NSCoding)];
        });
        
        it(@"should properly encode/decode when the wrapped result is an object", ^{
            OSResultWrapper *wrapper = [[OSResultWrapper alloc] init];
            [wrapper setObjectResult:@"Foo"];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:wrapper];
            OSResultWrapper *decodedWrapper = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [[decodedWrapper.result should] equal:@"Foo"];
            [[decodedWrapper.type should] equal:@"@"];
            
        });
        
        it(@"should properly encode/decode when the wrapped result is not an object", ^{
            OSResultWrapper *wrapper = [[OSResultWrapper alloc] init];
            CGPoint p = CGPointMake(10, 10);
            [wrapper setNonObjectResult:&p forObjcType:@encode(CGPoint)];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:wrapper];
            OSResultWrapper *decodedWrapper = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSValue *val = decodedWrapper.result;
            
            CGPoint decodedPoint = [val CGPointValue];
            BOOL yn = CGPointEqualToPoint(decodedPoint, p);
            
            [[theValue(yn) should] beTrue];
            [[decodedWrapper.type should] equal:@"{CGPoint=ff}"];
        });
    });
});
SPEC_END