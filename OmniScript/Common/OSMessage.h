//
//  OSMessage.h
//  OmniScript
//
//  Created by Kam Dahlin on 9/11/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSResultWrapper.h"

@interface OSMessage : NSObject <NSCoding>
@property (nonatomic, copy) NSString *selectorName;
@property (nonatomic, copy) NSArray *arguments;
@property (nonatomic, readonly, retain) OSMessage *subMessage;

- (id)initWithSelector:(SEL)selector arguments:(NSArray *)arguments;
- (id)initWithSelectorName:(NSString *)string arguments:(NSArray *)arguments; //designated initalizers
- (id)initWithKeyPath:(NSString *)keypath;

- (SEL)selector;

#pragma mark - Message Resolution
- (OSResultWrapper *)invokeMessageOnTarget:(id)target error:(NSError **)error;

#pragma mark - Builder API
- (id)message:(NSString *)selectorName arguments:(NSArray *)args;

// can also use a more natural message description:
// [[[message some] method:arg] otherMethod:arg]
@end
