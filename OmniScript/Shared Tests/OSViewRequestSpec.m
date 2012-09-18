#import "Kiwi.h"
#import "OSViewRequest.h"

SPEC_BEGIN(OSViewRequestSpec)
describe(@"OSViewRequest", ^{
    it(@"should be intialized with arguments", ^{
        OSViewRequest *req = [[OSViewRequest alloc] initWithViewClass:@"view" identifier:nil identifierUsingMessage:nil];
        [[req shouldNot] beNil];
        [[req.viewClass should] equal:@"view"];
    });
    
    it(@"should create a default message if no message is given", ^{
        OSViewRequest *req = [[OSViewRequest alloc] initWithViewClass:@"view" identifier:@"foo" identifierUsingMessage:nil];
        [[req.identifierMessage shouldNot] beNil];
        [[req.identifierMessage.selectorName should] equal:@"omniScriptIdentifier"];
    });
    
    it(@"should use the message given", ^{
        OSMessage *message = [[OSMessage alloc] initWithSelectorName:@"foo" arguments:nil];
        OSViewRequest *req = [[OSViewRequest alloc] initWithViewClass:@"view" identifier:@"foo" identifierUsingMessage:message];
        [[req.identifierMessage should] equal:message];
    });
    
    it(@"should the view class to 'view' if no viewClass is given", ^{
        OSViewRequest *req = [[OSViewRequest alloc] initWithViewClass:nil identifier:@"foo" identifierUsingMessage:nil];
        [[req.viewClass should] equal:@"view"];
    });
    
    context(@"when serializing", ^{
        it(@"should conform to NSCoding", ^{
            [[OSViewRequest should] conformToProtocol:@protocol(NSCoding)];
        });
        
        it(@"should encode and decode the object correctly", ^{
            OSViewRequest *req = [[OSViewRequest alloc] initWithViewClass:@"view" identifier:@"foo" identifierUsingMessage:nil];
            NSData *d = [NSKeyedArchiver archivedDataWithRootObject:req];
            OSViewRequest *unpackedReq = [NSKeyedUnarchiver unarchiveObjectWithData:d];
            
            [[unpackedReq.viewClass should] equal:req.viewClass];
            [[unpackedReq.identifier should] equal:req.identifier];
            [[unpackedReq.identifierMessage.selectorName should] equal:@"omniScriptIdentifier"];
        });
    });
    
    context(@"when building requests", ^{
        
    });
});
SPEC_END
