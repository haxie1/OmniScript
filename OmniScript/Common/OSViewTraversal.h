//
//  OSViewTraversal.h
//  OmniScript
//
//  Created by Kam Dahlin on 10/29/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSViewRequest.h"

@interface OSViewTraversal : NSObject
@property (nonatomic, readonly) id rootView;

- (id)initWithRootView:(id)view;

- (id)findViewWithRequst:(OSViewRequest *)request error:(NSError **)error;
@end
