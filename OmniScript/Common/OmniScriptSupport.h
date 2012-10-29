//
//  OmniScriptSupport.h
//  OmniScript
//
//  Created by Kam Dahlin on 10/17/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol OmniScriptIdentification <NSObject>
- (id)omniScriptIdentifier;
- (NSArray *)possibleOmniScriptIdentifiers;
- (CGRect)omniScriptFrame; // return frame in screen coordindates.
@end

@protocol OmniScriptScriptingContainer <OmniScriptIdentification>
- (NSArray *)omniScriptChildren;
@end
