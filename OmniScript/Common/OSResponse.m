//
//  OSMessageResponse.m
//  OmniScript
//
//  Created by Kam Dahlin on 9/20/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import "OSResponse.h"

@implementation OSResponse
@synthesize status = _status;
@synthesize result = _result;
@synthesize error = _error;

- (id)initWithStatus:(BOOL)yn result:(id)result error:(NSError *)error
{
    if(! (self = [super init])) {
        [self release];
        return nil;
    }
    
    _status = yn;
    _result = [result retain];
    _error = [error retain];
    
    return self;
}

- (void)dealloc
{
    [_result release];
    [_error release];
    
    [super dealloc];
}
@end
