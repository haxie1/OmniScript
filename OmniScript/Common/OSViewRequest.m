//
//  OSViewRequest.m
//  OmniScript
//
//  Created by Kam Dahlin on 9/14/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import "OSViewRequest.h"

@interface OSViewRequest ()
- (id)initWithViewClass:(NSString *)viewClass identifier:(id)identifier identifierUsingMessage:(OSMessage *)message subViewRequest:(OSViewRequest *)request;
@end

static NSString *VIEW_CLASS_KEY = @"viewClass";
static NSString *IDENTIFIER_KEY = @"identifier";
static NSString *IDENTIFIER_MESSAGE_KEY = @"identifierMessage";
static NSString *REQUEST_KEY = @"request";

@implementation OSViewRequest
@synthesize viewClass = _viewClass;
@synthesize identifier = _identifier;
@synthesize identifierMessage = _identifierMessage;
@synthesize request = _request;

- (id)initWithViewClass:(NSString *)viewClass identifier:(id)identifier identifierUsingMessage:(OSMessage *)message
{
    
    return [self initWithViewClass:viewClass identifier:identifier identifierUsingMessage:message subViewRequest:nil];
}

- (id)initWithViewClass:(NSString *)viewClass identifier:(id)identifier identifierUsingMessage:(OSMessage *)message subViewRequest:(OSViewRequest *)request
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
    
    if(request) {
      _request = [request retain];  
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *viewClass = [aDecoder decodeObjectForKey:VIEW_CLASS_KEY];
    id ident = [aDecoder decodeObjectForKey:IDENTIFIER_KEY];
    OSMessage *message = [aDecoder decodeObjectForKey:IDENTIFIER_MESSAGE_KEY];
    OSViewRequest *req = [aDecoder decodeObjectForKey:REQUEST_KEY];
    
    return [self initWithViewClass:viewClass identifier:ident identifierUsingMessage:message subViewRequest:req];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.viewClass forKey:VIEW_CLASS_KEY];
    [aCoder encodeObject:self.identifier forKey:IDENTIFIER_KEY];
    [aCoder encodeObject:self.identifierMessage forKey:IDENTIFIER_MESSAGE_KEY];
    [aCoder encodeObject:self.request forKey:REQUEST_KEY];
}

- (void)dealloc
{
    [_viewClass release];
    [_identifier release];
    [_identifierMessage release];
    [_request release];
    
    [super dealloc];
}

- (id)findViewClass:(NSString *)viewClass
{
    return [self findViewClass:viewClass withIdentifier:nil usingMessageForIdentifier:nil];
}

- (id)findViewClass:(NSString *)viewClass withIdentifer:(id)identifier
{
    return [self findViewClass:viewClass withIdentifier:identifier usingMessageForIdentifier:nil];
}

- (id)findViewClass:(NSString *)viewClass withIdentifier:(id)identifier usingMessageForIdentifier:(OSMessage *)message
{
    OSViewRequest *subReq = self.request;
    if(subReq == nil) {
        self.request = [[[OSViewRequest alloc] initWithViewClass:viewClass identifier:identifier identifierUsingMessage:message] autorelease];
    } else {
        [subReq findViewClass:viewClass withIdentifier:identifier usingMessageForIdentifier:message];
    }
    return self;
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"viewClass: %@", self.viewClass];
    if(self.identifier) {
        [desc appendFormat:@"\n\tidentifier: %@", self.identifier];
    }
    
    if(self.identifierMessage) {
        [desc appendFormat:@"\n\tusing identiifer message: %@", [self.identifierMessage description]];
    }
    
    NSString *subReqDesc = [self.request description];
    if(subReqDesc) {
        [desc appendFormat:@"\n\tsub request %@", subReqDesc];
    }
    
    return [[desc copy] autorelease];
}
@end
