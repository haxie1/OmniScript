//
//  OSApplication.h
//  OmniScript
//
//  Created by Kam Dahlin on 10/15/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSApplication : NSObject
@property (nonatomic, assign) BOOL isPublished;

+ (void)startOmniScriptSessionWithSessionName:(NSString *)sessionName;

- (void)stopSession;
@end
