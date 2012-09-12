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
- (id)initWithSelectorName:(NSString *)string arguments:(NSArray *)arguments subMessage:(OSMessage *)subMessage;
@end

static NSString *SELECTOR_KEY = @"selectorName";
static NSString *ARGUMENTS_KEY = @"arguments";
static NSString *SUBMESSAGE_KEY = @"subMessage";

@implementation OSMessage
@synthesize selectorName = _selectorName;
@synthesize arguments = _arguments;
@synthesize subMessage = _subMessage;
@synthesize parentMessage = _parentMessage;

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
    OSMessage *parent = nil;
    if(self.subMessage == nil) {
        self.subMessage = [[[OSMessage alloc] initWithSelectorName:selectorName arguments:args] autorelease];
        self.subMessage.parentMessage = self;
        parent = (self.parentMessage == nil ? self : self.parentMessage);
    } else {
        parent = [self.subMessage message:selectorName arguments:args];
    }
    
    return parent;
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
