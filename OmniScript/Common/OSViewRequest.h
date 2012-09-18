//
//  OSViewRequest.h
//  OmniScript
//
//  Created by Kam Dahlin on 9/14/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSMessage.h"

@interface OSViewRequest : NSObject <NSCoding>

@property (nonatomic, copy) NSString *viewClass;
@property (nonatomic, retain) id identifier;
@property (nonatomic, retain) OSMessage *identifierMessage;

- (id)initWithViewClass:(NSString *)viewClass identifier:(id)identifier identifierUsingMessage:(OSMessage *)message;
@end
