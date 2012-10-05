//
//  OSMessageResponse.m
//  OmniScript
//
//  Created by Kam Dahlin on 9/20/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import "OSResponse.h"
@interface OSResponse ()
@property (nonatomic, readwrite, retain) NSString *responseID;
- (NSString *)generateUUID;
@end

static NSString *RESPONSE_ID_KEY = @"responseID";
static NSString *REQUEST_SUCCEEDED_KEY = @"requestSucceeded";
static NSString *RESULT_KEY = @"result";
static NSString *ERROR_KEY = @"error";

@implementation OSResponse
@synthesize requestSucceeded = _requestSucceeded;
@synthesize result = _result;
@synthesize error = _error;
@synthesize responseID = _responseID;

- (id)initWithRequestID:(NSString *)requestID result:(OSResultWrapper *)result requestSucceeded:(BOOL)yn error:(NSError *)error;
{
    if(! (self = [super init])) {
        [self release];
        return nil;
    }
    
    if(! requestID) {
        requestID = [self generateUUID];
    }
    
    _responseID = [requestID retain];
    _requestSucceeded = yn;
    _result = [result retain];
    _error = [error retain];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *responseID = [aDecoder decodeObjectForKey:RESPONSE_ID_KEY];
    OSResultWrapper *result = [aDecoder decodeObjectForKey:RESULT_KEY];
    BOOL success = [aDecoder decodeBoolForKey:REQUEST_SUCCEEDED_KEY];
    NSError *err = [aDecoder decodeObjectForKey:ERROR_KEY];
    
    
    return [self initWithRequestID:responseID result:result requestSucceeded:success error:err];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.responseID forKey:RESPONSE_ID_KEY];
    [aCoder encodeObject:self.result forKey:RESULT_KEY];
    [aCoder encodeBool:self.requestSucceeded forKey:REQUEST_SUCCEEDED_KEY];
    [aCoder encodeObject:self.error forKey:ERROR_KEY];
}

- (void)dealloc
{
    [_responseID release];
    [_result release];
    [_error release];
    
    [super dealloc];
}

// there may be times when the server just needs to send a response to the client
// since no request was generated from the client, we need to generate our own response id.
// this may not end up being useful, but here for completeness.
- (NSString *)generateUUID
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (NSString *)CFUUIDCreateString(NULL, uuid);
    
    CFRelease(uuid);
    
    return [uuidStr autorelease];
}
@end
