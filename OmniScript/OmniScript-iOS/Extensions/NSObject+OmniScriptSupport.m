//
//  NSObject+OmniScriptSupport.m
//  OmniScript
//
//  Created by Kam Dahlin on 10/29/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import "NSObject+OmniScriptSupport.h"
#import <objc/runtime.h>

@implementation NSObject (OmniScriptSupport)
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
    return CGRectZero;
}
@end

@interface NSObject (OmniScriptUtilitiesPrivate)
- (NSString *)formatMethodSig:(Method)m;
@end

@implementation NSObject (OmniScriptUtilities)
- (NSArray *)methodNames
{
    return [self methodNamesIncludingInherited:YES];
}

- (NSArray *)propertyNames
{
    return [self propertyNamesIncludingInherited:YES];
}

- (NSArray *)methodNamesIncludingInherited:(BOOL)includeInherited
{
    Class currentClass = [self class];
    NSMutableArray *methods = [NSMutableArray array];
    
    while(currentClass) {
        unsigned int count = 0;
        Method *list = class_copyMethodList(currentClass, &count);
        
        for(NSUInteger i = 0; i < count; i++) {
            
            NSString *method = [self formatMethodSig:list[i]];
            [methods addObject:method];
        }
        
        free(list);
        
        if(! includeInherited) {
            break;
        }
        
        currentClass = [currentClass superclass];
    }
    
    return [[methods copy] autorelease];
}

- (NSArray *)propertyNamesIncludingInherited:(BOOL)includeInherited
{
    Class currentClass = [self class];
    NSMutableArray *properties = [NSMutableArray array];
    
    while(currentClass) {
        unsigned int count = 0;
        objc_property_t *props = class_copyPropertyList(currentClass, &count);
        for(NSUInteger i = 0; i < count; i++) {
            NSString *propStr = [NSString stringWithUTF8String:property_getName(props[i])];
            [properties addObject:propStr];
        }
        free(props);
        
        if(! includeInherited) {
            break;
        }
        
        currentClass = [currentClass superclass];
    }
    
    return [[properties copy] autorelease];
}

- (NSString *)formatMethodSig:(Method)m
{
    NSString *method = NSStringFromSelector(method_getName(m));

    NSMutableArray *parts = [NSMutableArray arrayWithArray:[method componentsSeparatedByString:@":"]];
    [parts removeLastObject]; // get rid of the extra empty row inserted by the final ':' in the method sig
    
    unsigned int args = method_getNumberOfArguments(m) - 2;
    NSMutableArray *partsAndArgs = [[NSMutableArray alloc] initWithCapacity:args];
    
    if(args == 0) {
        [partsAndArgs addObject:method];
    }
    
    for(NSUInteger i = 0; i < args; i++) {
        char *arg = method_copyArgumentType(m, (2 + i));
        NSString *argStr = [NSString stringWithUTF8String:arg];
        NSString *nameAndArg = [NSString stringWithFormat:@"%@:%@", [parts objectAtIndex:i], argStr];
        [partsAndArgs addObject:nameAndArg];
        free(arg);
    }
    
    char *type = method_copyReturnType(m);
    NSString *returnType = [NSString stringWithUTF8String:type];
    free(type);
    
    NSString *fullMethod = [NSString stringWithFormat:@"(%@)%@", returnType, [partsAndArgs componentsJoinedByString:@" "]];
    [partsAndArgs release];
    
    return fullMethod;
    
}
@end