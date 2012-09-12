#import "Kiwi.h"
#import "OSMessage.h"

@interface OSMessage (Testing)
@property (nonatomic, assign) OSMessage *parentMessage;
@end

SPEC_BEGIN(OSMessageSpec)
describe(@"OSMessage", ^{
    
    it(@"should create a new instance with a selector and arguments", ^{
        OSMessage *message = [[OSMessage alloc] initWithSelector:@selector(foo:) arguments:[NSArray arrayWithObject:@"bar"]];
        [[message shouldNot] beNil];
        
    });
    
    it(@"should store selectors as strings", ^{
        SEL sel = @selector(foo);
        OSMessage *message = [[OSMessage alloc] initWithSelector:sel arguments:nil];
        [[message.selectorName should] equal:NSStringFromSelector(sel)];
    });
    

    it(@"should be able to return the arguments array", ^{
        OSMessage *message = [[OSMessage alloc] initWithSelector:@selector(foo:) arguments:[NSArray arrayWithObject:@"bar"]];
        [[message.arguments should] haveCountOf:1];
        
    });
    
    it(@"should be able to create an instance using a NSString for the selector", ^{
        OSMessage *message = [[OSMessage alloc] initWithSelectorName:@"foo" arguments:nil];
        [[message shouldNot] beNil];
        [[message.selectorName should] equal:@"foo"];
    });
    
    it(@"should return a selector from the selectorName", ^{
        SEL selector = NSSelectorFromString(@"foo");
        OSMessage *message = [[OSMessage alloc] initWithSelectorName:@"foo" arguments:nil];
        
        [[theValue([message selector]) should] equal:theValue(selector)];
    });
    
    it(@"should conform to NSCoding for serialization", ^{
        [[OSMessage should] conformToProtocol:@protocol(NSCoding)];
    });
    
    context(@"when building message chains", ^{
        it(@"should capture each sub message and its arguments", ^{
            OSMessage *message = [[OSMessage alloc] initWithSelectorName:@"foo" arguments:nil];
            
            NSArray *args = [NSArray arrayWithObject:@"baz"];
            
            [message message:@"bar:" arguments:args];
            
            [[message.subMessage.selectorName should] equal:@"bar:"];
            [[message.subMessage.arguments should] equal:args];
        });
        
        it(@"message chaining should return the root (parent) message", ^{
            OSMessage *message = [[OSMessage alloc] initWithSelectorName:@"foo" arguments:nil];
            
            OSMessage *chain = [[message message:@"bar:" arguments:[NSArray arrayWithObject:@"baz"]] message:@"blab" arguments:nil];
            [[chain should] equal:message];
        });
    });
    
    context(@"when serializing", ^{
        it(@"should serialize from the root message", ^{
            OSMessage *message = [[OSMessage alloc] initWithSelectorName:@"foo" arguments:nil];
            OSMessage *chain = [[message message:@"bar:" arguments:[NSArray arrayWithObject:@"baz"]] message:@"blab" arguments:nil];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:chain];
            OSMessage *decodedMessage = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [[decodedMessage.selectorName should] equal:message.selectorName];
            [[decodedMessage.subMessage.selectorName should] equal:message.subMessage.selectorName];
            
            //sNSLog(@"message: %@", [message description]);
            NSLog(@"decodeMessage: %@", [decodedMessage description]);
            
        });
    });
});
SPEC_END