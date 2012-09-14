//
//  OSMessage.m
//  OmniScript
//
//  Created by Kam Dahlin on 9/11/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import "OSMessage.h"


@interface OSMessage ()
@property (nonatomic, readwrite, retain) OSMessage *subMessage;
@property (nonatomic, assign) OSMessage *parentMessage;
@property (nonatomic, assign) BOOL resolveMessage;

- (id)initWithSelectorName:(NSString *)string arguments:(NSArray *)arguments subMessage:(OSMessage *)subMessage;
- (id)messageFromKeyPath:(NSString *)keypath;
@end

static NSString *SELECTOR_KEY = @"selectorName";
static NSString *ARGUMENTS_KEY = @"arguments";
static NSString *SUBMESSAGE_KEY = @"subMessage";

@implementation OSMessage
@synthesize selectorName = _selectorName;
@synthesize arguments = _arguments;
@synthesize subMessage = _subMessage;
@synthesize parentMessage = _parentMessage;
@synthesize resolveMessage = _resolveMessage;

- (id)initWithSelector:(SEL)selector arguments:(NSArray *)arguments
{
    return [self initWithSelectorName:NSStringFromSelector(selector) arguments:arguments];
}

- (id)initWithSelectorName:(NSString *)string arguments:(NSArray *)arguments
{
    return [self initWithSelectorName:string arguments:arguments subMessage:nil];
}

- (id)initWithSelectorName:(NSString *)string arguments:(NSArray *)arguments subMessage:(OSMessage *)subMessage
{
    if(! (self = [super init])) {
        [self release];
        return nil;
    }
    
    _selectorName = [string copy];
    _arguments = [arguments copy];
    _parentMessage = nil;
    
    if(subMessage) {
        _subMessage = [subMessage retain];
        _subMessage.parentMessage = self;
    }
    
    return self;
}

- (id)initWithKeyPath:(NSString *)keypath
{
    self = [self initWithSelectorName:nil arguments:nil subMessage:nil];
    return [self messageFromKeyPath:keypath];
}

- (id)init
{
    return [self initWithSelectorName:nil arguments:nil subMessage:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *selector = [aDecoder decodeObjectForKey:SELECTOR_KEY];
    NSArray *args = [aDecoder decodeObjectForKey:ARGUMENTS_KEY];
    OSMessage *subMessage = [aDecoder decodeObjectForKey:SUBMESSAGE_KEY];
    
     return [self initWithSelectorName:selector arguments:args subMessage:subMessage];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.selectorName forKey:SELECTOR_KEY];
    [aCoder encodeObject:self.arguments forKey:ARGUMENTS_KEY];
    [aCoder encodeObject:self.subMessage forKey:SUBMESSAGE_KEY];
}

- (void)dealloc
{
    _parentMessage = nil;
    
    [_selectorName release];
    [_arguments release];
    [_subMessage release];
    
    [super dealloc];
}

- (SEL)selector
{
    return NSSelectorFromString(self.selectorName);
}

- (id)message:(NSString *)selectorName arguments:(NSArray *)args
{
    // if the root message isn't 
    if(self.selectorName == nil) {
        self.selectorName = selectorName;
        self.arguments = args;
        return self;
    }
    
    OSMessage *parent = nil;
    if(self.subMessage == nil) {
        self.subMessage = [[[OSMessage alloc] initWithSelectorName:selectorName arguments:args] autorelease];
        self.subMessage.parentMessage = self;
        parent = (self.parentMessage == nil ? self : self.parentMessage);
    } else {
        // since this message already has a sub message, lets ask the sub message to add the message.
        // we always return the parent message so that we end up with the root message for serialization purposes.
        // 
        parent = [self.subMessage message:selectorName arguments:args];
    }
    
    return parent;
}

#pragma mark - Method Missing support
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    // we have no way to know what return and argument types are for a given selector.
    // so, we figure out the number of arguments and just fake a signature using that info
    // since we want to return an OSMessasge, the return type is '@'
    NSUInteger count = [[NSStringFromSelector(aSelector) componentsSeparatedByString:@":"] count] - 1;
    NSMutableString *baseSig = [NSMutableString stringWithString:@"@@:"];
    for(NSUInteger i = 0; i < count; i++) {
        [baseSig appendString:@"@"];
    }
    
    // we will need to unpack our arguments on the server once we can get the real method signature
    // this flag will let our server side operation know to do that work.
    self.resolveMessage = YES;
    
    return [NSMethodSignature signatureWithObjCTypes:[baseSig UTF8String]];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // we need to package up our arguments (if any) as data objects
    // stuff them into an array, and then hand the whole mess off to -message:arguments: for message creation.
    NSMethodSignature *sig = [anInvocation methodSignature];
    
    NSUInteger argCount = [sig numberOfArguments];
    NSString *selectorString = NSStringFromSelector([anInvocation selector]);
    NSMutableArray *args = nil;
    
    if(argCount > 2) {
        args = [NSMutableArray array];
        for(NSUInteger i = 2; i < argCount; i++) {
            void *bytes = NULL;
            
            [anInvocation getArgument:&bytes atIndex:i];
            int size = sizeof(bytes);
            NSLog(@"size: %d", size);
            NSData *d = [NSData dataWithBytes:&bytes length:sizeof(bytes)];
            [args addObject:d];
        }
    }
    
    [self message:selectorString arguments:args];
    [anInvocation setReturnValue:&self];
}

#pragma mark - Internal
// keypaths don't support @key modifiers... so no foo.bar.@sum
- (id)messageFromKeyPath:(NSString *)keypath
{
    NSArray *keys = [keypath componentsSeparatedByString:@"."];
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *args = [NSArray arrayWithObject:obj];
        [self message:@"valueForKey:" arguments:args];
    }];
    
    return self;
}

- (NSString *)description
{
    NSString *desc = nil;
    if(self.arguments) {
        desc = [NSString stringWithFormat:@"%@, %@", self.selectorName, self.arguments];
    } else {
        desc = self.selectorName;
    }
    
    NSString *subMsgDesc = nil;
    if(self.subMessage) {
        subMsgDesc = [self.subMessage description];
    }
    
    if(subMsgDesc) {
        desc = [NSString stringWithFormat:@"%@ subMessage: (%@)", desc, subMsgDesc];
    }

    return desc;
}

@end
