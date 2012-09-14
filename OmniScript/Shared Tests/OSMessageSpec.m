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
        
        it(@"should fill in the root message first", ^{
            OSMessage *message = [[OSMessage alloc] init];
            message = [[message message:@"foo" arguments:[NSArray arrayWithObject:@"bar"]] message:@"baz" arguments:nil];
            [[message.selectorName should] equal:@"foo"];
            [[message.subMessage.selectorName should] equal:@"baz"];
        });
        
        context(@"when building messages directly", ^{
            context(@"when parsing a selector", ^{
                it(@"should return a faked method signature with '@' for argument placeholders", ^{
                    OSMessage *message = [[OSMessage alloc] init];
                    NSMethodSignature *sig = [message methodSignatureForSelector:@selector(foo:bar:baz:)];
                    [[theValue([sig numberOfArguments]) should] equal:theValue(5)];
                    NSString *arg1 = [NSString stringWithUTF8String:[sig getArgumentTypeAtIndex:2]];
                    [[arg1 should] equal:@"@"];
                });
            });
            
            it(@"should capture real methods and arguments", ^{
                OSMessage *message = [[OSMessage alloc] init];
                
                message = [[message foo] bar:@"baz"];
                [[message.selectorName should] equal:@"foo"];
                [[message.subMessage.selectorName should] equal:@"bar:"];
                [[message.subMessage.arguments should] haveCountOf:1];
            });
            
            it(@"should handle non-object arguments", ^{
                OSMessage *message = [[OSMessage alloc] init];
                message = [message integerArgument:121];
                [[message.arguments should] haveCountOf:1];
            });
            
            it(@"should hint that the selector needs to be resolved", ^{
                OSMessage *message = [[OSMessage alloc] init];
                message = [message madeUpMethod:@"foo"];
                [[theValue(message.resolveMessage) should] beTrue];
            });
        });
    
    });
    
    context(@"when using a keypath", ^{
        it(@"should build a message chain using the keypath keys as arguments", ^{
            OSMessage *message = [[OSMessage alloc] initWithKeyPath:@"foo.bar.baz.bap"];
            [[message.selectorName should] equal:@"valueForKey:"];
            [[message.arguments should] contain:@"foo"];
            [[message.subMessage.selectorName should] equal:@"valueForKey:"];
            [[message.subMessage.arguments should] contain:@"bar"];
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
            
        });
    });
});
SPEC_END