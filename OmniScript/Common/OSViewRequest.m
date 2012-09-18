//
//  OSViewRequest.m
//  OmniScript
//
//  Created by Kam Dahlin on 9/14/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import "OSViewRequest.h"

static NSString *VIEW_CLASS_KEY = @"viewClass";
static NSString *IDENTIFIER_KEY = @"identifier";
static NSString *IDENTIFIER_MESSAGE_KEY = @"identifierMessage";

@implementation OSViewRequest
@synthesize viewClass = _viewClass;
@synthesize identifier = _identifier;
@synthesize identifierMessage = _identifierMessage;

- (id)initWithViewClass:(NSString *)viewClass identifier:(id)identifier identifierUsingMessage:(OSMessage *)message
{
    if(! (self = [super init])) {
        [self release];
        return nil;
    }
    
    if(viewClass == nil) {
        viewClass = @"view";
    }
    
    _viewClass = [viewClass copy];
    
    _identifier = [identifier retain];
    if(_identifier && message == nil) {
        _identifierMessage = [[OSMessage alloc] initWithSelectorName:@"omniScriptIdentifier" arguments:nil];
    } else {
       _identifierMessage = [message retain];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *viewClass = [aDecoder decodeObjectForKey:VIEW_CLASS_KEY];
    id ident = [aDecoder decodeObjectForKey:IDENTIFIER_KEY];
    OSMessage *message = [aDecoder decodeObjectForKey:IDENTIFIER_MESSAGE_KEY];
    
    return [self initWithViewClass:viewClass identifier:ident identifierUsingMessage:message];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.viewClass forKey:VIEW_CLASS_KEY];
    [aCoder encodeObject:self.identifier forKey:IDENTIFIER_KEY];
    [aCoder encodeObject:self.identifierMessage forKey:IDENTIFIER_MESSAGE_KEY];
}

- (void)dealloc
{
    [_viewClass release];
    [_identifier release];
    [_identifierMessage release];
    
    [super dealloc];
}
@end
