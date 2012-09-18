#import "Kiwi.h"
#import "OSViewRequest.h"

SPEC_BEGIN(OSViewRequestSpec)
describe(@"OSViewRequest", ^{
    it(@"should be intialized with arguments", ^{
        OSViewRequest *req = [[OSViewRequest alloc] initWithViewClass:@"view" identifier:nil usingMessageForIdentifier:nil];
        [[req shouldNot] beNil];
        [[req.viewClass should] equal:@"view"];
    });
    
    it(@"should create a default message if no message is given", ^{
        OSViewRequest *req = [[OSViewRequest alloc] initWithViewClass:@"view" identifier:@"foo" usingMessageForIdentifier:nil];
        [[req.identifierMessage shouldNot] beNil];
        [[req.identifierMessage.selectorName should] equal:@"omniScriptIdentifier"];
    });
    
    it(@"should use the message given", ^{
        OSMessage *message = [[OSMessage alloc] initWithSelectorName:@"foo" arguments:nil];
        OSViewRequest *req = [[OSViewRequest alloc] initWithViewClass:@"view" identifier:@"foo" usingMessageForIdentifier:message];
        [[req.identifierMessage should] equal:message];
    });
    
    it(@"should the view class to 'view' if no viewClass is given", ^{
        OSViewRequest *req = [[OSViewRequest alloc] initWithViewClass:nil identifier:@"foo" usingMessageForIdentifier:nil];
        [[req.viewClass should] equal:@"view"];
    });
    
    context(@"when building requests", ^{
        
        __block OSViewRequest *firstReq = nil;
        __block OSViewRequest *builderResult = nil;
        beforeEach(^{
             firstReq = [[OSViewRequest alloc] initWithViewClass:@"view" identifier:@"foo" usingMessageForIdentifier:nil];
            builderResult = [[firstReq findViewClass:@"tableView"] findViewClass:@"tableViewCell" withIdentifer:@"bar"];
            NSLog(@"firstReq: %@", [firstReq description]);
        });
        
        it(@"should build nested requests", ^{
            [[firstReq.request.request shouldNot] beNil];
            [[firstReq.request.request.viewClass should] equal:@"tableViewCell"];
        });
        
        it(@"should always return the root view request", ^{
            [[builderResult should] equal:firstReq];
        });
    });
    
    context(@"when serializing", ^{
        __block OSViewRequest *req;
        __block OSViewRequest *unpackedReq;
        
        beforeEach(^{
            req = [[OSViewRequest alloc] initWithViewClass:@"view" identifier:@"foo" usingMessageForIdentifier:nil];
            [[req findViewClass:@"firstSubView"] findViewClass:@"subView" withIdentifier:@"bar" usingMessageForIdentifier:nil];
            NSData *d = [NSKeyedArchiver archivedDataWithRootObject:req];
            unpackedReq = [NSKeyedUnarchiver unarchiveObjectWithData:d];
        });
        
        it(@"should conform to NSCoding", ^{
            [[OSViewRequest should] conformToProtocol:@protocol(NSCoding)];
        });
        
        it(@"should encode and decode the object correctly", ^{
            [[unpackedReq.viewClass should] equal:req.viewClass];
            [[unpackedReq.identifier should] equal:req.identifier];
            [[unpackedReq.identifierMessage.selectorName should] equal:@"omniScriptIdentifier"];
        });
        
        it(@"should properly encode/decode sub requests", ^{
            [[unpackedReq.request.viewClass should] equal:@"firstSubView"];
            [[unpackedReq.request.request.viewClass should] equal:@"subView"];
        });
    });
});
SPEC_END
