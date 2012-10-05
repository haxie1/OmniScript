//
//  OSResultPayload.h
//  OmniScript
//
//  Created by Kam Dahlin on 10/4/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSResultWrapper : NSObject
@property (nonatomic, readonly, retain) id result;
@property (nonatomic, readonly, retain) NSString *type;

- (void)setObjectResult:(id)object;
- (void)setNonObjectResult:(const void *)bytes forObjcType:(const char *)type;
@end
