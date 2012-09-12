//
//  OSMessage.h
//  OmniScript
//
//  Created by Kam Dahlin on 9/11/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSMessage : NSObject <NSCoding>
@property (nonatomic, copy) NSString *selectorName;
@property (nonatomic, copy) NSArray *arguments;
@property (nonatomic, readonly, retain) OSMessage *subMessage;

- (id)initWithSelector:(SEL)selector arguments:(NSArray *)arguments;
- (id)initWithSelectorName:(NSString *)string arguments:(NSArray *)arguments;

- (SEL)selector;

#pragma mark - Builder API
- (id)message:(NSString *)selectorName arguments:(NSArray *)args;
@end
