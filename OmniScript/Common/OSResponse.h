//
//  OSMessageResponse.h
//  OmniScript
//
//  Created by Kam Dahlin on 9/20/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSResponse : NSObject
@property (nonatomic, assign) BOOL status;
@property (nonatomic, retain) id result;
@property (nonatomic, retain) NSError *error;

- (id)initWithStatus:(BOOL)yn result:(id)result error:(NSError *)error;
@end
