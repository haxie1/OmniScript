#import "kiwi.h"
#import <Foundation/Foundation.h>

#import "OSResponse.h"

SPEC_BEGIN(OSResponseSpec)
NSString * (^uuid)(void) = ^NSString * (void) {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (NSString *)CFUUIDCreateString(NULL, uuid);
    
    CFRelease(uuid);
    
    return [uuidStr autorelease];
};

describe(@"OSResponse", ^{
    it(@"should create a new instance", ^{
        OSResponse *response = [[OSResponse alloc] initWithRequestID:uuid() result:nil requestSucceeded:YES error:nil];
        [[response shouldNot] beNil];
        [[theValue(response.requestSucceeded) should] beTrue];
    });
    
    it(@"the response id should not be nil", ^{
         OSResponse *response = [[OSResponse alloc] initWithRequestID:uuid() result:nil requestSucceeded:YES error:nil];
        [[response.responseID shouldNot] beNil];
    });
    
    it(@"should generate a response id if no request id is provided", ^{
        OSResponse *response = [[OSResponse alloc] initWithRequestID:nil result:nil requestSucceeded:YES error:nil];
        [[response.responseID shouldNot] beNil];

    });
    
    context(@"when serializing/deserializing", ^{
        it(@"should conform to NSCoding", ^{
            [[OSResponse should] conformToProtocol:@protocol(NSCoding)];
        });
        
        it(@"should encode and decode the object correctly", ^{
            NSError *error = [NSError errorWithDomain:@"foo" code:1 userInfo:nil];
            
            OSResponse *response = [[OSResponse alloc] initWithRequestID:uuid() result:@"Foo" requestSucceeded:YES error:error];
            NSData *repData = [NSKeyedArchiver archivedDataWithRootObject:response];
            OSResponse *unarchivedResp = [NSKeyedUnarchiver unarchiveObjectWithData:repData];
            
            [[response.responseID should] equal:unarchivedResp.responseID];
            [[theValue(response.requestSucceeded) should] equal:theValue(unarchivedResp.requestSucceeded)];
            [[response.result should] equal:unarchivedResp.result];
            [[response.error should] equal:unarchivedResp.error];
        });
    });
});

SPEC_END
