//
//  NSObject+OmniScriptSupport.h
//  OmniScript
//
//  Created by Kam Dahlin on 10/29/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OmniScriptSupport.h"

@interface NSObject (OmniScrptSupport) <OmniScriptIdentification>

@end

@interface NSObject (OmniScriptUtilities)
- (NSArray *)methodNames;
- (NSArray *)propertyNames;

- (NSArray *)methodNamesIncludingInherited:(BOOL)includeInherited;
- (NSArray *)propertyNamesIncludingInherited:(BOOL)includeInherited;
@end
