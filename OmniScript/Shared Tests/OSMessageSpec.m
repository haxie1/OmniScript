#import "Kiwi.h"
#import "OSMessage.h"

@interface SubtestClass : NSObject
- (NSString *)subTestMethod;
@end

@implementation SubtestClass

- (NSString *)subTestMethod
{
    return @"subtestmethod";
}
@end

@interface TestClass : NSObject
@property (nonatomic, readonly, retain) SubtestClass *subTest;

- (void)methodWithNoReturn;
- (id)methodReturningObject;
- (NSUInteger)methodReturningPrimitive;
- (NSString *)methodTakingNumberReturningString:(NSNumber *)numb;
- (NSNumber *)methodTakingPrimitive:(NSUInteger)number;
- (NSArray *)methodTakingMultipleArguments:(NSString *)arg1 arg2:(NSNumber *)arg2 arg3:(NSArray *)arg3;

@end

@implementation TestClass
@synthesize subTest = _subTest;

- (id)init
{
    if(! (self = [super init])) {
        return nil;
    }
    _subTest = [[SubtestClass alloc] init];
    return self;
}

- (void)dealloc
{
    [_subTest release];
    [super dealloc];
}

- (void)methodWithNoReturn
{
    NSLog(@"called: %@", NSStringFromSelector(_cmd));
}

- (id)methodReturningObject
{
    return @"foo";
}

- (NSUInteger)methodReturningPrimitive
{
    return 10;
}

- (NSString *)methodTakingNumberReturningString:(NSNumber *)numb
{
    return [numb stringValue];
}

- (NSNumber *)methodTakingPrimitive:(NSUInteger)number
{
    return [NSNumber numberWithUnsignedInt:number];
}

- (NSArray *)methodTakingMultipleArguments:(NSString *)arg1 arg2:(NSNumber *)arg2 arg3:(NSArray *)arg3
{
    
    return [NSArray arrayWithObjects:arg1, arg2, arg3, nil];
}
@end

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
    
    context(@"when calling messages on a target", ^{
        __block TestClass *testCls = nil;
        beforeAll(^{
            testCls = [[TestClass alloc] init];
        });
    
        it(@"should invoke the message on a given target object", ^{
            OSMessage *m = [[OSMessage alloc] initWithSelectorName:@"methodWithNoReturn" arguments:nil];
            [[testCls should] receive:@selector(methodWithNoReturn)];
            [m invokeMessageOnTarget:testCls error:NULL];
           
        });
        
        it(@"should return an OSResultWrapper containing the result", ^{
            OSMessage *message = [[OSMessage alloc] initWithSelectorName:@"methodReturningObject" arguments:nil];
            OSResultWrapper *wrapper = [message invokeMessageOnTarget:testCls error:NULL];
            [[wrapper shouldNot] beNil];
            [[wrapper.result should] equal:[testCls methodReturningObject]];
            [[theValue(wrapper.isObject) should] beTrue];
        });
        
        it(@"should return an OSResultWrapper for messages taking an object argument", ^{
            NSNumber *twenty = [NSNumber numberWithUnsignedInteger:20];
            OSMessage *message = [[OSMessage alloc] initWithSelectorName:@"methodTakingNumberReturningString:"
                                                               arguments:[NSArray arrayWithObject:twenty]];
            OSResultWrapper *wrapper = [message invokeMessageOnTarget:testCls error:NULL];
            [[wrapper.result should] equal:[testCls methodTakingNumberReturningString:twenty]];
        });
        
        it(@"should return an OSResultWrapper for messages taking a primitive argument", ^{
            OSMessage *message = [[OSMessage alloc] init];
            message = [message methodTakingPrimitive:10];
            OSResultWrapper *wrapper = [message invokeMessageOnTarget:testCls error:NULL];
            [[wrapper.result should] equal:[testCls methodTakingPrimitive:10]];
        });
        
        it(@"should return the result of calling a message chain", ^{
            OSMessage *message = [[OSMessage alloc] initWithSelector:@selector(subTest) arguments:nil];
            message = [message message:@"subTestMethod" arguments:nil];
            OSResultWrapper *wrapper = [message invokeMessageOnTarget:testCls error:NULL];
            [[wrapper.result should] equal:[testCls.subTest subTestMethod]];
        });
        
        context(@"when errors occur", ^{
            it(@"should set the result to nil", ^{
                NSError *error = nil;
                OSMessage *message = [[OSMessage alloc] initWithSelector:@selector(subTest) arguments:nil];
                message = [message message:@"bogusMethod" arguments:nil];
                OSResultWrapper *wrapper = [message invokeMessageOnTarget:testCls error:&error];
                [wrapper shouldBeNil];
            });
            
            it(@"should return an error for bad method name", ^{
                NSError *error = nil;
                OSMessage *message = [[OSMessage alloc] initWithSelector:@selector(subTest) arguments:nil];
                message = [message message:@"bogusMethod" arguments:nil];
                OSResultWrapper *wrapper = [message invokeMessageOnTarget:testCls error:&error];
                [[error shouldNot] beNil];
            });
            
            it(@"should return error for missing argument", ^{
                NSError *error = nil;
                OSMessage *message = [[OSMessage alloc] initWithSelector:@selector(methodTakingPrimitive:) arguments:nil];
                OSResultWrapper *wrapper = [message invokeMessageOnTarget:testCls error:&error];
                [[error shouldNot] beNil];
            });
        });
        
    });
});
SPEC_END