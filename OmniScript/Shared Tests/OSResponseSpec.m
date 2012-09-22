#import "kiwi.h"
#import "OSResponse.h"

SPEC_BEGIN(OSResponseSpec)

describe(@"OSResponse", ^{
    it(@"should create a new instance with a status and optional error and result objects", ^{
        OSResponse *response = [[OSResponse alloc] initWithStatus:YES result:nil error:nil];
        [[response shouldNot] beNil];
        [[theValue(response.status) should] beTrue];
    });
});

SPEC_END
