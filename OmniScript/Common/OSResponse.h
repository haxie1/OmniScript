//
//  OSMessageResponse.h
//  OmniScript
//
//  Created by Kam Dahlin on 9/20/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSResultWrapper.h"

@interface OSResponse : NSObject <NSCoding>
@property (nonatomic, assign) BOOL requestSucceeded;
@property (nonatomic, retain) OSResultWrapper *result;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, readonly, retain) NSString *responseID;

- (id)initWithRequestID:(NSString *)requestID result:(OSResultWrapper *)result requestSucceeded:(BOOL)yn error:(NSError *)error;
@end
