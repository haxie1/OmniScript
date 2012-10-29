//
//  UIView+OmniScriptSupport.m
//  OmniScript
//
//  Created by Kam Dahlin on 10/25/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import "UIView+OmniScriptSupport.h"

@implementation UIView (OmniScriptSupport)
- (id)omniScriptIdentifier
{
    return nil;
}

- (NSArray *)possibleOmniScriptIdentifiers
{
    return nil;
}

- (CGRect)omniScriptFrame
{
    return [self.window convertRect:self.frame fromView:self];
}


- (NSArray *)omniScriptChildren
{
    return self.subviews;
}
@end
