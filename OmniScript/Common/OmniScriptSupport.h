//
//  OmniScriptSupport.h
//  OmniScript
//
//  Created by Kam Dahlin on 10/17/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OmniScriptIdentificationProtocol <NSObject>
- (id)omniScriptIdentifier;
- (NSArray *)possibleOmniScriptIdentifiers;
@end

@protocol OmniScriptScriptingContainerProtocol <NSObject>
- (NSArray *)omniScriptChildren;
@end
