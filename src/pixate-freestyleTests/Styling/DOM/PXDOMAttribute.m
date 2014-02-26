//
//  PXDOMAttribute.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXDOMAttribute.h"

@implementation PXDOMAttribute

@synthesize namespacePrefix = namespacePrefix_;
@synthesize name = name_;
@synthesize value = value_;

- initWithName:(NSString *)name value:(id)value
{
    if (self = [super init])
    {
        NSArray *parts = [name componentsSeparatedByString:@":"];

        if (parts.count == 2)
        {
            namespacePrefix_ = [parts objectAtIndex:0];
            name_ = [parts lastObject];
        }
        else
        {
            namespacePrefix_ = @"";
            name_ = name;
        }

        value_ = value;
    }

    return self;
}

- (NSString *)description
{
    if (namespacePrefix_.length > 0)
    {
        return [NSString stringWithFormat:@"%@:%@=\"%@\"", namespacePrefix_, name_, value_];
    }
    else
    {
        return [NSString stringWithFormat:@"%@=\"%@\"", name_, value_];
    }
}

@end
