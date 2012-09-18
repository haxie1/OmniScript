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
@property (nonatomic, retain) OSViewRequest *request;

- (id)initWithViewClass:(NSString *)viewClass identifier:(id)identifier usingMessageForIdentifier:(OSMessage *)message;

// message builder
// find with generic view
- (id)findIdentifer:(id)identifer;
- (id)findIdentifer:(id)identifer usingMessageForIdentifier:(OSMessage *)message;

// find with specific view
- (id)findViewClass:(NSString *)viewClass;
- (id)findViewClass:(NSString *)viewClass withIdentifer:(id)identifier;
- (id)findViewClass:(NSString *)viewClass withIdentifier:(id)identifier usingMessageForIdentifier:(OSMessage *)message;
@end
