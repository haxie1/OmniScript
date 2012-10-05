//
//  OSResultPayload.m
//  OmniScript
//
//  Created by Kam Dahlin on 10/4/12.
//  Copyright (c) 2012 The Omni Group. All rights reserved.
//

#import "OSResultWrapper.h"

@interface OSResultWrapper ()
@property (nonatomic, readwrite, retain) id result;
@property (nonatomic, readwrite, retain) NSString *type;

- (NSString *)stringForEncodedType:(const char *)type;
- (id)initWithResult:(id)result type:(NSString *)type;
@end

static NSString *RESULT_KEY = @"result";
static NSString *TYPE_KEY = @"type";

@implementation OSResultWrapper
@synthesize result = _result;
@synthesize type = _type;
- (id)initWithResult:(id)result type:(NSString *)type
{
    if (! (self = [super init])) {
        [self release];
        return nil;
    }
    _result = [result retain];
    _type = [type retain];
    
    return self;
}

 - (id)init
{
    return [self initWithResult:nil type:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    id result = [aDecoder decodeObjectForKey:RESULT_KEY];
    NSString *type = [aDecoder decodeObjectForKey:TYPE_KEY];
    
    return [self initWithResult:result type:type];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.result forKey:RESULT_KEY];
    [aCoder encodeObject:self.type forKey:TYPE_KEY];
}

- (void)dealloc
{
    [_result release];
    [_type release];
    [super dealloc];
}

- (void)setObjectResult:(id)object
{
    self.result = object;
    self.type = [self stringForEncodedType:@encode(id)];
}

- (void)setNonObjectResult:(const void *)bytes forObjcType:(const char *)type
{
    if(strcmp(type, "c") == 0) 
        self.result = [NSNumber numberWithChar:(char)bytes];
    else if(strcmp(type, "i") == 0)
        self.result = [NSNumber numberWithInt:(int)bytes];
    else if(strcmp(type, "s") == 0)
        self.result = [NSNumber numberWithShort:(short)bytes];
    else if(strcmp(type, "l") == 0)
        self.result = [NSNumber numberWithLong:(long)bytes];
    else if(strcmp(type, "q") == 0)
        self.result = [NSNumber numberWithLongLong:(long long)bytes];
    else if(strcmp(type, "C") == 0)
        self.result = [NSNumber numberWithUnsignedChar:(unsigned char)bytes];
    else if(strcmp(type, "I") == 0)
        self.result = [NSNumber numberWithUnsignedLongLong:(unsigned int)bytes];
    else if(strcmp(type, "S") == 0)
        self.result = [NSNumber numberWithUnsignedShort:(unsigned short)bytes];
    else if(strcmp(type, "L") == 0)
        self.result = [NSNumber numberWithUnsignedLong:(unsigned long)bytes];
    else if(strcmp(type, "Q") == 0)
        self.result = [NSNumber numberWithUnsignedLongLong:(unsigned long long)bytes];
    else if(strcmp(type, "f") == 0)
        self.result = [NSNumber valueWithBytes:bytes objCType:type];
    else if(strcmp(type, "d") == 0)
        self.result = [NSNumber valueWithBytes:bytes objCType:type];
    else if(strcmp(type, "B") == 0)
        self.result = [NSNumber numberWithBool:(BOOL)bytes];
    else if(strcmp(type, "v") == 0)
        self.result = nil;
    else if((strcmp(type, "*") == 0) || (strcmp(type, "r*") == 0))
        self.result = [NSString stringWithUTF8String:bytes];
    else {
        self.result = [NSValue valueWithBytes:bytes objCType:type];
    }
    
    self.type = [self stringForEncodedType:type];
}

- (NSString *)stringForEncodedType:(const char *)type
{
    return [NSString stringWithUTF8String:type];    
    
}
@end
